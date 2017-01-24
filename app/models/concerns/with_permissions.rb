module WithPermissions
  extend ActiveSupport::Concern

  included do
    serialize :permissions, Mumukit::Auth::Permissions

    validates_presence_of :permissions
  end

  def student?
    permissions.student? Organization.slug
  end

  def teacher?
    permissions.teacher? Organization.slug
  end

  def update_permissions!(permissions)
    update!(permissions: permissions)
  end

  def accessible_organizations
    permissions.accessible_organizations.map {|org| Organization.find_by(name: org)}.compact
  end

  def has_accessible_organizations?
    accessible_organizations.present?
  end

end
