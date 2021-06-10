module Mumuki::Laboratory::Controllers::Authorization
  def authorize_if_private!
    return if Organization.current.public? || from_sessions?
    authorize! authorization_minimum_role
  end

  def authorization_slug
    Organization.current.slug
  end

  def authorization_minimum_role
    :student
  end
end
