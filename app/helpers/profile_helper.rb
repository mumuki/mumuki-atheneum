module ProfileHelper
  def edit_profile_button
    link_to t(:edit_profile), edit_user_path, class: 'btn btn-success'
  end

  def cancel_edit_profile_button
    link_to t(:cancel), :back, class: 'btn btn-default' if current_user.profile_completed?
  end

  def save_edit_profile_button(form)
    form.submit t(:save), disabled: true, class: 'btn btn-success mu-edit-profile-btn'
  end
end
