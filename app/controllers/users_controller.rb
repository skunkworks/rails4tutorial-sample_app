class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy]

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    redirect_to root_url if signed_in?
    @user = User.new
  end

  def edit
    # @user is set by correct_user before_action filter
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'Welcome to the Sample App!'
      sign_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
    # @user is set by correct_user before_action filter
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    if user == current_user
      flash[:error] = 'You cannot delete yourself!'
    else
      user.destroy
      flash[:notice] = 'User deleted'
    end
    redirect_to users_path
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

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

end
