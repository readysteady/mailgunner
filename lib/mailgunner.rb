require 'net/http'
require 'json'
require 'cgi'
require 'uri'

module Mailgunner
  class Client
    attr_accessor :domain, :api_key, :public_key, :http

    def initialize(options = {})
      @domain = options.fetch(:domain) { ENV.fetch('MAILGUN_SMTP_LOGIN').split('@').last }

      @api_key = options.fetch(:api_key) { ENV.fetch('MAILGUN_API_KEY') }

      @public_key = options.fetch(:public_key) { ENV.fetch('MAILGUN_PUBLIC_KEY') }

      if options.has_key?(:json)
        Kernel.warn 'Mailgunner::Client :json option is deprecated'

        @json = options[:json]
      else
        @json = JSON
      end

      @http = Net::HTTP.new('api.mailgun.net', Net::HTTP.https_default_port)

      @http.use_ssl = true
    end

    def json
      Kernel.warn 'Mailgunner::Client#json is deprecated'

      @json
    end

    def json=(json)
      Kernel.warn 'Mailgunner::Client#json= is deprecated'

      @json = json
    end

    def validate_address(value)
      get('/v2/address/validate', {address: value}, :public_key)
    end

    def parse_addresses(values)
      get('/v2/address/parse', addresses: Array(values).join(','))
    end

    def send_message(attributes = {})
      post("/v2/#{escape @domain}/messages", attributes)
    end

    def get_domains(params = {})
      get('/v2/domains', params)
    end

    def get_domain(name)
      get("/v2/domains/#{escape name}")
    end

    def add_domain(attributes = {})
      post('/v2/domains', attributes)
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
      Kernel.warn 'Mailgunner::Client#get_log is deprecated'

      get("/v2/#{escape @domain}/log", params)
    end

    def get_events(params = {})
      get("/v2/#{escape @domain}/events", params)
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

    def get_mailboxes(params = {})
      Kernel.warn 'Mailgunner::Client#get_mailboxes is deprecated'

      get("/v2/#{escape @domain}/mailboxes", params)
    end

    def add_mailbox(attributes = {})
      Kernel.warn 'Mailgunner::Client#add_mailbox is deprecated'

      post("/v2/#{escape @domain}/mailboxes", attributes)
    end

    def update_mailbox(name, attributes = {})
      Kernel.warn 'Mailgunner::Client#update_mailbox is deprecated'

      put("/v2/#{escape @domain}/mailboxes/#{escape name}", attributes)
    end

    def delete_mailbox(name)
      Kernel.warn 'Mailgunner::Client#delete_mailbox is deprecated'

      delete("/v2/#{escape @domain}/mailboxes/#{escape name}")
    end

    def get_campaigns(params = {})
      get("/v2/#{escape @domain}/campaigns", params)
    end

    def get_campaign(id)
      get("/v2/#{escape @domain}/campaigns/#{escape id}")
    end

    def add_campaign(attributes = {})
      post("/v2/#{escape @domain}/campaigns", attributes)
    end

    def update_campaign(id, attributes = {})
      put("/v2/#{escape @domain}/campaigns/#{escape id}", attributes)
    end

    def delete_campaign(id)
      delete("/v2/#{escape @domain}/campaigns/#{escape id}")
    end

    def get_campaign_events(campaign_id, params = {})
      get("/v2/#{escape @domain}/campaigns/#{escape campaign_id}/events", params)
    end

    def get_campaign_stats(campaign_id, params = {})
      get("/v2/#{escape @domain}/campaigns/#{escape campaign_id}/stats", params)
    end

    def get_campaign_clicks(campaign_id, params = {})
      get("/v2/#{escape @domain}/campaigns/#{escape campaign_id}/clicks", params)
    end

    def get_campaign_opens(campaign_id, params = {})
      get("/v2/#{escape @domain}/campaigns/#{escape campaign_id}/opens", params)
    end

    def get_campaign_unsubscribes(campaign_id, params = {})
      get("/v2/#{escape @domain}/campaigns/#{escape campaign_id}/unsubscribes", params)
    end

    def get_campaign_complaints(campaign_id, params = {})
      get("/v2/#{escape @domain}/campaigns/#{escape campaign_id}/complaints", params)
    end

    def get_lists(params = {})
      get('/v2/lists', params)
    end

    def get_list(address)
      get("/v2/lists/#{escape address}")
    end

    def add_list(attributes = {})
      post('/v2/lists', attributes)
    end

    def update_list(address, attributes = {})
      put("/v2/lists/#{escape address}", attributes)
    end

    def delete_list(address)
      delete("/v2/lists/#{escape address}")
    end

    def get_list_members(list_address, params = {})
      get("/v2/lists/#{escape list_address}/members", params)
    end

    def get_list_member(list_address, member_address)
      get("/v2/lists/#{escape list_address}/members/#{escape member_address}")
    end

    def add_list_member(list_address, member_attributes)
      post("/v2/lists/#{escape list_address}/members", member_attributes)
    end

    def update_list_member(list_address, member_address, member_attributes)
      put("/v2/lists/#{escape list_address}/members/#{escape member_address}", member_attributes)
    end

    def delete_list_member(list_address, member_address)
      delete("/v2/lists/#{escape list_address}/members/#{escape member_address}")
    end

    def get_list_stats(list_address)
      get("/v2/lists/#{escape list_address}/stats")
    end

    private

    def get(path, params = {}, auth = :api_key)
      transmit(Net::HTTP::Get, request_uri(path, params), {}, auth)
    end

    def post(path, attributes = {}, auth = :api_key)
      transmit(Net::HTTP::Post, path, attributes, auth)
    end

    def put(path, attributes = {}, auth = :api_key)
      transmit(Net::HTTP::Put, path, attributes, auth)
    end

    def delete(path, auth = :api_key)
      transmit(Net::HTTP::Delete, path, {}, auth)
    end

    def transmit(subclass, path, attributes = nil, auth = :api_key)
      message = subclass.new(path)
      message.basic_auth('api', ((auth == :api_key) ? @api_key : @public_key))
      message.body = URI.encode_www_form(attributes) if attributes && attributes.length > 0

      Response.new(@http.request(message), :json => @json)
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
    def initialize(http_response, options = {})
      @http_response = http_response

      @json = options.fetch(:json) { JSON }
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

    def client_error?
      (400 .. 499).include?(code.to_i)
    end

    def server_error?
      (500 .. 599).include?(code.to_i)
    end

    def json?
      self['Content-Type'].split(';').first == 'application/json'
    end

    def object
      @object ||= @json.parse(body)
    end
  end
end
