module Mailgunner
  class Railtie < Rails::Railtie
    initializer 'mailgunner' do
      ActiveSupport.on_load(:action_mailer) do
        require 'mailgunner/delivery_method'
      end
    end
  end
end
