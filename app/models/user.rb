class User < ActiveRecord::Base
  include WithOmniauth, WithToken, WithMetadata, WithUserNavigation

  has_many :assignments, foreign_key: :submitter_id
  has_many :comments, foreign_key: :recipient_id

  has_many :submitted_exercises, through: :assignments, class_name: 'Exercise', source: :exercise

  has_many :solved_exercises,
           -> { where('assignments.status' => Status::Passed.to_i) },
           through: :assignments,
           class_name: 'Exercise',
           source: :exercise

  belongs_to :last_exercise, class_name: 'Exercise'
  belongs_to :last_organization, class_name: 'Organization'

  has_one :last_guide, through: :last_exercise, source: :guide

  has_and_belongs_to_many :exams

  after_initialize :init

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

  def create_remember_me_token!
    self.remember_me_token ||= get_token
    self.save!
  end

  def revoke!
    self.update!(remember_me_token: nil)
  end

  def social_id
    uid
  end

  def unread_comments
    comments.where(read: false)
  end

  def visit!(organization)
    update!(last_organization: organization) if organization != last_organization
  end

  def to_s
    "#{id}:#{name}:#{uid}"
  end


  private

  def init
    self.image_url ||= "user_shape.png"
  end

end
