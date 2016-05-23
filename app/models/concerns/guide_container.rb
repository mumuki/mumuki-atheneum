module GuideContainer
  extend ActiveSupport::Concern

  included do
    validates_presence_of :guide

    delegate :name,
             :language,
             :teaser_html,
             :search_tags,
             :exercises,
             :first_exercise,
             :next_exercise,
             :stats_for,
             :exercises_count, to: :guide
  end

  def friendly
    defaulting_name { "#{navigable_parent.friendly}: #{name}" }
  end
end