require 'net/http'
require 'json'
require 'cgi'
require 'uri'

module Mailgunner
  class Client
    attr_accessor :http

    def initialize(options = {})
      @domain = options.fetch(:domain)

      @api_key = options.fetch(:api_key)

      @http = Net::HTTP.new('api.mailgun.net', Net::HTTP.https_default_port)

      @http.use_ssl = true
    end

    def get_unsubscribes(params = {})
      get("/v2/#{escape @domain}/unsubscribes", params)
    end

    def get_unsubscribe(address)
      get("/v2/#{escape @domain}/unsubscribes/#{escape address}")
    end

    def delete_unsubscribe(address_or_id)
      delete("/v2/#{escape @domain}/unsubscribes/#{escape address_or_id}")
    end

    def add_unsubscribe(attributes = {})
      post("/v2/#{escape @domain}/unsubscribes", attributes)
    end

    def get_complaints(params = {})
      get("/v2/#{escape @domain}/complaints", params)
    end

    def get_complaint(address)
      get("/v2/#{escape @domain}/complaints/#{escape address}")
    end

    def add_complaint(attributes = {})
      post("/v2/#{escape @domain}/complaints", attributes)
    end

    def delete_complaint(address)
      delete("/v2/#{escape @domain}/complaints/#{escape address}")
    end

    def get_bounces(params = {})
      get("/v2/#{escape @domain}/bounces", params)
    end

    def get_bounce(address)
      get("/v2/#{escape @domain}/bounces/#{escape address}")
    end

    def add_bounce(attributes = {})
      post("/v2/#{escape @domain}/bounces", attributes)
    end

    def delete_bounce(address)
      delete("/v2/#{escape @domain}/bounces/#{escape address}")
    end

    def get_stats(params = {})
      get("/v2/#{escape @domain}/stats", params)
    end

    def get_log(params = {})
      get("/v2/#{escape @domain}/log", params)
    end

    def get_routes(params = {})
      get('/v2/routes', params)
    end

    def get_route(id)
      get("/v2/routes/#{escape id}")
    end

    def add_route(attributes = {})
      post('/v2/routes', attributes)
    end

    def update_route(id, attributes = {})
      put("/v2/routes/#{escape id}", attributes)
    end

    def delete_route(id)
      delete("/v2/routes/#{escape id}")
    end

    private

    def get(path, params = {})
      transmit(Net::HTTP::Get, request_uri(path, params))
    end

    def post(path, attributes = {})
      transmit(Net::HTTP::Post, path, attributes)
    end

    def put(path, attributes = {})
      transmit(Net::HTTP::Put, path, attributes)
    end

    def delete(path)
      transmit(Net::HTTP::Delete, path)
    end

    def transmit(subclass, path, attributes = nil)
      message = subclass.new(path)
      message.basic_auth('api', @api_key)
      message.body = URI.encode_www_form(attributes) if attributes

      Response.new(@http.request(message))
    end

    def request_uri(path, params_hash)
      if params_hash.empty?
        path
      else
        tmp = []

        params_hash.each do |key, values|
          Array(values).each do |value|
            tmp << "#{escape(key)}=#{escape(value)}"
          end
        end

        path + '?' + tmp.join('&')
      end
    end

    def escape(component)
      CGI.escape(component.to_s)
    end
  end

  class Response
    def initialize(http_response)
      @http_response = http_response
    end

    def method_missing(name, *args, &block)
      @http_response.send(name, *args, &block)
    end

    def respond_to_missing?(name, include_private = false)
      @http_response.respond_to?(name)
    end

    def ok?
      code.to_i == 200
    end

    def json?
      self['Content-Type'].split(';').first == 'application/json'
    end

    def object
      @object ||= JSON.parse(body)
    end
  end
end
