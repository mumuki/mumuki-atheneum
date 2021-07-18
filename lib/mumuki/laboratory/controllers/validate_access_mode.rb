module Mumuki::Laboratory::Controllers::ValidateAccessMode
  extend ActiveSupport::Concern

  included do
    before_action :validate_accessible!, only: :show
  end

  def validate_accessible!
    current_access_mode.validate_content_here? subject_container
  end

  def subject_container
    subject
  end
end
