# 2.5.0

  * Fixed compatibility with mail v2.6.6+ (#13)

  * Added Mailgunner::Client#get_webhooks method

  * Added Mailgunner::Client#get_webhook method

  * Added Mailgunner::Client#add_webhook method

  * Added Mailgunner::Client#update_webhook method

  * Added Mailgunner::Client#delete_webhook method

  * Added Mailgun::AuthenticationError exception class

  * Added Mailgun::ClientError exception class

  * Added Mailgun::ServerError exception class

# 2.4.0

  * Fixed Rails load order issue when specifying mailgun_settings (#10)

  * Added Mailgunner::Client#get_connection_settings method

  * Added Mailgunner::Client#update_connection_settings method

  * Added Mailgunner::Client#get_tags method

  * Added Mailgunner::Client#get_tag method

  * Added Mailgunner::Client#update_tag method

  * Added Mailgunner::Client#get_tag_stats method

  * Added Mailgunner::Client#delete_tag method

  * Added Mailgunner::Client#delete_bounces method

# 2.3.0

  * Added Mailgunner::Client#get_total_stats method

  * Deprecated Mailgunner::Client#get_stats method

  * Removed Mailgunner::Client#get_list_stats method

# 2.2.2

  * Fixed cc and bcc recipients not included in multipart sends (#9)

# 2.2.1

  * Fixed Rails load order issue (#8)

# 2.2.0

  * Added Mailgunner::Client#get_message method

  * Added Mailgunner::Client#get_mime_message method

  * Added Mailgunner::Client#delete_message method

  * Updated API version prefix from v2 to v3

# 2.1.0

  * Mailgunner::DeliveryMethod can now be used with Mail directly

  * An exception is now raised when calling domain methods if the domain is not provided

  * The api_key option can now be specified in ActionMailer::Base.mailgun_settings

# 2.0.0

  * Removed deprecated :json option

  * Removed Mailgunner::Response class in favour of using exceptions to signal errors

  * Added Mailgunner::Client#delete_domain method

  * Added Mailgunner::Client methods for managing SMTP credentials

# 1.3.0

  * Added [ActionMailer](https://rubygems.org/gems/actionmailer) integration

  * Added Mailgunner::Client#send_mime method for sending [mail](https://rubygems.org/gems/mail) objects in MIME format

  * Fixed default behaviour to allow for nil domain

  * Removed deprecated Mailgunner::Client#get_log method

  * Removed deprecated mailbox methods

  * Removed deprecated json accessor methods

# 1.2.0

  * Added methods for the new [Email Validation endpoint](http://documentation.mailgun.com/api-email-validation.html)

  * Added Mailgunner::Client#get_events method for the new [Events API endpoint](http://documentation.mailgun.com/api-events.html)

  * Deprecated the Mailgunner::Client#get_log method (use Mailgunner::Client#get_events instead)

# 1.1.0

  * Fixed use of insecure JSON.load

  * Deprecated the mailbox methods (legacy Mailgun feature)

  * Deprecated the :json option and associated accessor methods

# 1.0.0

  * First version!
