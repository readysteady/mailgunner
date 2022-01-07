# mailgunner

![Gem Version](https://badge.fury.io/rb/mailgunner.svg)
![Test Status](https://github.com/readysteady/mailgunner/actions/workflows/test.yml/badge.svg)


Ruby client for the [Mailgun API](https://documentation.mailgun.com/en/latest/api_reference.html).


## Installation

    $ gem install mailgunner


## Usage

```ruby
require 'mailgunner'

Mailgunner.configure do |config|
  config.domain = 'samples.mailgun.org'
  config.api_key = 'key-3ax6xnjp29jd6fds4gc373sgvjxteol0'
end

mailgun = Mailgunner::Client.new

mailgun.get_domains.items.each do |item|
  puts "#{item.id} #{item.name}"
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

Mailgun offers both a US and EU region to send your email from. Mailgunner uses
the US region by default. If you wish to use the EU region set the `api_host`
config option like so:

```ruby
Mailgunner.configure do |config|
  config.api_host = 'api.eu.mailgun.net'
end
```
