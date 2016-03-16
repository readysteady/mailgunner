module Mailgunner
  class Railtie < Rails::Railtie
    initializer 'mailgunner', before: 'action_mailer.set_configs' do
      ActiveSupport.on_load(:action_mailer) do
        require 'mailgunner/delivery_method'
      end
    end
  end
end
