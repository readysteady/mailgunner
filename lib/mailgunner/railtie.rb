module Mailgunner
  class Railtie < Rails::Railtie
    config.before_initialize do
      require 'mailgunner/delivery_method'
    end
  end
end
