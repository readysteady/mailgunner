require 'rake/testtask'

task :default => :spec

Rake::TestTask.new(:spec) do |t|
  t.test_files = FileList['spec/mailgunner/*_spec.rb']
  t.warning = true
end
