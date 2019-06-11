# frozen_string_literal: true

module Mailgunner
  class Client
    def get_routes(params = PARAMS)
      get('/v3/routes', query: params)
    end

    def get_route(id)
      get("/v3/routes/#{escape id}")
    end

    def add_route(attributes = ATTRIBUTES)
      post('/v3/routes', attributes)
    end

    def update_route(id, attributes = ATTRIBUTES)
      put("/v3/routes/#{escape id}", attributes)
    end

    def delete_route(id)
      delete("/v3/routes/#{escape id}")
    end
  end
end
