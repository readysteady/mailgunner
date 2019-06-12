# 3.0.0

* Changed required_ruby_version to >= 2.5.0

* Added Mailgunner::Config class

  You can now configure options globally. For example:

      Mailgunner.configure do |config|
        config.api_host = 'api.eu.mailgun.net'
      end

  This may or may not be a breaking change, depending on how you are currently initializing client objects.

* Added Mailgunner::Struct class

  Return values are now instances of the Mailgunner::Struct class. You can access nested keys in various ways:

      response.items
      response['items']
      response[:items]
      response.to_h.dig('items')

  This may or may not be a breaking change, depending on how you are currently using return values.

* Added parsing of error messages in response bodies

* Removed Mailgunner::Client#get_stats method

* Removed Mailgunner::Client#parse_addresses method

* Changed Mailgunner::Client#validate_address to v4 endpoint

* Changed Mailgunner::Client#get_lists method to new endpoint

* Changed Mailgunner::Client#get_list_members method to new endpoint

* Added Mailgunner::Client#get_bulk_validations method

* Added Mailgunner::Client#create_bulk_validation method

* Added Mailgunner::Client#get_bulk_validation method

* Added Mailgunner::Client#cancel_bulk_validation method

* Added Mailgunner::Client#get_whitelists method

* Added Mailgunner::Client#get_whitelist method

* Added Mailgunner::Client#add_whitelist method

* Added Mailgunner::Client#delete_whitelist method

* Added Mailgunner::Client#get_tracking_settings method

* Added Mailgunner::Client#update_open_tracking_settings method

* Added Mailgunner::Client#update_click_tracking_settings method

* Added Mailgunner::Client#update_unsubscribe_tracking_settings method

# 2.6.0

* Added `api_host` option for EU region (thanks @drummerroma and @markoudev)

* Added Mailgunner::Client#get_all_ips method

* Added Mailgunner::Client#get_ip method

* Added Mailgunner::Client#get_ips method

* Added Mailgunner::Client#add_ip method

* Added Mailgunner::Client#delete_ip method

* Removed legacy campaign methods

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
