require 'rails'

require 'formageddon'
require 'formageddon/configuration'
require 'formageddon/acts_as_formageddon_recipient/base'
require 'formageddon/acts_as_formageddon_sender/base'

require 'formageddon/incoming_email_fetcher'
require 'formageddon/incoming_email_handler'

module Formageddon
  class Railtie < Rails::Engine
    rake_tasks do
      load File.join(File.dirname(__FILE__), '../tasks/tasks.rake')
    end
    
    initializer 'formageddon.helper' do |app|
      ActionView::Base.send :include, FormageddonHelper
    end
    
    initializer 'formageddon.mechanize_extend' do |app|
      load File.join(File.dirname(__FILE__), 'mechanize_extend.rb')
    end
    
    initializer 'formageddon.acts_as_formageddon_recipient' do |app|
      ActiveRecord::Base.send :include, Formageddon::ActsAsFormageddonRecipient::Base
    end
    initializer 'formageddon.acts_as_formageddon_sender' do |app|
      ActiveRecord::Base.send :include, Formageddon::ActsAsFormageddonSender::Base
    end
    
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end
end