class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user_role, except: [:login, :verify_login]

  def set_user_role
    @user = User.find_by_id(session[:user_id])
    if @user
      @role = @user.role
    else
      reset_session
      redirect_to :root
    end
  end

  def should_be_admin
    get_out unless @role == 'admin'
  end

  def should_be_admin_or_self
    get_out unless (@role == 'admin' || session[:user_id].to_s == params[:id])
  end

  def get_out
    reset_session
    flash[:notice] = "Something Fishy!!!"
    redirect_to :root
  end

end
