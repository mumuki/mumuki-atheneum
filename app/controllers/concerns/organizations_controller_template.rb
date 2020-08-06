module OrganizationsControllerTemplate
  extend ActiveSupport::Concern

  included do
    before_action :set_organization!, only: [:show, :update, :edit]
    before_action :set_new_organization!, only: :create
  end

  private

  def set_new_organization!
    @organization = Organization.new organization_params
    @organization.validate!
  end

  def set_organization!
    @organization = Organization.locate! params[:id]
  end

  def protection_slug
    @organization&.slug
  end

  def organization_params
    params
      .require(:organization)
      .permit(:book,
              :name,
              *Mumuki::Domain::Organization::Profile.attributes,
              *Mumuki::Domain::Organization::Theme.attributes,
              *(Mumuki::Domain::Organization::Settings.attributes - %i(login_methods email_verification_policy)),
              login_methods: [],
              email_verification_policy: [:type, options: [:grace_period]]
              )
      .tap { |it| it.merge!(book: Book.find_by!(slug: it[:book])) if it[:book] }
  end
end
