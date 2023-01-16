source 'https://rubygems.org'

gem 'rspec-core', '~> 3'
gem 'rspec-expectations', '~> 3'
gem 'webmock', '~> 3'
gem 'mail', '~> 2'
gem 'actionmailer', '~> 6'
gem 'mocha', '~> 2'
gem 'yard', '~> 0.9'

platforms :ruby do
  gem 'redcarpet', '~> 3'
end

# https://github.com/mikel/mail/pull/1439
if Gem.ruby_version >= Gem::Version.new('3.1.0')
  gem 'net-smtp'
end
