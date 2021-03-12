class UsersController < ApplicationController
  include WithUserParams

  before_action :authenticate!, except: :terms
  before_action :set_user!
  skip_before_action :validate_accepted_role_terms!

  def update
    current_user.update_and_notify! user_params
    current_user.accept_profile_terms!
    flash.notice = I18n.t(:user_data_updated)
    redirect_after! :profile_completion, fallback_location: user_path
  end

  def accept_profile_terms
    current_user.accept_profile_terms!
    flash.notice = I18n.t(:terms_accepted)
    redirect_after! :terms_acceptance, fallback_location: root_path
  end

  def terms
    @profile_terms ||= Term.profile_terms_for(current_user)
  end

  def messages
    @messages ||= current_user.messages_in_organization
  end

  def discussions
    @watched_discussions = current_user.watched_discussions_in_organization
  end

  def certificates
    @certificates ||= current_user.certificates_in_organization
  end

  def unsubscribe
    user_id = User.unsubscription_verifier.verify(params[:id])
    User.find(user_id).unsubscribe_from_reminders!

    redirect_to root_path, notice: t(:unsubscribed_successfully)
  end

  def delete_request
  end

  def send_delete_confirmation_email
    current_user.generate_delete_account_token!
    UserMailer.delete_account(current_user).deliver_now
    redirect_to delete_request_user_path
  end

  def delete_confirmation
    redirect_to delete_confirmation_invalid_user_path unless @user.delete_account_token_matches? params[:token]
  end

  def delete_confirmation_invalid
  end

  def disable
    current_user.disable!
    redirect_to root_path
  end

  def permissible_params
    super << [:avatar_id, :avatar_type]
  end

  private

  def validate_user_profile!
  end

  def set_user!
    @user = current_user
  end

end
