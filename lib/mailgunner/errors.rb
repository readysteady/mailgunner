module Mailgunner
  class Error < StandardError; end

  class ClientError < Error; end

  class AuthenticationError < ClientError; end

  class ServerError < Error; end

  module NoDomainProvided
    def self.to_s
      raise Error, 'No domain provided'
    end
  end
end
