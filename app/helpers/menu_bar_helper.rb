module MenuBarHelper
  def menu_bar_links
    [
      menu_link_to_classroom,
      menu_link_to_bibliotheca,
      solve_discussions_link,
      user_discussions_link
    ].compact
  end

  def menu_bar_list_items
    menu_bar_links.compact.map { |link| li_tag(link) }.join.html_safe
  end

  def li_tag(link)
    content_tag :li, link
  end

  def menu_link_to_profile
    li_tag menu_item('user', :my_account, user_path)
  end

  def menu_link_to_classroom
    menu_link_to_application 'graduation-cap', :classroom_ui, :teacher_here?
  end

  def menu_link_to_bibliotheca
    menu_link_to_application :book, :bibliotheca_ui, :writer?
  end

  def menu_link_to_application(icon, app_name, minimal_permissions)
    return unless current_user&.send(minimal_permissions)
    url = url_for_application(app_name)
    menu_item icon, app_name, url
  end

  def logout_menu_link
    li_tag menu_item('sign-out-alt', :sign_out, logout_path(origin: url_for))
  end

  def menu_item(icon, name, url, translation_params = {})
    link_to fixed_fa_icon(icon, text: t(name, translation_params)), url, role: 'menuitem', tabindex: '-1', class: 'dropdown-item'
  end

  def any_menu_bar_links?
    menu_bar_links.any?
  end

  def menu_link_to_faqs
    li_tag menu_item('question', :faqs, faqs_path)
  end
end
