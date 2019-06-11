# frozen_string_literal: true
require 'net/http'
require 'json'

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
      uri = URI(path)
      uri.query = Params.encode(params) unless params.empty?

      request = Net::HTTP::Get.new(uri.to_s)

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

      response = @http.request(message)

      unless response.is_a?(Net::HTTPSuccess)
        raise Error.parse(response)
      end

      if response['Content-Type']&.start_with?('application/json')
        return JSON.parse(response.body)
      end

      response.body
    end

    def escape(component)
      Params.escape(component)
    end
  end
end
