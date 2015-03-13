module Icons

  def status_icon(with_status)
    fa_icon *icon_for_status(with_status.status)
  end

  def exercise_status_icon(exercise)
    link_to exercise_status_fa_icon(exercise),
            exercise_submissions_path(exercise) if current_user?
  end

  def language_icon(language, options={})
    options = {title: language, alt: language.name, height: 16, class: 'special-icon has-tooltip'}.merge(options)
    link_to image_tag(language.image_url, options), exercises_path(q: language.name)
  end

  private

  def exercise_status_fa_icon(exercise)
    fa_icon(*icon_for_status(exercise.status_for(current_user)))
  end

  def icon_for_status(status)
    def i(icon, class_)
      [icon, class: "text-#{class_} special-icon"]
    end
    case status.to_s
      when 'passed' then i 'check','success'
      when 'failed' then i 'times', 'danger'
      when 'running' then i 'circle', 'warning'
      when 'pending' then i 'clock-o','info'
      when 'unknown' then i 'circle', 'muted'
      else raise "Unknown status #{status}"
    end
  end

end
