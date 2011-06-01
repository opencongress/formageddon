module Formageddon
  class FormageddonContactStep < ActiveRecord::Base
    belongs_to :formageddon_recipient, :polymorphic => true
    has_one :formageddon_form, :dependent => :destroy
    
    accepts_nested_attributes_for :formageddon_form
    
    attr_accessor :error_msg, :captcha_image
    
    @@contact_fields = [ 
      :title, :first_name, :last_name, :email, :address1, :address2, :zip5, :zip4, :city, :state,                
      :phone, :issue_area, :subject, :message, :submit_button, :leave_blank, :captcha_solution
    ]
    def self.contact_fields
      @@contact_fields
    end
    
    def has_captcha?
      command =~ /submit_form/ && formageddon_form.has_captcha?
    end
    
    def execute(browser, options = {})
      raise "Browser is nil!" if browser.nil?
      delivery_attempt = options[:delivery_attempt]
      
      delivery_attempt.letter_contact_step = self.step_number unless delivery_attempt.nil?
      
      case self.command
      when /^visit::/
        command, url = self.command.split(/::/)
        
        begin
          browser.get(url)
        rescue 
          @error_msg = "ERROR: #{$!}"
          
          unless options[:letter].nil?
            letter = options[:letter]
            letter.status = delivery_attempt.result = @error_msg
            letter.save
            delivery_attempt.save
          end
          
          # save the browser state in the delivery attempt
          return false
        end
        
        return true
      when /^submit_form/
        raise "Must submit :letter to execute!" if options[:letter].nil?
        letter = options[:letter]
        
        delivery_attempt.save_before_browser_state(browser)
        
        if formageddon_form.has_captcha? and letter.captcha_solution.nil?
          letter.status = delivery_attempt.result = 'CAPTCHA_REQUIRED'
          letter.save
          delivery_attempt.save
          
          save_captcha_image(browser, letter)
          return false
        end
        
        form = browser.page.forms[formageddon_form.form_number]
        form.fields.each do |field|
          puts "TRYING FIELD: #{field.name}"
          ff = formageddon_form.formageddon_form_fields.select{|f| f.name == field.name }.first     

          unless ff.nil?
            if letter.kind_of? FormageddonLetter
            
              if ff.value == 'email' and not Formageddon::configuration.reply_domain.nil?
                field.value = "formageddon+#{letter.formageddon_thread.id}@#{Formageddon::configuration.reply_domain}"
              else
                field.value = letter.value_for(ff.value) unless ff.not_changeable?
              end
            
            # Hashes are used in form building
            elsif letter.kind_of? Hash
              field.value = letter[ff.value]
            end
          end
        end
        
        begin
          form.submit
        rescue 
          @error_msg = "ERROR: #{$!}"
          
          letter.status = delivery_attempt.status = @error_msg
          letter.save
          delivery_attempt.save
          
          # save the browser state in the delivery attempt
          delivery_attempt.save_after_browser_state(browser)
          
          return false
        end
        
        
        if (browser.page.parser.to_s =~ /#{formageddon_form.success_string}/).nil?
          puts "Here's the browser: #{browser.page.parser.to_s}"
          # save the browser state in the delivery attempt
          delivery_attempt.save_after_browser_state(browser)
          
          if letter.status == 'TRYING_CAPTCHA'
            # assume that the captcha was wrong?
            letter.status = 'CAPTCHA_REQUIRED'
            save_captcha_image(browser, letter)
            
            delivery_attempt.result = 'CAPTCHA_WRONG'
            delivery_attempt.save
          else
            letter.status = delivery_attempt.status = "WARNING: Confirmation message not found."
          end
          
          letter.save
          delivery_attempt.save
          
          
          return false
        else
          letter.status = 'SENT'
          delivery_attempt.result = 'SUCCESS'
          letter.save
          delivery_attempt.save
          
          return true
        end
      end
    end
    
    def save_captcha_image(browser, letter)
      captcha_node = browser.page.parser.css(formageddon_form.formageddon_form_captcha_image.css_selector).first
      if captcha_node
        @captcha_image = browser.page.image_urls.select{ |ui| ui =~ /#{Regexp.escape(captcha_node.attributes['src'].value)}/ }.first
      end
      puts "captcha node: #{captcha_node} / captcha image: #{@captcha_image}"
      
      unless @captcha_image.blank?
        # turn following into method
        uri = URI.parse(@captcha_image)
        Net::HTTP.start(uri.host, uri.port) { |http|
          resp = http.get(uri.path)
          open("#{Formageddon::configuration.tmp_captcha_dir}#{letter.id}.jpg", "wb") { |file|
            file.write(resp.body)
           }
        }
      end
    end
  end
end