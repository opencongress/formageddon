if defined? Formageddon
  Formageddon.configure do |config|
    config.admin_check_filter = :admin_required

    config.user_method = :current_user
    config.sender_user_mapping = { 
      :sender_email => :email 
    }
    
    config.privacy_options = [
      ['Public -- Anyone', 'PUBLIC'], 
      ['Friends -- MyOC Friends Only', 'FRIENDS_ONLY'], 
      ['Private -- You Only', 'PRIVATE']
    ]
  end
end