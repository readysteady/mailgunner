require 'mail'
require 'action_mailer'
require_relative '../lib/mailgunner'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_with :mocha
end
