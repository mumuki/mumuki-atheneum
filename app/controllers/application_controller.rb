class ApplicationController < ActionController::Base
  Mumukit::Login.configure_controller! self

  protect_from_forgery with: :exception

  include Mumuki::Laboratory::Controllers::CurrentOrganization
  include Mumukit::Login::AuthenticationHelpers

  include Mumuki::Laboratory::Controllers::Authorization
  include Mumuki::Laboratory::Controllers::Disabling
  include Mumuki::Laboratory::Controllers::Notifications
  include Mumuki::Laboratory::Controllers::DynamicErrors
  include Mumuki::Laboratory::Controllers::EmbeddedMode
  include Mumuki::Laboratory::Controllers::IncognitoMode
  include Mumuki::Laboratory::Controllers::ActionRedirector

  before_action :set_current_organization!
  before_action :set_locale!
  before_action :set_time_zone!

  before_action :ensure_user_enabled!, if: :current_user?
  before_action :validate_active_organization!

  before_action :redirect_to_proper_context!, if: :immersive_context_wrong?

  before_action :authorize_if_private!
  before_action :validate_user_profile!, if: :current_user?
  before_action :validate_accepted_role_terms!, if: :current_user?

  before_action :visit_organization!, if: :current_user?

  after_action :leave_organization!
  after_action :unset_time_zone!

  helper_method :current_workspace,
                :login_button,
                :notifications_count,
                :has_notifications?,
                :notifications,
                :subject,
                :should_choose_organization?,
                :current_immersive_organizations,
                :theme_stylesheet_url,
                :extension_javascript_url,
                :current_immersive_path,
                :current_access_mode

  add_flash_types :info

  def immersive_context_wrong?
    current_immersive_context != Organization.current
  end

  def redirect_to_proper_context!
    redirect_to current_immersive_path_for(*current_immersive_context_and_content)
  end

  def should_choose_organization?
    return false unless current_user?
    current_immersive_organizations.multiple?
  end

  def current_immersive_organizations
    current_user.immersive_organizations_with_content_at(subject)
  end

  # ensures contents are accessible to current user
  def validate_accessible!
    return if current_user&.teacher_here?
    accessible_subject.validate_accessible_for! current_user
  end

  def validate_active_organization!
    return if current_user&.teacher_here?
    Organization.current.validate_active_for! current_user
  end

  # required by Mumukit::Login
  def login_button(options = {})
    login_form.button_html I18n.t(:sign_in), options[:class]
  end

  # redirects to the usage in the current organization for the given content
  # or raises a not found error if unused
  def redirect_to_usage(content)
    raise Mumuki::Domain::NotFoundError unless content.usage_in_organization.try { |usage| redirect_to usage }
  end

  def current_workspace
    Mumuki::Domain::Workspace.new(current_user, Organization.current)
  end

  def current_immersive_path(context)
    current_immersive_path_for context, subject&.navigable_content_in(context)
  end

  def current_immersive_path_for(context, content)
    resource = content ? polymorphic_path(content) : default_immersive_path_for(context)
    context.url_for resource
  end

  private

  def default_immersive_path_for(context)
    subject.present? ? root_path : inorganic_path_for(request)
  end

  def inorganic_path_for(request)
    Mumukit::Platform.organization_mapping.inorganic_path_for(request)
  end

  def current_immersive_context
    current_immersive_context_and_content&.first || Organization.current
  end

  def current_immersive_context_and_content
    current_user&.current_immersive_context_and_content_at(subject) || [Organization.current, nil]
  end

  def from_sessions?
    params['controller'] == 'login'
  end

  def login_settings
    Organization.current.login_settings
  end

  def validate_user_profile!
    unless current_user.profile_completed?
      save_location_before! :profile_completion
      flash[:info] = I18n.t :please_fill_profile_data
      redirect_to edit_user_path
    end
  end

  def validate_accepted_role_terms!
    if current_user&.has_role_terms_to_accept?
      save_location_before! :terms_acceptance
      flash[:info] = I18n.t :accept_terms_to_continue
      redirect_to terms_user_path
    end
  end

  def set_locale!
    I18n.locale = Organization.current.locale
  end

  def set_time_zone!
    Time.zone = Organization.current.time_zone
  end

  def unset_time_zone!
    Time.zone = nil
  end

  def subject #TODO may be used to remove breadcrumbs duplication
    nil
  end

  def leave_organization!
    Mumukit::Platform::Organization.leave!
  end

  def current_access_mode
    Organization.current.access_mode(current_user)
  end
end
