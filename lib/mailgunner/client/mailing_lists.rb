# frozen_string_literal: true

module Mailgunner
  class Client
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
  end
end
