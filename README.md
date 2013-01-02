A Ruby wrapper for the [Mailgun API](http://documentation.mailgun.net/api_reference.html)
=========================================================================================


Installation
------------

    $ gem install mailgunner


Quick Start
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


Alternative JSON Implementations
--------------------------------

Mailgunner::Client defaults to using the "json" library which is available
in the Ruby 1.9 standard library, and as a gem for Ruby 1.8. You can specify
an alternative implementation using the json option when constructing a client
object. For example, to use [multi_json](https://rubygems.org/gems/multi_json):

```ruby
mailgun = Mailgunner::Client.new(:json => MultiJson)
```


Environment Variables
---------------------

Best practice for storing credentials for external services is to use environment
variables, as described by [12factor.net/config](http://www.12factor.net/config).

Mailgunner::Client defaults to extracting the domain and api_key values it needs
from the MAILGUN_API_KEY and MAILGUN_SMTP_LOGIN environment variables. These will
exist if you are using Mailgun on Heroku, or you can set them manually.

