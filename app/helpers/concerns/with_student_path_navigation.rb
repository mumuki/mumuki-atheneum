module WithStudentPathNavigation
  def next_button(navigable)
    return unless navigable
    ContinueNavigation.new(self).button(navigable) || RevisitNavigation.new(self).button(navigable) || FinishNavigation.new(self).button(navigable)
    #TODO Refactor this
  end

  def next_lesson_button(guide)
    next_button(guide.lesson) || chapter_finished(guide.chapter)
  end

  def next_exercise_button(exercise)
    adaptive_navigation_button(exercise) || next_button(exercise.guide.lesson)
  end

  def adaptive_navigation_button(exercise)
    AdaptiveNavigation.new(self).button(exercise)
  end

  def close_modal_button
    %Q{<button class="btn btn-success btn-block mu-close-modal">#{t :keep_learning}</button>}.html_safe
  end
end
