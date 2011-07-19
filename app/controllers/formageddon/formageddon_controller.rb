module Formageddon
  class FormageddonController < ApplicationController
  
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