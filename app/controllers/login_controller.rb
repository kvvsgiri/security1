class LoginController < ApplicationController

  def login

  end

  def verify_login
    @user = User.where('email= ? and password = ?', params[:email], Digest::MD5.hexdigest(params[:password])).first
    if @user
      reset_session
      session[:user_id] = @user.id
      if @user.role == "admin"
        redirect_to users_path
      else
        redirect_to user_path(@user)
      end
    else
      flash[:notice] = "Please enter valid credentials"
      redirect_to :login
    end

  end

  def logout
    reset_session
    redirect_to :root
  end
end
