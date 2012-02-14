if Rails.env.development?
  require 'rspec/core/rake_task'
  require 'cucumber'
  require 'cucumber/rake/task'

  namespace :formageddon do
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = File.dirname(__FILE__) + '/../../spec/**/*_spec.rb'
      t.verbose = true
    end
  
    desc "Run the cucumber feature tests"
    Cucumber::Rake::Task.new(:features)
      
    desc "Hello World"
    task :hello_world do
      puts "Contact Government: Hello World"
    end
  end
end