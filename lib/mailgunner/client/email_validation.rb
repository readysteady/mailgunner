# frozen_string_literal: true

module Mailgunner
  class Client
    def validate_address(value)
      get('/v4/address/validate', query: {address: value})
    end

    def get_bulk_validations
      get('/v4/address/validate/bulk')
    end

    def create_bulk_validation(list_id)
      post("/v4/address/validate/bulk/#{escape list_id}")
    end

    def get_bulk_validation(list_id)
      get("/v4/address/validate/bulk/#{escape list_id}")
    end

    def cancel_bulk_validation(list_id)
      delete("/v4/address/validate/bulk/#{escape list_id}")
    end
  end
end
