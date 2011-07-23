if defined? Formageddon
  Formageddon.configure do |config|
    # admin_check_filter -- Method used by controllers to check is user has admin priviledges.
    config.admin_check_filter = :admin_required
    
    # user_method -- Method used by controllers to access the currently logged-in user.
    #                Usually 'current_user'.
    config.user_method = :current_user
    
    # sender_user_mapping -- Maps fields in the formageddon thread model to your
    #                        sender (usually user) model.
    config.sender_user_mapping = { :sender_email => :email }
  
    # privacy_options -- List of options for users composing messages. The second element is the
    #                    string that will be stored in the DB.
    config.privacy_options = [
      ['Public', 'PUBLIC'], 
      ['Private', 'PRIVATE']
    ]
    
    # reply_domain -- If not nil, will replace sender's email with a generated email address
    #                 at the specified domain to receive replies.
    config.reply_domain = nil
    config.incoming_email_config = {
      'server' => '',
      'username' => '',
      'password' => ''
    }
    
    config.tmp_captcha_dir = '/tmp/'
    
    config.default_params = {}
  end
end