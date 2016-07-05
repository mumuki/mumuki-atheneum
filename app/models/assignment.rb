class Assignment < ActiveRecord::Base
  include WithStatus

  belongs_to :exercise
  has_one :guide, through: :exercise

  belongs_to :submitter, class_name: 'User'

  validates_presence_of :exercise, :submitter

  serialize :expectation_results
  serialize :test_results

  delegate :language, :name, :visible_success_output?, to: :exercise
  delegate :output_content_type, to: :language
  delegate :should_retry?, to: :status

  scope :by_exercise_ids, -> (exercise_ids) {
    where(exercise_id: exercise_ids) if exercise_ids
  }

  scope :by_usernames, -> (usernames) {
    joins(:submitter).where('users.name' => usernames) if usernames
  }

  def results_visible?
    visible_success_output? || should_retry?
  end

  def result_preview
    result.truncate(100) if should_retry?
  end

  def result_html #TODO move rendering logic to helpers
    output_content_type.to_html(result)
  end

  def feedback_html
    output_content_type.to_html(feedback)
  end

  def expectation_results_visible?
    visible_expectation_results.present?
  end

  def visible_expectation_results
    Rails.configuration.verbosity.visible_expectation_results(expectation_results || [])
  end

  def accept_new_submission!(submission)
    transaction do
      update! submission_id: submission.id
      update_submissions_count!
      update_last_submission!
    end
  end

  def comments
    Comment.where(submission_id: submission_id).order('date DESC')
  end

  def comment!(comment_data)
    Comment.create! comment_data.merge(submission_id: submission_id, exercise_id: exercise_id)
  end

  private

  def update_submissions_count!
    self.class.connection.execute(
        "update public.exercises
         set submissions_count = submissions_count + 1
        where id = #{exercise.id}")
    self.class.connection.execute(
        "update public.assignments
         set submissions_count = submissions_count + 1
        where id = #{id}")
    exercise.reload
  end

  def update_last_submission!
    submitter.update!(last_submission_date: created_at, last_exercise: exercise)
  end

  def status_message
    I18n.t(status.passed? && exercise.navigable_parent.is_a?(Exam) ? :teacher_evaluation_pending : status)
  end
end
