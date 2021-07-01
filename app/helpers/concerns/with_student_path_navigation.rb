module WithStudentPathNavigation
  def next_button(navigable)
    return unless navigable
    navigation_flows.lazy.map { |it| it.new(self).button(navigable) }.find(&:present?)
  end

  def next_lesson_button(guide)
    next_button(guide.lesson) || chapter_finished(guide.chapter)
  end

  def next_exercise_button(exercise)
    next_button(exercise) || next_button(exercise.guide.lesson) unless show_content_element?
  end

  def close_modal_button
    %Q{<button class="btn btn-complementary w-100 mu-close-modal">#{t :keep_learning}</button>}.html_safe
  end

  private

  def navigation_flows
    [ContinueNavigation, RevisitNavigation, NextParentNavigation, FinishNavigation]
  end
end
