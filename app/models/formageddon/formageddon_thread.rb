module Formageddon
  class FormageddonThread < ActiveRecord::Base
    belongs_to :formageddon_recipient, :polymorphic => true
    belongs_to :formageddon_sender, :polymorphic => true
    has_many :formageddon_letters, :order => 'created_at ASC'
    
    accepts_nested_attributes_for :formageddon_letters

    validates_presence_of :formageddon_recipient_id, :message => "You must choose a recipient."
    
    validates_presence_of :sender_first_name, :message => "First name can't be blank."
    validates_presence_of :sender_last_name, :message => "Last name can't be blank."
    validates_presence_of :sender_address1, :message => "Address can't be blank."
    validates_presence_of :sender_email, :message => "Email address can't be blank."
    validates_presence_of :sender_city, :message => "City can't be blank."
    validates_presence_of :sender_zip5, :message => "Zip can't be blank."
    validates_presence_of :sender_phone, :message => "Phone number can't be blank."
    
    def sender_full_name
      "#{sender_first_name} #{sender_last_name}"
    end
        
    def prepare(options)
      letter = formageddon_letters.build

      if options[:user]
        user = options[:user]
        self.attributes.keys.each do |k|            
          if u_method = Formageddon::configuration.sender_user_mapping[k.to_sym]
            begin
              self.send("#{k}=", user.send(u_method))
            rescue
            end
          end
        end
      end
      
      if options[:subject]
        letter.subject = options[:subject]
      end
      
      if options[:message]
        letter.message = options[:message]
      end
    end
    
    def first_subject
      formageddon_letters.any? ? formageddon_letters.first.subject : nil
    end

    def first_message
      formageddon_letters.any? ? formageddon_letters.first.message : nil
    end
  end
end