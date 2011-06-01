module Formageddon
  class Configuration
    attr_accessor :admin_check_filter
    attr_accessor :user_method
    attr_accessor :sender_user_mapping
    attr_accessor :reply_domain
    attr_accessor :privacy_options
    attr_accessor :incoming_email_config
    attr_accessor :tmp_captcha_dir
    
    def initialize
      @admin_check_filter = nil
      @user_method = nil
      @sender_user_mapping = {}
      @reply_domain = nil
      @privacy_options = []
      @incoming_email_config = {}
      @tmp_captcha_dir = nil
    end
  end

  class << self
    attr_accessor :configuration
  end

  # Configure Formageddon in config/initializers/formageddon.rb
  #
  # @example
  #   Formageddon.configure do |config|
  #     config.check_admin_filter = ''
  #   end
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end