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
  end
end
