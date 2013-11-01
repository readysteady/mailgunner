mailgunner
==========


A Ruby wrapper for the [Mailgun API](http://documentation.mailgun.net/api_reference.html).


Installation
------------

    $ gem install mailgunner


Quick start
-----------

```ruby
require 'mailgunner'

mailgun = Mailgunner::Client.new({
  domain: 'samples.mailgun.org',
  api_key: 'key-3ax6xnjp29jd6fds4gc373sgvjxteol0'
})

response = mailgun.get_stats(limit: 5)

if response.ok?
  # do something with response.object
else
  # handle client/server error
end
```


Environment variables
---------------------

Best practice for storing credentials for external services is to use environment
variables, as described by [12factor.net/config](http://www.12factor.net/config).
Mailgunner::Client defaults to extracting the domain and api_key values it needs
from the MAILGUN_API_KEY and MAILGUN_SMTP_LOGIN environment variables. These will
exist if you are using Mailgun on Heroku, or you can set them manually.


Email validation
----------------

If you only need [email validation](http://documentation.mailgun.com/api-email-validation.html),
you can instead use your Mailgun public key to authenticate like this:

```ruby
require 'mailgunner'

public_key = 'pubkey-5ogiflzbnjrljiky49qxsiozqef5jxp7'

mailgun = Mailgunner::Client.new(api_key: public_key)

response = mailgun.validate_address('john@gmail.com')
```
