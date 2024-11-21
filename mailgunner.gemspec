require_relative './lib/mailgunner/version'

Gem::Specification.new do |s|
  s.name = 'mailgunner'
  s.version = Mailgunner::VERSION
  s.license = 'LGPL-3.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Tim Craft']
  s.email = ['mail@timcraft.com']
  s.homepage = 'https://github.com/readysteady/mailgunner'
  s.description = 'Ruby client for the Mailgun API'
  s.summary = 'Ruby client for the Mailgun API'
  s.files = Dir.glob('lib/**/*.rb') + %w(CHANGES.md LICENSE.txt README.md mailgunner.gemspec)
  s.required_ruby_version = '>= 2.5.0'
  s.require_path = 'lib'
  s.metadata = {
    'homepage' => 'https://github.com/readysteady/mailgunner',
    'source_code_uri' => 'https://github.com/readysteady/mailgunner',
    'bug_tracker_uri' => 'https://github.com/readysteady/mailgunner/issues',
    'changelog_uri' => 'https://github.com/readysteady/mailgunner/blob/main/CHANGES.md'
  }
  s.add_dependency 'uri', '~> 1'
end
