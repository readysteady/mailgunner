module Mailgunner
  # @private
  class Railtie < Rails::Railtie
    initializer 'mailgunner.configure_rails_initialization', before: 'action_mailer.set_configs' do
      require 'mailgunner/delivery_method'
    end
  end
end
