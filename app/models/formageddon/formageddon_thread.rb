module Formageddon
  class FormageddonThread < ActiveRecord::Base
    belongs_to :formageddon_recipient, :polymorphic => true
    belongs_to :formageddon_sender, :polymorphic => true
    has_many :formageddon_letters, :order => 'created_at ASC'
    
    accepts_nested_attributes_for :formageddon_letters
    
    def sender_full_name
      "#{sender_first_name} #{sender_last_name}"
    end
    
    # sends the most current unsent letter
    def send_letter(browser)
      letter = formageddon_letters.last
      
      if letter
        recipient = letter.formageddon_thread.formageddon_recipient
      
        recipient.formageddon_contact_steps.each do |s|
          error = s.execute(browser, :letter => letter)
          return error unless error.nil?
        end

        return nil
      else
        return false
      end
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
  end
end