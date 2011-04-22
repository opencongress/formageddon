module Formageddon
  module ActsAsFormageddonSender

    ## Define ModelMethods
    module Base
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_formageddon_sender
          has_many :formageddon_threads,  :class_name => 'Formageddon::FormageddonThread', :as => :formageddon_sender, :order => 'formageddon_threads.created_at DESC'

          include Formageddon::ActsAsFormageddonSender::Base::InstanceMethods
        end
      end
      
      module InstanceMethods
                
      end # InstanceMethods      
    end

  end
end