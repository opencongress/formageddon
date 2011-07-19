module Formageddon
  class FormageddonLetter < ActiveRecord::Base
    belongs_to :formageddon_thread
    has_many :formageddon_delivery_attempts, :order => 'created_at ASC'
    
    attr_accessor :captcha_solution
    
    validates_presence_of :subject, :message => "You must enter a letter subject."
    validates_presence_of :message, :message => "You must enter some content in your message."
    
    def send_letter(options = {})
      recipient = formageddon_thread.formageddon_recipient
      
      if recipient.nil? or recipient.formageddon_contact_steps.empty?
        self.status = 'ERROR: Recipient not configured for message delivery!'
        self.save
        return false
      end
      
      browser = Mechanize.new
      
      case status
      when 'START', 'RETRY'
        return recipient.execute_contact_steps(browser, self)
      when 'TRYING_CAPTCHA', 'RETRY_STEP'
        attempt = formageddon_delivery_attempts.last
        
        if status == 'TRYING_CAPTCHA' and !(attempt.result == 'CAPTCHA_REQUIRED' or attempt.result == 'CAPTCHA_WRONG')
          # weird state, abort
          return false
        end
        
        browser = (attempt.result == 'CAPTCHA_WRONG') ? attempt.rebuild_browser(browser, false) : attempt.rebuild_browser(browser, true)
        
        if options[:captcha_solution]
          @captcha_solution = options[:captcha_solution]
        end
        
        return recipient.execute_contact_steps(browser, self, attempt.letter_contact_step)
      end      
    end

    
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
      when :captcha_solution, 'captcha_solution'
        return @captcha_solution
      else
        return self.formageddon_thread.send("sender_#{field.to_s}")
      end
    end
  end
end