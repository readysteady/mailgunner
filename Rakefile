require 'rake/testtask'
require 'yard'

task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['spec/mailgunner/*_spec.rb']
  t.warning = true
end

YARD::Rake::YardocTask.new do |t|
  t.options << '--no-private'
end
