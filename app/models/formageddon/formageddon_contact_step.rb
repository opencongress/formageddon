module Formageddon
  class FormageddonContactStep < ActiveRecord::Base
    belongs_to :formageddon_recipient, :polymorphic => true
    has_one :formageddon_form, :dependent => :destroy
    
    accepts_nested_attributes_for :formageddon_form
    
    attr_accessor :error_msg, :captcha_image
    
    @@contact_fields = [ 
      :title, :first_name, :last_name, :email, :address1, :address2, :zip5, :zip4, :city, :state, :state_house,               
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
      
      Rails.logger.debug "Executing Contact Step ##{self.step_number} for #{self.formageddon_recipient}..."
      
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
          
            begin
              save_captcha_image(browser, letter)
            rescue Timeout::Error
              save_after_error("Saving captcha: #{$!}", options[:letter], delivery_attempt, save_states)

              delivery_attempt.save_after_browser_state(browser) if save_states
            end
            return false
          end
        
          form = browser.page.forms[formageddon_form.form_number]
          
          raise "Form is nil! Problem with config?" if form.nil?
          
          form.fields.each_with_index do |field, field_index|
            if formageddon_form.use_field_names?
              ff = formageddon_form.formageddon_form_fields.select{|f| f.name == field.name }.first     
            else
              ff = formageddon_form.formageddon_form_fields[field_index]
            end
          
            unless ff.nil?
              if letter.kind_of? FormageddonLetter
            
                if ff.value == 'email' and not Formageddon::configuration.reply_domain.nil?
                  field.value = "formageddon+#{letter.formageddon_thread.id}@#{Formageddon::configuration.reply_domain}"
                elsif ff.value == 'get_response'
                  field.value = 'Yes'
                elsif ff.value == 'issue_area'
                  if field.kind_of?(Mechanize::Form::SelectList)
                    option_field = field.options_with(:value => /other|general/i).first
                    
                    if option_field
                      option_field.select
                    else
                      # select a random one.  not ideal.
                      field.options[rand(field.options.size-1)+1].select
                    end
                  else
                    field.value = 'Other'
                  end
                elsif ff.value == 'state_house'
                  state = State.find_by_abbreviation(letter.value_for('state'))
                  
                  field.value = "#{state.abbreviaion}#{state.name}"
                else
                  field.value = letter.value_for(ff.value) unless ff.not_changeable?
                end
            
              # Hashes are used in form building
              elsif letter.kind_of? Hash
                field.value = letter[ff.value]
              end
            end
          end
        
          # check to see if there are any default params to force
          unless Formageddon::configuration.default_params.empty?
            Formageddon::configuration.default_params.keys.each do |k|
              field = form.field_with(:name => k)
              if field
                field.value = Formageddon::configuration.default_params[k]
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
          
          puts "PAGE::::::#{browser.page.parser.to_s}"
        
          if ((!formageddon_form.success_string.blank? and (browser.page.parser.to_s =~ /#{formageddon_form.success_string}/)) or generic_confirmation?(browser.page.parser.to_s))
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
            
          elsif formageddon_form.success_string.blank?
            formageddon_form.success_string.blank? and !generic_confirmation?(browser.page.parser.to_s)
             
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
          else 
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
    
    def generic_confirmation?(content)
      if content =~ /thank you/i or content =~ /message sent/
        return true
      end
      
      return false
    end
  end
end