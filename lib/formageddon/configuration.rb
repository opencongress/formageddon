module Formageddon
  class Configuration
    attr_accessor :admin_check_filter
    attr_accessor :user_method
    attr_accessor :sender_user_mapping
    
    def initialize
      @admin_check_filter = nil
      @user_method = nil
      @sender_user_mapping = {}
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