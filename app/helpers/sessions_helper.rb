module SessionsHelper

  def sign_in(user)
    # We need to persist state to indicate that the user has successfully signed in.
    #
    # Using session to store a remember token is one option: it stores the token in
    # a cookie that expires on browser close.
    #
    # However, if we want sign-in sessions that persist even on browser close, we
    # need to create a secure token that the user can store permanently and that *we*
    # store permanently. On the client side, we can use a permanent cookie to hold the
    # remember token; on our side, we'll stash the token in the user model.
    #
    
    # Generate a new remember token each time a user signs in. Has a side effect of
    # invalidating any hijacked remember tokens from the database when the user signs
    # in again
    remember_token = User.new_remember_token
    
    # Save the remember token in a permanent cookie. The #permanent method sets the
    # expiration of the remember_token to 20 years from now.
    cookies.permanent[:remember_token] = remember_token

    # Update the user model to reflect the new token
    user.update_attribute(:remember_token, User.encrypt(remember_token))

    # ... what is this all about?
    #
    # Answer: we want to allow both controllers and views to easily access the
    # current user. Our strategy for this is to define current_user in the
    # SessionsHelper module/mix-in, which is included in ApplicationController,
    # which is therefore available in all of our controllers because they are
    # subclasses.
    #
    self.current_user = user
  end

  def sign_out
    @current_user = nil
    # Note: easy way to get rid of something from cookie. Setting it to nil would
    # probably keep it in the cookie with a blank value. This removes the key from
    # the cookie altogether.
    cookies.delete(:remember_token)
  end

  # Deeper question: how do we store the current user?
  #
  # If we stash it in @current_User, the next HTTP request causes it to disappear. So
  # what's the purpose of even setting the @current_user instance variable in this
  # method, particularly when the current_user accessor below does an explicit database
  # query to find the current user, except when we first sign in?
  #
  # Answer: it's to cache the current user in case current_user is invoked more than
  # once for a given HTTP request.
  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by_remember_token(remember_token)
  end

  def current_user?(user)
    current_user == user
  end

  def signed_in?
    !current_user.nil?
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    # Why do we only store the URL to return to if it's a GET request?
    # Answer: one edge case exists when the user attempts to perform an action that
    # requires authentication that uses POST, PATCH, DELETE, e.g. they submit a form
    # after purging their cookies. If we stored the forwarding URL for these cases,
    # after the user re-authenticated, we would attempt to redirect them to this
    # forwarding URL but it would be with a GET, which would lead to either an error
    # or their reaching some unexpected page. A more sensible behavior might be to
    # pretend the forwarding URL request never happened and provide default sign-in
    # behavior.
    session[:return_to] = request.url if request.get?
  end
end
