module OverlappedButtonsHelper
  def expand_icon
    overlapped_link :fullscreen, :expand, class: 'editor-resize'
  end

  def format_icon
    overlapped_link :format, :indent, class: 'editor-format'
  end

  def restart_icon(source='console', **options)
    overlapped_link :restart, :undo, class: "#{source}-reset submission-reset", **options
  end

  def restart_guide_link(guide)
    all_options = tooltip_options(:restart).merge!(
      {class: 'mu-content-toolbar-item mu-restart-guide',
       data: {confirm: t(:confirm_restart)}, method: :delete, 'data-bs-placement': 'top'})

    link_to overlapped_button_icon(:undo), guide_progress_path(guide), all_options if show_content_element?

  end

  private

  def overlapped_link(key, icon, **options)
    content_tag :a, overlapped_button_icon(icon), tooltip_options(key).merge!(options)
  end

  def overlapped_button_icon(icon)
    fa_icon icon, class: 'fa-fw', role: 'button'
  end

  def tooltip_options(key)
    {title: t(key), 'aria-label': t(key), 'data-bs-toggle': 'tooltip', 'data-bs-placement': 'left'}
  end
end
