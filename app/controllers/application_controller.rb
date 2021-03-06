class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from ActionController::MethodNotAllowed, with: :render_forbidden
    rescue_from User::NotAuthorized, with: :render_forbidden
  end

  def raise_not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_not_found(e)
    respond_to do |f|
      f.html{ render "public/404.html", :status => 404 }
    end
  end

  def raise_forbidden
    raise ActionController::MethodNotAllowed.new
  end

  def render_forbidden(e)
    respond_to do |f|
      f.html{ render "public/403.html", :status => 403 }
    end
  end

  def current_user
    User.find_by_email(session[:email])
  end

  def require_login
    if current_user.nil?
      store_target_location
      redirect_to root_url
    else
      redirect_to_target if session[:return_to].present?
    end
  end

private

  def redirect_to_target
    redirect_to(session[:return_to])
    session[:return_to] = nil
  end

  def store_target_location
    session[:return_to] = request.url
  end
end