class ExerciseSubmissionsController < ApplicationController
  before_action :authenticate!

  before_action :set_submission, only: [:show, :status, :results]
  before_action :set_exercise, only: [:create, :new, :show, :index]
  before_action :set_previous_submission_content, only: [:new]

  def index
    @submissions = paginated @exercise.submissions_for(current_user).order(created_at: :desc)
  end

  def show
  end

  def create
    @submission = current_user.submissions.build(submission_params)

    if @submission.save
      redirect_to [@exercise, @submission], notice: t(:submission_created)
    else
      render :new
    end
  end

  def status
    render json: @submission.as_json(only: :status)
  end

  def results
    render :results, layout: false
  end

  private
  def set_submission
    @submission = Submission.find(params[:id] || params[:submission_id])
  end

  def set_previous_submission_content
    @previous_submission_content = @exercise.default_content_for(current_user)
  end

  def set_exercise
    @exercise = Exercise.find(params[:exercise_id])
  end

  def submission_params
    params.require(:submission).permit(:content).merge(exercise: @exercise)
  end
end
