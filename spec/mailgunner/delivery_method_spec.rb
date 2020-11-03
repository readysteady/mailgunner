require 'spec_helper'

RSpec.describe Mailgunner::DeliveryMethod do
  let(:domain) { 'samples.mailgun.org' }
  let(:api_key) { 'api_key_xxx' }
  let(:address) { 'user@example.com' }

  before do
    ActionMailer::Base.delivery_method = :mailgun
    ActionMailer::Base.mailgun_settings = {api_key: api_key, domain: domain}
  end

  class ExampleMailer < ActionMailer::Base
    default from: 'testing@localhost'

    def registration_confirmation(user)
      mail to: user[:email], subject: 'Welcome!', body: 'Hello!'
    end
  end

  it 'delivers the mail to mailgun in mime format' do
    uri = "https://api.mailgun.net/v3/#{domain}/messages.mime"

    stub_request(:post, uri).with(basic_auth: ['api', api_key])

    ExampleMailer.registration_confirmation(email: address).deliver_now
  end
end
