class RelationshipsController < ApplicationController
  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    redirect_to @user
  end

  def destroy
    # A bit confusing, but remember that the unfollow form is created with a relationship
    # object, which means that the id represents the relationship id.
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    redirect_to @user
  end
end