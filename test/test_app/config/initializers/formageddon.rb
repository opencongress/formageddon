if defined? Formageddon
  Formageddon.configure do |config|
    config.admin_check_filter = :admin_required

    config.user_method = :current_user
    config.sender_user_mapping = { 
      :sender_email => :email 
    }
  end
end