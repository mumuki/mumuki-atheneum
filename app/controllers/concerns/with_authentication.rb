module WithAuthentication
  def current_user_id
    @current_user_id ||= remember_me_token.value.try do |token |
      User.where(remember_me_token: token).first.try(:id)
    end
  end

  def current_user?
    current_user_id.present?
  end

  def current_user
    @current_user ||= User.find(current_user_id) if current_user?
  end

  def authenticate!
    unauthenticated! unless current_user?
  end

  def unauthenticated!
    message = t :you_must, action: login_anchor(title: :sign_in_action)

    redirect_to :back, alert: message
  rescue ActionController::RedirectBackError
    redirect_to root_path, alert: message
  end

  def login_anchor(options={})
    options[:title] ||= :sign_in
    session[:redirect_after_login] = request.fullpath
    Mumukit::Auth::Login.button_html I18n.t(options[:title]), options[:class]
  end
end
