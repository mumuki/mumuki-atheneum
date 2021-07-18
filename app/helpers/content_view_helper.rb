module ContentViewHelper
  def full_title_for(content)
    "#{t(content_type_number(content), number: content.number)}: #{content.name}"
  end

  def short_title_for(content)
    content.name
  end

  def show_content?(content)
    current_access_mode.show_content?(content)
  end

  def show_content_element?
    current_access_mode.show_content_element?
  end

  private

  def content_type_number(content)
    "#{content_type(content)}_number"
  end

  def content_type(content)
    content.model_name.element
  end
end
