Gem::Specification.new do |s|
  s.name = 'mailgunner'
  s.version = '1.3.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'http://github.com/timcraft/mailgunner'
  s.description = 'A Ruby wrapper for the Mailgun API'
  s.summary = 'See description'
  s.files = Dir.glob('{lib,spec}/**/*') + %w(README.md mailgunner.gemspec)
  s.add_development_dependency('rake', '~> 10.1')
  s.add_development_dependency('webmock', '~> 1.18')
  s.add_development_dependency('mail', '~> 2.5')
  s.add_development_dependency('actionmailer', '~> 4.0')
  s.require_path = 'lib'
end
