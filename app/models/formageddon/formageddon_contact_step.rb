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
      
      case self.command
      when /^visit::/
        command, url = self.command.split(/::/)
        browser.get(url)
        
        ## error hanlding
        
        return nil  
      when /^submit_form/
        raise "Must submit :letter to execute!" if options[:letter].nil?
        letter = options[:letter]
        
        if formageddon_form.has_captcha? and options[:captcha_solution].nil?
          letter.status = 'CAPTCHA_REQUIRED'
          letter.save
          
          @error_msg = 'Captcha Required'
          #puts "getting selector: #{formageddon_form.formageddon_form_captcha_image.css_selector}"
          captcha_node = browser.page.parser.css(formageddon_form.formageddon_form_captcha_image.css_selector).first
          #puts "captcha node: #{captcha_node.inspect}"
          if captcha_node
            return browser.page.image_urls.select{ |ui| ui =~ /#{Regexp.escape(captcha_node.attributes['src'].value)}/ }.first
          end
          return nil
        end
        
        form = browser.page.forms[formageddon_form.form_number]
        form.fields.each do |field|
          ff = formageddon_form.formageddon_form_fields.select{|f| f.name == field.name }.first     

          if letter.kind_of? FormageddonLetter
            
            if ff.value == 'email' and not Formageddon::configuration.reply_domain.nil?
              field.value = "formageddon-#{letter.formageddon_thread.id}@#{Formageddon::configuration.reply_domain}"
            else
              field.value = letter.value_for(ff.value) unless ff.nil? or ff.not_changeable?
            end
            
          # Hashes are used in form building
          elsif letter.kind_of? Hash
            field.value = letter[ff.value]
          end
        end
        form.submit
        
        return nil #(browser.page.parser.to_s =~ /#{formageddon_form.success_string}/).nil? ? false : true
      end
    end
  end
end