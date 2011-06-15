module Formageddon
  class FormsController < ApplicationController
    unloadable
    
    ## must use!
    ##before_filter :admin_check
    
    def edit
      @formageddon_form = FormageddonForm.find(params[:id])
    end
    
    def update
      @formageddon_form = FormageddonForm.find(params[:id])

      if @formageddon_form.update_attributes(params[:formageddon_formageddon_form])
        redirect_to :controller => 'contact_steps', :action => 'show', :recipient_type => @formageddon_form.formageddon_contact_step.formageddon_recipient_type, 
                    :recipient_id => @formageddon_form.formageddon_contact_step.formageddon_recipient_id
      else
        flash[:error] = 'Error updating form!'
        redirect_to :action => 'edit', :id => @formageddon_form
      end
    end
  end
end