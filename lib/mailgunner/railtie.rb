module Mailgunner
  class Railtie < Rails::Railtie
    initializer 'mailgunner', before: 'action_mailer.set_configs' do
      require 'mailgunner/delivery_method'
    end
  end
end
