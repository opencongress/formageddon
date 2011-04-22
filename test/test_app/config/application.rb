require File.expand_path('../boot', __FILE__)

require 'rails/all'
$:.unshift File.expand_path('../../../../lib', __FILE__)
require 'formageddon'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module TestApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
  
    #FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://www.example.com/no_form", :response => File.join(File.dirname(__FILE__), '..', 'testforms', 'no_forms.response'))
    FakeWeb.register_uri(:get, "http://www.example.com/1_form", :response => File.join(File.dirname(__FILE__), '..', 'testforms', 'one_form.response'))
    FakeWeb.register_uri(:post, "http://www.example.com/1_form_action", :response => File.join(File.dirname(__FILE__), '..', 'testforms', 'one_form_action.response'))
    FakeWeb.register_uri(:get, "http://www.example.com/2_form", :response => File.join(File.dirname(__FILE__), '..', 'testforms', 'two_forms.response'))
    FakeWeb.register_uri(:get, "http://www.example.com/multistep_1", :response => File.join(File.dirname(__FILE__), '..', 'testforms', 'multistep_1.response'))
    FakeWeb.register_uri(:post, "http://www.example.com/multistep_2", :response => File.join(File.dirname(__FILE__), '..', 'testforms', 'multistep_2.response'))
    FakeWeb.register_uri(:get, "http://www.example.com/one_form_captcha", :response => File.join(File.dirname(__FILE__), '..', 'testforms', 'one_form_captcha.response'))
  end
end
