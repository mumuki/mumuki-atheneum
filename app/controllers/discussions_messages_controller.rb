class DiscussionsMessagesController < AjaxController
  include WithAuthorization
  include WithUserDiscussionValidation

  before_action :set_discussion!, only: [:create, :destroy]
  before_action :authorize_user!, only: [:destroy]
  before_action :authorize_moderator!, only: [:question, :approve]
  before_action :authorize_admin!, only: [:restore]

  def create
    @discussion.submit_message! message_params, current_user
    redirect_back(fallback_location: root_path)
  end

  def destroy
    current_message.disable_by! current_user
    redirect_back(fallback_location: root_path)
  end

  def approve
    current_message.toggle_approved!
    head :ok
  end

  def question
    current_message.toggle_not_actually_a_question!
    head :ok
  end

  def restore
    current_message.restore!
    redirect_back(fallback_location: root_path)
  end

  private

  def set_discussion!
    @discussion ||= Discussion.find_by(id: params[:discussion_id])
  end

  def authorize_user!
    current_message.authorize! current_user
  end

  def current_message
    @message ||= Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
