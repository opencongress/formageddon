class ApplicationController < ActionController::Base  
  protect_from_forgery
  
  #before_filter :dump_session
  
  def admin_required
    unless current_user.try(:admin?)
      flash[:error] = 'Access denied!'
      redirect_to '/'
    end
  end

  def dump_session
    puts session.inspect
  end
  
end
