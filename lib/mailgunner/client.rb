# frozen_string_literal: true
require 'net/http'
require 'json'

module Mailgunner
  class Client
    def initialize(domain: nil, api_key: nil, api_host: nil)
      @domain = domain || Mailgunner.config.domain

      @api_key = api_key || Mailgunner.config.api_key

      @api_host = api_host || Mailgunner.config.api_host

      @http = Net::HTTP.new(@api_host, Net::HTTP.https_default_port)

      @http.use_ssl = true
    end

    private

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

    def transmit(message)
      message.basic_auth('api', @api_key)
      message['User-Agent'] = Mailgunner.config.user_agent

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
