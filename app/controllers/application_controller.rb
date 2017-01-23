class ApplicationController < ActionController::Base
  include WithOrganization

  include Authentication
  include Authorization
  include WithRememberMeToken
  include Pagination
  include Referer
  include WithComments
  include Accessibility
  include WithDynamicErrors
  include WithOrganizationChooser

  before_action :set_organization!
  before_action :set_locale!
  before_action :authorize!
  before_action :validate_subject_accessible!
  before_action :visit_organization!, if: :current_user?

  AuthStrategy.protect_from_forgery self

  helper_method :current_user, :current_user?,
                :current_user_id,
                :login_anchor,
                :comments_count,
                :has_comments?,
                :subject,
                :should_choose_organization?

  private

  def set_locale!
    I18n.locale = Organization.locale
  end

  def subject #TODO may be used to remove breadcrumbs duplication
    nil
  end
end
