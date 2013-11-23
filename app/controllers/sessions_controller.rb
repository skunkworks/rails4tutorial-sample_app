class SessionsController < ApplicationController

  def new
  end

  def create
    # Authenticate user using sessions hash
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # sign_in method is defined in SessionsHelper and is responsible for creating
      # a permanent session for the user that does not expire
      sign_in user
      redirect_back_or user
    else
      # Don't do this! Flash messages persist for the next request, and rendering
      # the 'new' template like we do here counts as the *current* request, not
      # the next one!
      # 
      # flash[:error] = 'Invalid email/password combination'
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
