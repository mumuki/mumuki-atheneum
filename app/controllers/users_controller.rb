class UsersController < ApplicationController
  include WithUserParams

  before_action :authenticate!
  before_action :set_user!
  skip_before_action :verify_email!

  def show
    @messages = current_user.messages.to_a
    @watched_discussions = current_user.watched_discussions_in_organization
  end

  def update
    current_user.update_and_notify! user_params
    redirect_to root_path, notice: I18n.t(:user_data_updated)
  end

  def unsubscribe
    User.for_unsubscribe_verifier(params[:id]).unsubscribe_from_reminders!

    redirect_to root_path, notice: t(:unsubscribed_successfully)
  end

  def verify_email
    User.for_verify_email_verifier(params[:id]).verify_email!

    redirect_to root_path, notice: t(:email_verified_successfully)
  end

  def request_email_verification
    UserMailer.verification_email(@user).deliver_later

    redirect_to user_path, notice: t(:email_verification_sent)
  end

  private

  def validate_user_profile!
  end

  def set_user!
    @user = current_user
  end
end
