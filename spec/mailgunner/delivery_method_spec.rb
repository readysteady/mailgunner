require 'minitest/autorun'
require 'webmock/minitest'
require 'action_mailer'
require 'mailgunner'
require 'mailgunner/delivery_method'

class ExampleMailer < ActionMailer::Base
  default from: 'testing@localhost'

  def registration_confirmation(user)
    mail to: user[:email], subject: 'Welcome!', body: 'Hello!'
  end
end

describe 'Mailgunner::DeliveryMethod' do
  before do
    @api_key = 'xxx'

    @domain = 'samples.mailgun.org'

    @base_url = 'https://api.mailgun.net/v3'

    @auth = ['api', @api_key]

    @address = 'user@example.com'

    ActionMailer::Base.delivery_method = :mailgun

    ActionMailer::Base.mailgun_settings = {api_key: @api_key, domain: @domain}
  end

  it 'delivers the mail to mailgun in mime format' do
    stub_request(:post, "#@base_url/#@domain/messages.mime").with(basic_auth: @auth)

    ExampleMailer.registration_confirmation(email: @address).deliver_now
  end
end
