load 'lib/tasks/tasks.rake'

begin
  require 'rspec/core/rake_task'
rescue LoadError
  begin
    gem 'rspec-rails', '>= 2.0.0'
    require 'rspec/core/rake_task'
  rescue LoadError
    puts "[govkit:] RSpec - or one of it's dependencies - is not available. Install it with: sudo gem install rspec-rails"
  end
end

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "formageddon"
    gem.summary = "Universal Form Contacter"
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*"]
    # other fields that would normally go in your gemspec
    # like authors, email and has_rdoc can also be included here

  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end
