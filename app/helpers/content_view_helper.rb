module ContentViewHelper
  def full_title_for(content)
    "#{t(content_type_number(content), number: content.number)}: #{content.name}"
  end

  def short_title_for(content)
    content.name
  end

  def show_content?(content)
    Organization.current.access_mode(current_user).show_content?(content)
  end

  private

  def content_type_number(content)
    "#{content_type(content)}_number"
  end

  def content_type(content)
    content.model_name.element
  end
end
