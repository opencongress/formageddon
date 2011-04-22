class ContactableObject < ActiveRecord::Base
  acts_as_formageddon_recipient
  
  def to_s
    name
  end
end
