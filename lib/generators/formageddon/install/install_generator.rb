require 'rails/generators'

module Formageddon
  class InstallGenerator < Rails::Generators::Base
    
    def initialize(*runtime_args)
      super
    end

    desc "Copies a config initializer to config/initializers/formageddon.rb"

    source_root File.join(File.dirname(__FILE__), 'templates')

    def copy_initializer_file
      copy_file 'formageddon.rb', File.join('config', 'initializers', 'formageddon.rb')
    end
  end
end