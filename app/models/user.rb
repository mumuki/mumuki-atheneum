class User < ActiveRecord::Base
  include WithProfile,
          WithToken,
          WithPermissions,
          TerminalNavigation,
          Mumukit::Login::UserPermissionsHelpers

  has_many :assignments, foreign_key: :submitter_id

  has_many :messages, -> { order(created_at: :desc) }, through: :assignments

  has_many :submitted_exercises, through: :assignments, class_name: 'Exercise', source: :exercise

  has_many :solved_exercises,
           -> { where('assignments.status' => Status::Passed.to_i) },
           through: :assignments,
           class_name: 'Exercise',
           source: :exercise

  belongs_to :last_exercise, class_name: 'Exercise'
  belongs_to :last_organization, class_name: 'Organization'

  has_one :last_guide, through: :last_exercise, source: :guide

  has_many :exam_authorizations

  after_initialize :init
  after_save :notify_changed!, if: Proc.new { |user| user.image_url_changed? || user.social_id_changed? }

  def notify_changed!
    Mumukit::Nuntius.notify_event! 'UserChanged', user: event_json
  end

  def update_and_notify!(data)
    update! data
    notify_changed!
  end

  def profile_completed?
    first_name.present? && last_name.present?
  end

  def event_json
    as_json(only: [:uid, :social_id, :image_url, :email, :first_name, :last_name], methods: [:permissions]).compact
  end

  def last_lesson
    last_guide.try(:lesson)
  end

  def submissions_count
    assignments.pluck(:submissions_count).sum
  end

  def passed_submissions_count
    passed_assignments.count
  end

  def submitted_exercises_count
    submitted_exercises.count
  end

  def solved_exercises_count
    solved_exercises.count
  end

  def submissions_success_rate
    "#{passed_submissions_count}/#{submissions_count}"
  end

  def exercises_success_rate
    "#{solved_exercises_count}/#{submitted_exercises_count}"
  end

  def passed_assignments
    assignments.where(status: Status::Passed.to_i)
  end

  def unread_messages
    messages.where read: false
  end

  def visit!(organization)
    update!(last_organization: organization) if organization != last_organization
  end

  def to_s
    "#{id}:#{name}:#{uid}"
  end

  def never_submitted?
    last_submission_date.nil?
  end

  def clear_progress!
    transaction do
      update! last_submission_date: nil, last_exercise: nil
      assignments.destroy_all
    end
  end

  def transfer_progress_to!(another)
    transaction do
      assignments.update_all(submitter_id: another.id)
      if another.never_submitted? || last_submission_date.try { |it| it > another.last_submission_date }
        another.update! last_submission_date: last_submission_date,
                        last_exercise: last_exercise,
                        last_organization: last_organization
      end
    end
    reload
  end

  def self.import_from_json!(body)
    body[:name] = "#{body[:first_name]} #{body[:last_name]}"
    User.where(uid: body[:uid]).update_or_create!(body.except(:id))
  end

  private

  def init
    self.image_url ||= "user_shape.png"
  end

end
