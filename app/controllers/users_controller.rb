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

  def activity
    @activity = UserStats.stats_for(current_user).activity date_range_params
  end

  def certificates
    @certificates ||= current_user.certificates_in_organization
  end

  def exam_authorizations
    @exam_authorization_requests ||= ExamAuthorizationRequest.where(user: current_user, organization: Organization.current)
  end

  def unsubscribe
    user_id = User.unsubscription_verifier.verify(params[:id])
    User.find(user_id).unsubscribe_from_reminders!

    redirect_to root_path, notice: t(:unsubscribed_successfully)
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

  def date_range_params
    @date_from = params[:date_from].try { |it| Date.parse it }
    to = params[:date_to].try { |it| Date.parse it }
    if @date_from && to
      @date_from.beginning_of_day..(to - 1.day).end_of_day
    else
      nil
    end
  end

  def authorization_minimum_role
    :ex_student
  end
end
