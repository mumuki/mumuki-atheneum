require 'addressable/uri'

# It acts as a guide container in monolesson contexts
class ChaptersController < GuideContainerController
  include Mumuki::Laboratory::Controllers::ImmersiveNavigation
  include Mumuki::Laboratory::Controllers::ValidateAccessMode

  def subject
    @chapter ||= Chapter.find_by(id: params[:id])
  end

  private

  def set_guide
    @monolesson = subject.monolesson
    @guide = @monolesson&.guide
  end

  def authorization_minimum_role
    :ex_student
  end

  def subject_container
    subject.topic
  end
end
