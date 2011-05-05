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