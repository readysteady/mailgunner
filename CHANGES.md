# [v2.2.0](https://github.com/timcraft/mailgunner/tree/v2.2.0) (2015-04-06)

  * Added Mailgunner::Client#get_message method

  * Added Mailgunner::Client#get_mime_message method

  * Added Mailgunner::Client#delete_message method

  * Updated API version prefix from v2 to v3

# [v2.1.0](https://github.com/timcraft/mailgunner/tree/v2.1.0) (2015-01-27)

  * Mailgunner::DeliveryMethod can now be used with Mail directly

  * An exception is now raised when calling domain methods if the domain is not provided

  * The api_key option can now be specified in ActionMailer::Base.mailgun_settings

# [v2.0.0](https://github.com/timcraft/mailgunner/tree/v2.0.0) (2014-07-29)

  * Removed deprecated :json option

  * Removed Mailgunner::Response class in favour of using exceptions to signal errors

  * Added Mailgunner::Client#delete_domain method

  * Added Mailgunner::Client methods for managing SMTP credentials

# [v1.3.0](https://github.com/timcraft/mailgunner/tree/v1.3.0) (2013-11-03)

  * Added [ActionMailer](https://rubygems.org/gems/actionmailer) integration

  * Added Mailgunner::Client#send_mime method for sending [mail](https://rubygems.org/gems/mail) objects in MIME format

  * Fixed default behaviour to allow for nil domain

  * Removed deprecated Mailgunner::Client#get_log method

  * Removed deprecated mailbox methods

  * Removed deprecated json accessor methods

# [v1.2.0](https://github.com/timcraft/mailgunner/tree/v1.2.0) (2013-09-01)

  * Added methods for the new [Email Validation endpoint](http://documentation.mailgun.com/api-email-validation.html)

  * Added Mailgunner::Client#get_events method for the new [Events API endpoint](http://documentation.mailgun.com/api-events.html)

  * Deprecated the Mailgunner::Client#get_log method (use Mailgunner::Client#get_events instead)

# [v1.1.0](https://github.com/timcraft/mailgunner/tree/v1.1.0) (2013-04-01)

  * Fixed use of insecure JSON.load

  * Deprecated the mailbox methods (legacy Mailgun feature)

  * Deprecated the :json option and associated accessor methods

# [v1.0.0](https://github.com/timcraft/mailgunner/tree/v1.0.0) (2013-01-02)

  * First version!
