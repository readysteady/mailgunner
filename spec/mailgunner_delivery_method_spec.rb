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

    @base_url = "https://api:#@api_key@api.mailgun.net/v2"

    @address = 'user@example.com'

    ActionMailer::Base.delivery_method = :mailgun

    ENV['MAILGUN_API_KEY'] = @api_key

    ENV['MAILGUN_SMTP_LOGIN'] = "postmaster@#@domain"
  end

  it 'delivers the mail to mailgun in mime format' do
    stub_request(:post, "#@base_url/#@domain/messages.mime")

    ExampleMailer.registration_confirmation(email: @address).deliver
  end

  it 'raises an exception if the api returns an error' do
    stub_request(:post, "#@base_url/#@domain/messages.mime").to_return({
      status: 403,
      headers: {'Content-Type' => 'application/json'},
      body: '{"message": "Invalid API key"}'
    })

    proc { ExampleMailer.registration_confirmation(email: @address).deliver }.must_raise(Mailgunner::DeliveryFailed)
  end

  it 'allows the domain to be specified explicitly via the delivery method settings' do
    stub_request(:post, "#@base_url/app123.mailgun.org/messages.mime")

    ActionMailer::Base.mailgun_settings = {domain: 'app123.mailgun.org'}

    ExampleMailer.registration_confirmation(email: @address).deliver

    ActionMailer::Base.mailgun_settings = {}
  end
end
