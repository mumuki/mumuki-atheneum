class UsersController < ApplicationController
  include WithUserParams

  before_action :authenticate!, except: :terms
  before_action :set_user!
  skip_before_action :validate_accepted_role_terms!

  def show
    @messages = current_user.messages.to_a
    @watched_discussions = current_user.watched_discussions_in_organization
  end

  def update
    update_and_flash!(:user_data_updated)
    current_user.accept_profile_terms!
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

  def update_preferences
    update_and_flash!(:user_preferences_updated)
    redirect_to preferences_user_path
  end

  def preferences
    @preferences ||= current_user.preferences
  end

  def unsubscribe
    user_id = User.unsubscription_verifier.verify(params[:id])
    User.find(user_id).unsubscribe_from_reminders!

    redirect_to root_path, notice: t(:unsubscribed_successfully)
  end

  def permissible_params
    super << [:avatar_id, :avatar_type, :uppercase_mode]
  end

  private

  def validate_user_profile!
  end

  def set_user!
    @user = current_user
  end

  def update_and_flash!(notice)
    current_user.update_and_notify! user_params
    flash.notice = I18n.t(notice)
  end
end
