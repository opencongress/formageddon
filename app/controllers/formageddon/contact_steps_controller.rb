module Formageddon
  class ContactStepsController < ApplicationController
    before_filter :admin_check
    
    def new
      if params[:recipient_id].nil? or params[:recipient_type].nil?
        flash[:error] = "You must specify a recipient id and type to build steps!"
        redirect_to "/"
      end
      
      session[:formageddon_recipient_id] = params[:recipient_id]
      session[:formageddon_recipient_type] = params[:recipient_type]
      session[:formageddon_contact_step] = 1
      
      session[:formageddon_contact_steps] = []
      session[:formageddon_temp_data] = []
      
      @contact_step = FormageddonContactStep.new 
    end
    
    def create      
      if params[:back_button]
        session[:formageddon_contact_step] -= 1
        @contact_step = session[:formageddon_contact_steps][session[:formageddon_contact_step] - 1]
        
        render :action => 'new' if session[:formageddon_contact_step] == 1
        return
      else
        @contact_step = FormageddonContactStep.new(params[:formageddon_formageddon_contact_step])
        @contact_step.formageddon_recipient_id = session[:formageddon_recipient_id]
        @contact_step.formageddon_recipient_type = session[:formageddon_recipient_type]
        @contact_step.step_number = session[:formageddon_contact_step]
      end
      
      # check validity?
      
      session[:formageddon_contact_steps][session[:formageddon_contact_step]-1] = @contact_step
      session[:formageddon_temp_data][session[:formageddon_contact_step]-1] = params[:formageddon_temp_data]
      session[:formageddon_contact_step] += 1
      
      if params[:next_step] and params[:next_step] == 'true'
        browser = Mechanize.new
        
        # execute all the steps to get here
        session[:formageddon_contact_steps].each_with_index do |step, step_i|
          step.execute(browser, :letter => session[:formageddon_temp_data][step_i])        
        end
        
        @page = browser.page
        
        @contact_steps = []
        @form_imgs = []
        @page.forms.each_with_index do |form, form_i|
          contact_step = FormageddonContactStep.new
          contact_step.build_formageddon_form(:form_number => form_i)
          form.fields.each_with_index do |field, field_i|
            contact_step.formageddon_form.formageddon_form_fields.build(:name => field.name, :field_number => field_i)
          end
          @form_imgs[form_i] = @page.parser.css('form')[form_i].css('img')
          contact_step.formageddon_form.build_formageddon_form_captcha_image
          @contact_steps << contact_step
        end
      else
        session[:formageddon_contact_steps].each { |s| s.save }
                
        redirect_to :controller => 'contact_steps', :action => 'show', :recipient_id => session[:formageddon_recipient_id], :recipient_type => session[:formageddon_recipient_type]
        
        session[:formageddon_contact_steps] = session[:formageddon_contact_step] = session[:formageddon_recipient_id] = session[:formageddon_recipient_type] = nil
      end
    end
    
    def show
      unless params[:recipient_id].nil? and params[:recipient_type].nil?
        @contact_steps = FormageddonContactStep.where(["formageddon_recipient_id=? AND formageddon_recipient_type=?", params[:recipient_id], params[:recipient_type]]).order('step_number ASC')
      else
        @contact_steps = FormageddonContactStep.where(["id=?", params[:id]])
      end
    end
    
    
    protected

    def admin_check
      if Formageddon::configuration.admin_check_filter.nil?
        # automatically reject
        flash[:notice] = "Access denied."
        redirect_to '/'
        return
      else
        case Formageddon::configuration.admin_check_filter
        when String
        when Symbol
          self.send(Formageddon::configuration.admin_check_filter)
        when Proc
          Formageddon::configuration.admin_check_filter.call
        end
      end
    end
    
  end
end