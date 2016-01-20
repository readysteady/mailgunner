Gem::Specification.new do |s|
  s.name = 'mailgunner'
  s.version = '2.2.1'
  s.license = 'LGPL-3.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'http://github.com/timcraft/mailgunner'
  s.description = 'Ruby client for the Mailgun API'
  s.summary = 'Ruby client for the Mailgun API'
  s.files = Dir.glob('{lib,spec}/**/*') + %w(LICENSE.txt README.md mailgunner.gemspec)
  s.required_ruby_version = '>= 1.9.3'
  s.add_development_dependency('rake', '~> 10.1')
  s.add_development_dependency('webmock', '~> 1.18')
  s.add_development_dependency('mail', '~> 2.5')
  s.add_development_dependency('actionmailer', '~> 4.0')
  s.require_path = 'lib'
end
