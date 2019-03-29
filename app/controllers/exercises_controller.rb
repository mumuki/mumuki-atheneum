class ExercisesController < ApplicationController
  include Mumuki::Laboratory::Controllers::Content
  include Mumuki::Laboratory::Controllers::ExerciseSeed

  before_action :set_guide!, only: :show
  before_action :set_assignment!, only: :show, if: :current_user?
  before_action :validate_accessible!, only: :show
  before_action :start!, only: :show

  def show
    @solution = @exercise.new_solution if current_user?
    enable_embedded_rendering
  end

  def show_transparently
    redirect_to Exercise.find_transparently!(params)
  end

  private

  def subject
    @exercise ||= Exercise.find_by(id: params[:id])
  end

  def accessible_subject
    subject.navigable_parent
  end

  def start!
    session_id = Mumukit::Login::Controller.new(Mumukit::Platform.web_framework, self) # TODO: Exponer Mumukit::Login::AuthenticationHelpers::mumukit_controller
      .session.id                                                                      # (o hay alguna forma mejor? code-reviewer responda!)

    @exercise.navigable_parent.start! current_user, session_id
  end

  def set_assignment!
    @assignment = @exercise.assignment_for(current_user)
    @files = @assignment.files
    @current_content = @assignment.current_content
    @default_content = @assignment.default_content
  end

  def set_guide!
    raise Mumuki::Domain::NotFoundError if @exercise.nil?
    @guide = @exercise.guide
  end

  def exercise_params
    params.require(:exercise).
      permit(:name, :description, :locale, :test,
             :extra, :language_id, :hint, :tag_list,
             :guide_id, :number,
             :layout, :expectations_yaml)
  end
end
