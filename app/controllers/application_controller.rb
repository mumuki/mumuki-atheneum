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

  before_action :set_current_organization!
  before_action :set_locale!

  before_action :ensure_user_enabled!, if: :current_user?
  before_action :validate_active_organization!

  before_action :redirect_to_main_organization!, if: :should_redirect_to_main_organization?

  before_action :authorize_if_private!
  before_action :validate_active_organization!
  before_action :validate_user_profile!, if: :current_user?

  before_action :visit_organization!, if: :current_user?

  before_action :verify_email!, if: :current_user?

  after_action :leave_organization!

  helper_method :current_workspace,
                :login_button,
                :notifications_count,
                :user_notifications_path,
                :has_notifications?,
                :subject,
                :should_choose_organization?,
                :theme_stylesheet_url,
                :extension_javascript_url

  def should_redirect_to_main_organization?
    should_choose_organization? && current_user.has_immersive_main_organization?
  end

  def redirect_to_main_organization!
    redirect_to current_user.main_organization.url_for(request.path)
  end

  def should_choose_organization?
    current_user? &&
      current_user.has_student_granted_organizations? &&
      Mumukit::Platform.implicit_organization?(request)
  end

  # ensures contents are accessible to current user
  def validate_accessible!
    return if current_user&.teacher_here?
    accessible_subject.validate_accessible_for! current_user
  end

  def validate_active_organization!
    return if current_user&.teacher_here?
    Organization.current.validate_active!
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

  private

  def verify_email!
    begin
      Organization.current.email_verification_policy.verify!(current_user)
    rescue Mumuki::Domain::GracePeriodStartError
      #TODO: show modal
    end
  end

  def from_sessions?
    params['controller'] == 'login'
  end

  def login_settings
    Organization.current.login_settings
  end

  def validate_user_profile!
    unless current_user.profile_completed?
      flash.notice = I18n.t :please_fill_profile_data
      redirect_to user_path
    end
  end

  def set_locale!
    I18n.locale = Organization.current.locale
  end

  def subject #TODO may be used to remove breadcrumbs duplication
    nil
  end

  def leave_organization!
    Mumukit::Platform::Organization.leave!
  end
end
