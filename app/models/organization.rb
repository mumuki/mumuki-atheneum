class Organization < ActiveRecord::Base
  include Mumukit::Platform::Organization::Helpers

  serialize :profile, Mumukit::Platform::Organization::Profile
  serialize :settings, Mumukit::Platform::Organization::Settings
  serialize :theme, Mumukit::Platform::Organization::Theme

  validate :ensure_consistent_public_login

  belongs_to :book
  has_many :usages

  validates_presence_of :name, :contact_email
  validates_uniqueness_of :name

  after_create :reindex_usages!

  has_many :guides, through: 'usages', source: 'item', source_type: 'Guide'
  has_many :exercises, through: :guides
  has_many :assignments, through: :exercises
  has_many :exams

  def in_path?(item)
    usages.exists?(item: item) || usages.exists?(parent_item: item)
  end

  def notify_recent_assignments!(date)
    notify_assignments! assignments.where('assignments.updated_at > ?', date)
  end

  def notify_assignments_by!(submitter)
    notify_assignments! assignments.where(submitter_id: submitter.id)
  end

  def silent?
    test?
  end

  def reindex_usages!
    transaction do
      drop_usage_indices!
      book.index_usage! self
      exams.each { |exam| exam.index_usage! self }
    end
  end

  def drop_usage_indices!
    usages.destroy_all
  end

  def index_usage_of!(item, parent)
    Usage.create! organization: self, item: item, parent_item: parent
  end

  def accessible_exams_for(user)
    exams.select { |exam| exam.accessible_for?(user) }
  end

  private

  def ensure_consistent_public_login
    errors.add(:base, :consistent_public_login) if settings.customized_login_methods? && public?
  end

  def notify_assignments!(assignments)
    puts "We will try to send #{assignments.count} assignments, please wait..."
    assignments.each { |assignment| assignment.notify! }
  end

  class << self
    def central
      find_by name: 'central'
    end

    def create_from_json!(json)
      Organization.create! parse json
    end

    def update_from_json!(json)
      organization_json = parse json

      organization = Organization.find_by! name: organization_json[:name]
      organization.update! organization_json
    end

    def parse(json)
      book_ids = json[:books].map { |it| Book.find_by!(slug: it).id }
      super.merge(book_id: book_ids.first, book_ids: book_ids)
    end
  end
end
