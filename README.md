# mailgunner

[![Gem Version](https://badge.fury.io/rb/mailgunner.svg)](https://badge.fury.io/rb/mailgunner) [![Build Status](https://api.travis-ci.org/readysteady/mailgunner.svg?branch=master)](https://travis-ci.org/readysteady/mailgunner)


Ruby client for the [Mailgun API](https://documentation.mailgun.com/en/latest/api_reference.html).


## Installation

    $ gem install mailgunner


## Quick start

```ruby
require 'mailgunner'

mailgun = Mailgunner::Client.new({
  domain: 'samples.mailgun.org',
  api_key: 'key-3ax6xnjp29jd6fds4gc373sgvjxteol0'
})

response = mailgun.get_domains

response['items'].each do |item|
  p item.values_at('id', 'name')
end
```


## Storing the API key

Best practice for credentials is to [store them in the environment](https://www.12factor.net/config#store_config_in_the_environment).
`Mailgunner::Client` defaults to extracting the domain and api_key values it needs
from the `MAILGUN_API_KEY` and `MAILGUN_SMTP_LOGIN` environment variables—these will
exist if you are using Mailgun on Heroku, or you can set them manually.


## ActionMailer integration

Mailgunner integrates with [ActionMailer](https://rubygems.org/gems/actionmailer).
If you are using Rails, you can use Mailgunner to send mail via Mailgun by adding
the following line to `config/environments/production.rb`:

```ruby
config.action_mailer.delivery_method = :mailgun
```

If for some reason you can't set the required ENV variables, you can configure Mailgunner
through ActionMailer settings:

```ruby
config.action_mailer.mailgun_settings = {
  domain: 'test.com',
  api_key: 'your-api-key'
}
```

Outside of Rails you can set `ActionMailer::Base.delivery_method` directly.


## Specifying the region

Mailgun offers both a US and EU region to send your e-mail from. Mailgunner uses
the US region by default. If you wish to use the EU region set the `api_host`
config option like so:

```ruby
mailgun = Mailgunner::Client.new({
  domain: 'eu.samples.mailgun.org',
  api_key: 'key-3ax6xnjp29jd6fds4gc373sgvjxteol0',
  api_host: 'api.eu.mailgun.net'
})
```


## Email validation

If you only need to use Mailgun's [email address validation service](http://documentation.mailgun.com/api-email-validation.html),
you can instead use your Mailgun public key to authenticate like this:

```ruby
require 'mailgunner'

public_key = 'pubkey-5ogiflzbnjrljiky49qxsiozqef5jxp7'

mailgun = Mailgunner::Client.new(api_key: public_key)

response = mailgun.validate_address('john@gmail.com')
```
