module PreferencesHelper
  def uppercase_enabled?(user, organization)
    uppercase_organization?(organization) || (user.preferences.uppercase? if user)
  end

  def uppercase_organization?(organization)
    organization.kindergarten?
  end
end
