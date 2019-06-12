# frozen_string_literal: true

module Mailgunner
  class Struct
    def initialize(hash = nil)
      @hash = hash || {}
    end

    def [](key)
      @hash[key.to_s]
    end

    def []=(key, value)
      @hash[key] = value
    end

    def to_h
      @hash
    end

    def ==(other)
      other.is_a?(self.class) && other.to_h == @hash
    end

    def respond_to_missing?(name, include_all)
      @hash.key?(name.to_s)
    end

    def method_missing(name, *args)
      return @hash[name.to_s] if @hash.key?(name.to_s)

      super
    end

    def pretty_print(q)
      q.object_address_group(self) do
        q.seplist(@hash, lambda { q.text ',' }) do |key, value|
          q.breakable
          q.text key.to_s
          q.text '='
          q.group(1) {
            q.breakable ''
            q.pp value
          }
        end
      end
    end
  end
end
