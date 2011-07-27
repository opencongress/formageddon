module Formageddon
  class DeliveryAttemptsController < FormageddonController
    
    before_filter :admin_check, :only => :edit

    def show
      letter_ids = params[:letter_ids]
      
      @finished = true
      @captcha_letters = []
      letter_ids.split(/,/).each do |letter_id|
        letter = Formageddon::FormageddonLetter.find(letter_id)
        
        unless (letter.status == 'SENT' || letter.status =~ /WARNING/ || letter.status =~ /ERROR/)
          if letter.updated_at < 60.seconds.ago
            letter.status = 'ERROR: Timeout trying to send'
          else
            @finished = false
        
            if letter.status == 'CAPTCHA_REQUIRED'
              @captcha_letters << letter
            end
          end
        end
      end

      if @finished and !session[:formageddon_after_send_url].blank?
        @to_url = session[:formageddon_after_send_url]
        session[:formageddon_after_send_url] = nil
        
        if @to_url =~ /\?/
          @to_url = "#{@to_url}&letter_ids=#{letter_ids}"
        else
          @to_url = "#{@to_url}?letter_ids=#{letter_ids}"
        end
        
        respond_to do |format|
          format.html { redirect_to @to_url }
          format.js
        end
      else
        respond_to do |format|
          format.html
          format.js
        end
      end
    end
    
    def create
      # check for captcha solutions
      unless params[:captcha_solution].nil?
        params[:captcha_solution].keys.each do |letter_id|
          letter = FormageddonLetter.find(letter_id)
          
          letter.status = 'TRYING_CAPTCHA'
          letter.save
          
          if defined? Delayed
            letter.delay.send_letter(:captcha_solution => params[:captcha_solution][letter_id])
          else
            letter.send_letter(:captcha_solution => params[:captcha_solution][letter_id])
          end
        end
        
        respond_to do |format|
          format.html {
            redirect_to :controller => 'delivery_attempts', :action => 'show', 
                        :letter_ids => params[:letter_ids]
          }
          format.js {
            redirect_to :controller => 'delivery_attempts', :action => 'show', :format => 'js', 
                        :letter_ids => params[:letter_ids]
          }
        end
        
      end
    end
    
    def edit
      @formageddon_delivery_attempt = Formageddon::FormageddonDeliveryAttempt.find(params[:id])
    end
  end
end