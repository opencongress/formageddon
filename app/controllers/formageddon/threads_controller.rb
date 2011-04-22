module Formageddon
  class ThreadsController < ApplicationController
    def new
      @contact_steps = FormageddonContactStep.where(["formageddon_recipient_id=? AND formageddon_recipient_type=?",
                                                     params[:recipient_id], params[:recipient_type]])
      
      if @contact_steps.empty?
        flash[:error] = "Contact process has not been configure for recipient."
        redirect_to "/"
      end
      
      recipient = Object.const_get(params[:recipient_type]).find_by_id(params[:recipient_id])
      
      @formageddon_thread = FormageddonThread.new
      @formageddon_thread.formageddon_recipient = recipient
      @formageddon_thread.formageddon_letters.build
      
      # check for user
      begin
        user = self.send(Formageddon::configuration.user_method)
        if user
          @formageddon_thread.attributes.keys.each do |k|            
            if u_method = Formageddon::configuration.sender_user_mapping[k.to_sym]
              begin
                @formageddon_thread.send("#{k}=", user.send(u_method))
              rescue
              end
            end
          end
        end
      rescue
      end
    end

    def create
      @formageddon_thread = FormageddonThread.new(params[:formageddon_formageddon_thread])
      begin
        user = self.send(Formageddon::configuration.user_method)
        if user
          @formageddon_thread.formageddon_sender = user
        end
      rescue
      end
      
      if @formageddon_thread.save
        @formageddon_thread.formageddon_letters.first.update_attribute(:status, 'UNSENT')
        @formageddon_thread.formageddon_letters.first.update_attribute(:direction, 'TO_RECIPIENT')
        
        browser = Mechanize.new
        
        # now queue or send the email
        
        # for now disabling sending
        if params[:after_send_url]
          ## REFACTOR
          redirect_to params[:after_send_url] + "?thread_id=#{@formageddon_thread.id}"
        else
          redirect_to formageddon_formageddon_thread_path(@formageddon_thread)
        end
        return
        
        
        
        
        unless error = @formageddon_thread.send_letter(browser)
          flash[:notice] = 'Your letter was sent!'
          redirect_to '/'
        else
          puts "LAST STATUS #{@formageddon_thread.formageddon_letters.last.status}"
          
          if @formageddon_thread.formageddon_letters.last.status == 'CAPTCHA_REQUIRED'
          
            flash.now[:notice] = 'This form requires a captcha solution.'
            
            @formageddon_thread.formageddon_recipient.formageddon_contact_steps.each do |step|
              puts "STEP CAP: #{step.captcha_image}"
              @captcha_image = error
            end
            
            render 'captcha_form'
          else
            flash[:error] = 'There was an unknown error sending your letter.'
            
            redirect_to '/'
          end
        end      
      else
      end
    end
    
    def show
      @formageddon_thread = FormageddonThread.find(params[:id])
    end
  end
end