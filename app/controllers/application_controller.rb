class ApplicationController < ActionController::Base
  Mumukit::Login.configure_controller! self

  include WithOrganization

  include WithAuthentication
  include WithAuthorization
  include WithPagination
  include WithMessagesNotification
  include WithCustomAssets
  include Accessible
  include WithDynamicErrors
  include WithOrganizationChooser

  before_action :set_organization!
  before_action :set_locale!
  before_action :authorize_if_private!
  before_action :validate_user_profile!, if: :current_user?
  before_action :validate_subject_accessible!
  before_action :visit_organization!, if: :current_user?

  helper_method :login_button,
                :messages_count,
                :has_messages?,
                :subject,
                :should_choose_organization?,
                :theme_stylesheet_url,
                :extension_javascript_url

  private

  def login_settings
    Organization.current.login_settings
  end

  def validate_user_profile!
    unless current_user.profile.complete?
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
end
