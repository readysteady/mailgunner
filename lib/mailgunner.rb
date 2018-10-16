require 'net/http'
require 'json'
require 'cgi'
require 'mailgunner/version'
require 'mailgunner/errors'
require 'mailgunner/delivery_method' if defined?(Mail)
require 'mailgunner/railtie' if defined?(Rails)

module Mailgunner
  class Client
    attr_accessor :domain, :api_key, :http

    def initialize(options = {})
      @domain = if options.key?(:domain)
        options.fetch(:domain)
      elsif ENV.key?('MAILGUN_SMTP_LOGIN')
        ENV['MAILGUN_SMTP_LOGIN'].to_s.split('@').last
      else
        NoDomainProvided
      end

      @api_key = options.fetch(:api_key) { ENV.fetch('MAILGUN_API_KEY') }

      @http = Net::HTTP.new('api.mailgun.net', Net::HTTP.https_default_port)

      @http.use_ssl = true
    end

    def validate_address(value)
      get('/v3/address/validate', address: value)
    end

    def parse_addresses(values)
      get('/v3/address/parse', addresses: Array(values).join(','))
    end

    def get_message(key)
      get("/v3/domains/#{escape @domain}/messages/#{escape key}")
    end

    def get_mime_message(key)
      get("/v3/domains/#{escape @domain}/messages/#{escape key}", {}, {'Accept' => 'message/rfc2822'})
    end

    def send_message(attributes = {})
      post("/v3/#{escape @domain}/messages", attributes)
    end

    def send_mime(mail)
      to = ['to', Array(mail.destinations).join(',')]

      message = ['message', mail.encoded, {filename: 'message.mime'}]

      multipart_post("/v3/#{escape @domain}/messages.mime", [to, message])
    end

    def delete_message(key)
      delete("/v3/domains/#{escape @domain}/messages/#{escape key}")
    end

    def get_domains(params = {})
      get('/v3/domains', params)
    end

    def get_domain(name)
      get("/v3/domains/#{escape name}")
    end

    def add_domain(attributes = {})
      post('/v3/domains', attributes)
    end

    def delete_domain(name)
      delete("/v3/domains/#{escape name}")
    end

    def get_credentials
      get("/v3/domains/#{escape @domain}/credentials")
    end

    def add_credentials(attributes)
      post("/v3/domains/#{escape @domain}/credentials", attributes)
    end

    def update_credentials(login, attributes)
      put("/v3/domains/#{escape @domain}/credentials/#{escape login}", attributes)
    end

    def delete_credentials(login)
      delete("/v3/domains/#{escape @domain}/credentials/#{escape login}")
    end

    def get_connection_settings
      get("/v3/domains/#{escape @domain}/connection")
    end

    def update_connection_settings(attributes)
      put("/v3/domains/#{escape @domain}/connection", attributes)
    end

    def get_unsubscribes(params = {})
      get("/v3/#{escape @domain}/unsubscribes", params)
    end

    def get_unsubscribe(address)
      get("/v3/#{escape @domain}/unsubscribes/#{escape address}")
    end

    def delete_unsubscribe(address_or_id)
      delete("/v3/#{escape @domain}/unsubscribes/#{escape address_or_id}")
    end

    def add_unsubscribe(attributes = {})
      post("/v3/#{escape @domain}/unsubscribes", attributes)
    end

    def get_complaints(params = {})
      get("/v3/#{escape @domain}/complaints", params)
    end

    def get_complaint(address)
      get("/v3/#{escape @domain}/complaints/#{escape address}")
    end

    def add_complaint(attributes = {})
      post("/v3/#{escape @domain}/complaints", attributes)
    end

    def delete_complaint(address)
      delete("/v3/#{escape @domain}/complaints/#{escape address}")
    end

    def get_bounces(params = {})
      get("/v3/#{escape @domain}/bounces", params)
    end

    def get_bounce(address)
      get("/v3/#{escape @domain}/bounces/#{escape address}")
    end

    def add_bounce(attributes = {})
      post("/v3/#{escape @domain}/bounces", attributes)
    end

    def delete_bounce(address)
      delete("/v3/#{escape @domain}/bounces/#{escape address}")
    end

    def delete_bounces
      delete("/v3/#{escape @domain}/bounces")
    end

    def get_stats(params = {})
      Kernel.warn 'Mailgunner::Client#get_stats is deprecated'

      get("/v3/#{escape @domain}/stats", params)
    end

    def get_total_stats(params = {})
      get("/v3/#{escape @domain}/stats/total", params)
    end

    def get_events(params = {})
      get("/v3/#{escape @domain}/events", params)
    end

    def get_tags(params = {})
      get("/v3/#{escape @domain}/tags", params)
    end

    def get_tag(id)
      get("/v3/#{escape @domain}/tags/#{escape id}")
    end

    def update_tag(id, attributes)
      put("/v3/#{escape @domain}/tags/#{escape id}", attributes)
    end

    def get_tag_stats(id, params)
      get("/v3/#{escape @domain}/tags/#{escape id}/stats", params)
    end

    def delete_tag(id)
      delete("/v3/#{escape @domain}/tags/#{escape id}")
    end

    def get_routes(params = {})
      get('/v3/routes', params)
    end

    def get_route(id)
      get("/v3/routes/#{escape id}")
    end

    def add_route(attributes = {})
      post('/v3/routes', attributes)
    end

    def update_route(id, attributes = {})
      put("/v3/routes/#{escape id}", attributes)
    end

    def delete_route(id)
      delete("/v3/routes/#{escape id}")
    end

    def get_webhooks
      get("/v3/domains/#{escape @domain}/webhooks")
    end

    def get_webhook(id)
      get("/v3/domains/#{escape @domain}/webhooks/#{escape id}")
    end

    def add_webhook(attributes = {})
      post("/v3/domains/#{escape @domain}/webhooks", attributes)
    end

    def update_webhook(id, attributes = {})
      put("/v3/domains/#{escape @domain}/webhooks/#{escape id}", attributes)
    end

    def delete_webhook(id)
      delete("/v3/domains/#{escape @domain}/webhooks/#{escape id}")
    end

    def get_lists(params = {})
      get('/v3/lists', params)
    end

    def get_list(address)
      get("/v3/lists/#{escape address}")
    end

    def add_list(attributes = {})
      post('/v3/lists', attributes)
    end

    def update_list(address, attributes = {})
      put("/v3/lists/#{escape address}", attributes)
    end

    def delete_list(address)
      delete("/v3/lists/#{escape address}")
    end

    def get_list_members(list_address, params = {})
      get("/v3/lists/#{escape list_address}/members", params)
    end

    def get_list_member(list_address, member_address)
      get("/v3/lists/#{escape list_address}/members/#{escape member_address}")
    end

    def add_list_member(list_address, member_attributes)
      post("/v3/lists/#{escape list_address}/members", member_attributes)
    end

    def update_list_member(list_address, member_address, member_attributes)
      put("/v3/lists/#{escape list_address}/members/#{escape member_address}", member_attributes)
    end

    def delete_list_member(list_address, member_address)
      delete("/v3/lists/#{escape list_address}/members/#{escape member_address}")
    end

    private

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
