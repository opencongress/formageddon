module Formageddon
  module ActsAsFormageddonRecipient

    ## Define ModelMethods
    module Base
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_formageddon_recipient
          has_many :formageddon_contact_steps,  :class_name => 'Formageddon::FormageddonContactStep', :as => :formageddon_recipient, :order => 'formageddon_contact_steps.step_number ASC', :dependent => :destroy
          has_many :formageddon_threads,  :class_name => 'Formageddon::FormageddonThread', :as => :formageddon_recipient, :order => 'formageddon_threads.created_at DESC'

          include Formageddon::ActsAsFormageddonRecipient::Base::InstanceMethods
        end
      end
      
      module InstanceMethods
        def execute_contact_steps(browser, letter, start_step = 1)
          remaining_steps = formageddon_contact_steps.where(['formageddon_contact_steps.step_number >= ?', start_step])

          # create a new delivery attempt
          delivery_attempt = letter.formageddon_delivery_attempts.create
          
          remaining_steps.each do |s|
            return unless s.execute(browser, { :letter => letter, :delivery_attempt => delivery_attempt })
          end
        end
        
        def formageddon_display_address
          ""
        end
        
        def formageddon_configured?
          not formageddon_contact_steps.empty?
        end
      end # InstanceMethods      
    end

  end
end