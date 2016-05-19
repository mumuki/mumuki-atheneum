class ExamAuthorization < ActiveRecord::Base

  belongs_to :user
  belongs_to :exam

  def start!
    update!(started: true, started_at: Time.now)
  end

end
