class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  include HelperFunctions
  allow_browser versions: :modern
  helper_method :current_business, :authorize_business

  def current_business
    @current_business ||= session[:business_id] && Business.find_by(id: session[:business_id])
  end

  def authorize_business
    unless current_business && current_business.id == @business.id || current_business && current_business.admin == true
      if current_business
        redirect_to business_path(current_business)
      else
        redirect_to login_path
      end
    end
  end

  def protect_route
    unless current_business && current_business.admin == true
      redirect_to root_path
    end
  end
end
