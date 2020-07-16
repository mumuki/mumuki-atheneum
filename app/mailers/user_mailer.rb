class UserMailer < ApplicationMailer

  def we_miss_you_reminder(user, cycles)
    build_email user, :we_miss_you, "#{cycles.ordinalize}_reminder"
  end

  def no_submissions_reminder(user)
    build_email user, :start_using_mumuki, 'no_submissions_reminder'
  end

  private

  def build_email(user, subject, template_name, organization = nil)
    @user = user
    @unsubscribe_code = User.unsubscription_verifier.generate(user.id)
    @organization = organization || user.last_organization

    I18n.with_locale(@organization.locale) do
      mail to: user.email,
           subject: t(subject),
           template_name: template_name
    end
  end
end
