Gem::Specification.new do |s|
  s.name = 'mailgunner'
  s.version = '1.0.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'http://github.com/timcraft/mailgunner'
  s.description = 'A Ruby wrapper for the Mailgun API'
  s.summary = 'See description'
  s.files = Dir.glob('{lib,spec}/**/*') + %w(README.md mailgunner.gemspec)
  s.add_development_dependency('rake', '>= 0.9.3')
  s.add_development_dependency('mocha', '~> 0.10.3')
  s.add_development_dependency('faux', '~> 1.1.0')
  s.require_path = 'lib'
end
