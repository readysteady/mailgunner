# frozen_string_literal: true
require 'uri'

module Mailgunner
  module Params
    def self.encode(params)
      params.flat_map { |k, vs| Array(vs).map { |v| "#{escape(k)}=#{escape(v)}" } }.join('&')
    end

    def self.escape(value)
      URI.encode_uri_component(value)
    end
  end
end
