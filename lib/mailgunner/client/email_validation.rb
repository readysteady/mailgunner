# frozen_string_literal: true

module Mailgunner
  class Client
    def validate_address(value)
      get('/v3/address/validate', query: {address: value})
    end

    def parse_addresses(values)
      get('/v3/address/parse', query: {addresses: Array(values).join(',')})
    end
  end
end
