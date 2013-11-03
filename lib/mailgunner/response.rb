module Mailgunner
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
