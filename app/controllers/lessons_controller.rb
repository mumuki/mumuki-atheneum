class LessonsController < GuideContainerController
  include Mumuki::Laboratory::Controllers::ImmersiveNavigation

  private

  def subject
    @lesson ||= Lesson.find_by(id: params[:id])
  end

  def authorization_minimum_role
    :ex_student
  end
end
