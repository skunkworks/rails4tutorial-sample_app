class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'Welcome to the Sample App!'
      redirect_to @user
    else
      render 'new'
    end
  end

  private

  # Strong params -- anywhere you'd previously pass in params willy-nilly, replace with
  # calls to a private method such as below.
  #
  # #require is an ActionController::Parameters instance method that looks at the parameters
  # and requires that the given key exists. If it does, it returns the paramter at that key.
  #
  # #permit is also an ActionController::Parameters instance method. It takes in one or more
  # attribute names as symbols and returns the params filtered to only those attributes.
  #
  # In this example, require returns the user hash, and permit filters that user hash such
  # that it contains only the permitted attributes.
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
