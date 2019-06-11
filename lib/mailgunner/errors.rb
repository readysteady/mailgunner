# frozen_string_literal: true

module Mailgunner
  class Error < StandardError
    def self.parse(response)
      exception_class = case response
        when Net::HTTPUnauthorized
          AuthenticationError
        when Net::HTTPClientError
          ClientError
        when Net::HTTPServerError
          ServerError
        else
          Error
        end

      message = if response['Content-Type']&.start_with?('application/json')
        JSON.parse(response.body)['message']
      end

      message ||= "HTTP #{response.code} response from Mailgun API"

      exception_class.new(message)
    end
  end

  class ClientError < Error; end

  class AuthenticationError < ClientError; end

  class ServerError < Error; end

  module NoDomainProvided
    def self.to_s
      raise Error, 'No domain provided'
    end
  end
end
