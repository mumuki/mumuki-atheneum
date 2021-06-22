module LinksHelper

  def link_to_path_element(element, options={})
    name = extract_name element, options
    link_to name, element, options
  end

  def link_to_error_404
    "<a href='https://es.wikipedia.org/wiki/Error_404'> #{I18n.t(:error_404)} </a>"
  end

  def link_to_issues(translation)
    "<a href='https://github.com/mumuki/mumuki-laboratory/issues/new'> #{I18n.t(translation)} </a>"
  end

  def link_to_status_codes(code)
    "<a href='https://es.wikipedia.org/wiki/Anexo:C%C3%B3digos_de_estado_HTTP' target='_blank'> #{I18n.t("error_#{code}")} </a>"
  end

  def url_for_application(app_name)
    app = Mumukit::Platform.application_for(app_name)
    app.organic_url(Organization.current.name)
  end

  def teacher_info_button(item)
    if current_user&.teacher_here? && item.teacher_info.present?
      %Q{
        <div data-bs-toggle="tooltip" title="#{t :teacher_info}">
          <a
            class="mu-popover"
            data-bs-toggle="popover"
            data-bs-html="true"
            title="#{t :teacher_info}"
            data-bs-placement="bottom"
            data-bs-content="#{html_rescape item.teacher_info_html}">#{fixed_fa_icon('info-circle')}
          </a>
        </div>
      }.html_safe
    end
  end

  def link_to_bibliotheca_guide(guide)
    edit_link_to_bibliotheca { url_for_bibliotheca_guide(guide) }
  end

  def link_to_bibliotheca_exercise(exercise)
    edit_link_to_bibliotheca { "#{url_for_bibliotheca_guide(exercise.guide)}/exercises/#{exercise.bibliotheca_id}" }
  end

  def mail_to_administrator
    mail_to Organization.current.contact_email,
            Organization.current.contact_email,
            subject: I18n.t(:permissions),
            body: permissions_help_email_body(current_user, Organization.current)
  end

  def link_to_profile_terms
    link_to t(:terms_and_conditions), terms_user_path, target: '_blank'
  end

  def link_to_forum_terms
    link_to t(:forum_terms), discussions_terms_path, target: '_blank'
  end

  def link_to_faqs
    link_to t(:faqs), faqs_path, target: '_blank' if faqs_enabled_here?
  end

  def turbolinks_enable_for(exercise)
    %Q{data-turbolinks="#{!exercise.input_kids?}"}.html_safe
  end

  def faqs_enabled_here?
    current_access_mode.faqs_here?
  end

  def profile_enabled_here?
    current_access_mode.profile_here?
  end

  private

  def current_access_mode
    Organization.current.access_mode(current_user)
  end

  def extract_name(named, options)
    case options.delete(:mode)
      when :plain
        named.name
      when :friendly
        named.friendly
      else
        named.navigable_name
    end
  end

  def edit_link_to_bibliotheca
    return unless current_user&.writer?

    url = yield
    link_to fixed_fa_icon('pencil-alt'), url, target: "_blank", 'data-bs-toggle': 'tooltip', title: t(:edit)
  end

  def url_for_bibliotheca_guide(guide)
    "#{url_for_application(:bibliotheca_ui).chomp('/')}/guides/#{guide.slug}"
  end
end
