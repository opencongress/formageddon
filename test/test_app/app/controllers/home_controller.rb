class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index ]
  before_filter :admin_required, :only => [ :protected_for_admin ]

  def index
    
  end
  
  def protected_for_user
    render :partial => 'protected'
  end
  
  def protected_for_admin
    render :partial => 'protected'
  end
end