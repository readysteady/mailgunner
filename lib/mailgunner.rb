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

    private

    def get(path, params = {})
      get_request = Net::HTTP::Get.new(request_uri(path, params))
      get_request.basic_auth('api', @api_key)

      Response.new(@http.request(get_request))
    end

    def post(path, attributes = {})
      post_request = Net::HTTP::Post.new(path)
      post_request.basic_auth('api', @api_key)
      post_request.body = URI.encode_www_form(attributes)

      Response.new(@http.request(post_request))
    end

    def delete(path)
      delete_request = Net::HTTP::Delete.new(path)
      delete_request.basic_auth('api', @api_key)

      Response.new(@http.request(delete_request))
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
