module Formageddon
  class FormageddonLetter < ActiveRecord::Base
    belongs_to :formageddon_thread
      
    def value_for(field)
      case field
      when :message, 'message'
        return self.message
      when :subject, 'subject'
        return self.subject
      when :issue_area, 'issue_area'
        return self.issue_area
      when :full_name, 'full_name'
        return "#{self.formageddon_thread.sender_first_name} #{self.formageddon_thread.sender_last_name}"
      else
        return self.formageddon_thread.send("sender_#{field.to_s}")
      end
    end
  end
end