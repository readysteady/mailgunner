# frozen_string_literal: true
require 'net/http'
require 'json'
require 'cgi'

module Mailgunner
  class Client
    attr_accessor :domain, :api_key, :http

    def initialize(options = {})
      @domain = options.fetch(:domain) { default_domain }

      @api_key = options.fetch(:api_key) { ENV.fetch('MAILGUN_API_KEY') }

      @api_host = options.fetch(:api_host) { 'api.mailgun.net' }

      @http = Net::HTTP.new(@api_host, Net::HTTP.https_default_port)

      @http.use_ssl = true
    end

    private

    def default_domain
      return NoDomainProvided unless ENV.key?('MAILGUN_SMTP_LOGIN')

      ENV['MAILGUN_SMTP_LOGIN'].to_s.split('@').last
    end

    def get(path, params = {}, headers = {})
      request = Net::HTTP::Get.new(request_uri(path, params))

      headers.each { |k, v| request[k] = v }

      transmit(request)
    end

    def post(path, attributes = {})
      transmit(Net::HTTP::Post.new(path)) { |message| message.set_form_data(attributes) }
    end

    def multipart_post(path, data)
      transmit(Net::HTTP::Post.new(path)) { |message| message.set_form(data, 'multipart/form-data') }
    end

    def put(path, attributes = {})
      transmit(Net::HTTP::Put.new(path)) { |message| message.set_form_data(attributes) }
    end

    def delete(path)
      transmit(Net::HTTP::Delete.new(path))
    end

    USER_AGENT = "Ruby/#{RUBY_VERSION} Mailgunner/#{VERSION}"

    def transmit(message)
      message.basic_auth('api', @api_key)
      message['User-Agent'] = USER_AGENT

      yield message if block_given?

      parse(@http.request(message))
    end

    def parse(response)
      case response
      when Net::HTTPSuccess
        parse_success(response)
      when Net::HTTPUnauthorized
        raise AuthenticationError, "HTTP #{response.code}"
      when Net::HTTPClientError
        raise ClientError, "HTTP #{response.code}"
      when Net::HTTPServerError
        raise ServerError, "HTTP #{response.code}"
      else
        raise Error, "HTTP #{response.code}"
      end
    end

    def parse_success(response)
      return JSON.parse(response.body) if json?(response)

      response.body
    end

    def json?(response)
      content_type = response['Content-Type']

      content_type && content_type.split(';').first == 'application/json'
    end

    def request_uri(path, params)
      return path if params.empty?

      path + '?' + params.flat_map { |k, vs| Array(vs).map { |v| "#{escape(k)}=#{escape(v)}" } }.join('&')
    end

    def escape(component)
      CGI.escape(component.to_s)
    end
  end
end
