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
      
      begin
        save_states = options[:save_states].nil? ? true : options[:save_states]
      
        if save_states
          delivery_attempt = options[:delivery_attempt]
          delivery_attempt.letter_contact_step = self.step_number unless delivery_attempt.nil?
        end
      
        case self.command
        when /^visit::/
          command, url = self.command.split(/::/)
        
          begin
            browser.get(url)
          rescue Timeout::Error
            save_after_error($!, options[:letter], delivery_attempt, save_states)
          
            return false
          rescue 
            save_after_error($!, options[:letter], delivery_attempt, save_states)
          
            return false
          end
        
          return true
        when /^submit_form/
          raise "Must submit :letter to execute!" if options[:letter].nil?
          letter = options[:letter]
        
          delivery_attempt.save_before_browser_state(browser) if save_states
        
          if formageddon_form.has_captcha? and letter.captcha_solution.nil?
            letter.status = 'CAPTCHA_REQUIRED'
            letter.save
          
            if save_states
               delivery_attempt.result = 'CAPTCHA_REQUIRED'
               delivery_attempt.save
            end
          
            save_captcha_image(browser, letter)
            return false
          end
        
          form = browser.page.forms[formageddon_form.form_number]
          form.fields.each_with_index do |field, field_index|
            puts "TRYING FIELD: #{field.name}"
            if formageddon_form.use_field_names?
              ff = formageddon_form.formageddon_form_fields.select{|f| f.name == field.name }.first     
            else
              ff = formageddon_form.formageddon_form_fields[field_index]
            end
          
            unless ff.nil?
              if letter.kind_of? FormageddonLetter
            
                if ff.value == 'email' and not Formageddon::configuration.reply_domain.nil?
                  field.value = "formageddon+#{letter.formageddon_thread.id}@#{Formageddon::configuration.reply_domain}"
                else
                  field.value = letter.value_for(ff.value) unless ff.not_changeable?
                end
            
              # Hashes are used in form building
              elsif letter.kind_of? Hash
                puts "FILLING #{field.name} with #{letter[ff.value]}"
                field.value = letter[ff.value]
              end
            end
          end
        
          begin
            form.submit
          rescue Timeout::Error
            save_after_error($!, options[:letter], delivery_attempt, save_states)

            delivery_attempt.save_after_browser_state(browser) if save_states
          
            return false
          rescue 
            save_after_error($!, options[:letter], delivery_attempt, save_states)

            delivery_attempt.save_after_browser_state(browser) if save_states
           
            return false
          end
        
          if formageddon_form.success_string.blank?
            if letter.kind_of? Formageddon::FormageddonLetter
              letter.status = 'WARNING: Confirmation message is blank. Unable to confirm delivery.'
              letter.save
            end
          
            if save_states
              delivery_attempt.save_after_browser_state(browser)

              delivery_attempt.result = 'WARNING: Confirmation message is blank. Unable to confirm delivery.'
              delivery_attempt.save            
            end
          
            return true
          elsif (browser.page.parser.to_s =~ /#{formageddon_form.success_string}/).nil?
            # save the browser state in the delivery attempt
            delivery_attempt.save_after_browser_state(browser) if save_states
          
            if letter.status == 'TRYING_CAPTCHA'
              # assume that the captcha was wrong?
              letter.status = 'CAPTCHA_REQUIRED'
              save_captcha_image(browser, letter)
            
              if save_states
                delivery_attempt.result = 'CAPTCHA_WRONG'
                delivery_attempt.save
              end
            else
              letter.status = "WARNING: Confirmation message not found."
            
              delivery_attempt.result = "WARNING: Confirmation message not found." if save_states
            end
          
            letter.save
            delivery_attempt.save if save_states
          
          
            return false
          else
            if letter.kind_of? Formageddon::FormageddonLetter
              letter.status = 'SENT'
              letter.save
            end
          
            if save_states
              delivery_attempt.result = 'SUCCESS'
              delivery_attempt.save
            
              # save on success for now, just in case we start getting false positives here
              delivery_attempt.save_after_browser_state(browser)
            end
          
            return true
          end
        end
      rescue
        if letter.kind_of? Formageddon::FormageddonLetter
          letter.status = "ERROR: #{$!}"
          letter.save
        end
      
        if save_states
          delivery_attempt.result = "ERROR: #{$!}"
          delivery_attempt.save        
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
    
    def save_after_error(ex, letter = nil, delivery_attempt = nil, save_states = true)
      @error_msg = "ERROR: #{ex}"
      
      unless letter.nil?
        if letter.kind_of? Formageddon::FormageddonLetter
          letter.status = @error_msg
          letter.save
        end
        
        if save_states
          delivery_attempt.result = @error_msg
          delivery_attempt.save
        end
      end
    end
  end
end