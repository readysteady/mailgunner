# frozen_string_literal: true

module Mailgunner
  class Client
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
  end
end
