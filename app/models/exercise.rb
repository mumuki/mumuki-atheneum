class Exercise < ApplicationRecord
  include WithDescription
  include WithLocale
  include WithNumber,
          WithAssignments,
          FriendlyName,
          WithLanguage,
          Assistable,
          WithRandomizations,
          WithDiscussions

  include Submittable,
          Questionable

  include SiblingsNavigation,
          ParentNavigation

  belongs_to :guide
  defaults { self.submissions_count = 0 }

  validates_presence_of :submissions_count,
                        :guide

  randomize :description, :hint, :extra, :test, :default_content
  delegate :capped?, :timed?, to: :navigable_parent

  def console?
    queriable?
  end

  def used_in?(organization=Organization.current)
    guide.usage_in_organization(organization).present?
  end

  def pending_siblings_for(user)
    guide.pending_exercises(user)
  end

  def structural_parent
    guide
  end

  def guide_done_for?(user)
    guide.done_for?(user)
  end

  def previous
    sibling_at number.pred
  end

  def sibling_at(index)
    index = number + index unless index.positive?
    guide.exercises.find_by(number: index)
  end

  def search_tags
    [language&.name, *tag_list].compact
  end

  def slug
    "#{guide.slug}/#{bibliotheca_id}"
  end

  def slug_parts
    guide.slug_parts.merge(bibliotheca_id: bibliotheca_id)
  end

  def friendly
    defaulting_name { "#{navigable_parent.friendly} - #{name}" }
  end

  def submission_for(user)
    assignment_for(user).submission
  end

  def new_solution
    Solution.new(content: default_content)
  end

  def import_from_json!(number, json)
    self.language = Language.for_name(json['language']) || guide.language
    self.locale = guide.locale

    reset!

    attrs = whitelist_attributes(json, except: %w(type id))
    attrs['choices'] = json['choices'].map { |choice| choice['value'] } if json['choices'].present?
    attrs['bibliotheca_id'] = json['id']
    attrs['number'] = number
    attrs = attrs.except('expectations') if json['type'] != 'problem' || json['new_expectations']

    assign_attributes(attrs)
    save!
  end

  def reset!
    self.name = nil
    self.description = nil
    self.corollary = nil
    self.hint = nil
    self.extra = nil
    self.tag_list = []
  end

  def ensure_type!(type)
    if self.type != type
      reclassify! type
    else
      self
    end
  end

  def reclassify!(type)
    update!(type: Exercise.class_for(type).name)
    Exercise.find(id)
  end

  def messages_path_for(user)
    "api/guides/#{guide.slug}/#{bibliotheca_id}/student/#{URI.escape user.uid}/messages?language=#{language}"
  end

  def messages_url_for(user)
    Mumukit::Platform.classroom_api.organic_url_for(Organization.current, messages_path_for(user))
  end

  def description_context
    Mumukit::ContentType::Markdown.to_html splitted_description.first
  end

  def splitted_description
    description.split('> ')
  end

  def description_task
    Mumukit::ContentType::Markdown.to_html splitted_description.drop(1).join("\n")
  end

  def custom?
    false
  end

  def inspection_keywords
    {}
  end

  def default_content
    self[:default_content] || ''
  end

  def max_attempts_in(exam)
    choice? ? exam.max_choice_submissions : exam.max_problem_submissions
  end

  def try_submit_solution!(user, solution)
    assignment = find_or_init_assignment_for(user)
    navigable_parent.submission_context_for(assignment) { submit_solution! user, solution }
  end

  def results_partial
    input_kids? ? 'exercise_solutions/kids_results' : 'exercise_solutions/results'
  end

  def attempts_left_for(assignment)
    max_attempts_in(navigable_parent) - (assignment&.attempts_count || 0)
  end

  private

  def evaluation_class
    if manual_evaluation?
      manual_evaluation_class
    else
      automated_evaluation_class
    end
  end

  def manual_evaluation_class
    Mumuki::Laboratory::Evaluation::Manual
  end

  def automated_evaluation_class
    Mumuki::Laboratory::Evaluation::Automated
  end

  def self.class_for(type)
    type.camelcase.constantize
  end

  def self.default_layout
    layouts.keys[0]
  end
end
