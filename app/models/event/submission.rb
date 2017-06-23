class Event::Submission < Event::Base
  def initialize(assignment)
    @assignment = assignment
  end

  def queue_name
    'submissions'
  end

  def event_json
    navigable_parent = @assignment.exercise.navigable_parent
    @assignment.
      as_json(except: [:exercise_id, :submission_id, :id, :submitter_id, :solution, :created_at, :updated_at],
              include: {
                guide: {
                  only: [:slug, :name],
                  include: {
                    lesson: {only: [:number]},
                    language: {only: [:name]}},
                },
                exercise: {only: [:name, :number]},
                submitter: {only: [:uid]}}).
      deep_merge(
        'sid' => @assignment.submission_id,
        'created_at' => @assignment.updated_at,
        'content' => @assignment.solution,
        'exercise' => {
          'eid' => @assignment.exercise.bibliotheca_id
        },
        'guide' => {'parent' => {
          'type' => navigable_parent.class.to_s,
          'name' => navigable_parent.name,
          'position' => navigable_parent.try(:number),
          'chapter' => @assignment.guide.chapter.as_json(only: [:id], methods: [:name])
        }})
  end
end
