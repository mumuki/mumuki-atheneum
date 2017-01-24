class SessionsController < ApplicationController
  def callback
    user = User.omniauth(env['omniauth.auth'])

    remember_me_token.value = user.remember_me_token
    redirect_after_login
  end

  def failure
    @error_msg = request.params['message']
  end

  def destroy
    remember_me_token.clear!
    redirect_to Mumukit::Auth::Login.logout_redirection_path
  end

  def redirect_after_login
    path = session[:redirect_after_login] || :back
    session[:redirect_after_login] = nil

    redirect_to path
  end
end
