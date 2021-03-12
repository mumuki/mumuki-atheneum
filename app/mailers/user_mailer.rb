class UserMailer < ApplicationMailer
  include WithCertificateRender

  def welcome_email(user, organization)
    with_locale(user, organization) do
      organization_name = organization.display_name || t(:your_new_organization)
      build_email t(:welcome, name: organization_name), { inline: organization.welcome_email_template }, from: organization.welcome_email_sender
    end
  end

  def we_miss_you_reminder(user, cycles)
    with_locale(user) do
      build_email t(:we_miss_you), "#{cycles.ordinalize}_reminder"
    end
  end

  def no_submissions_reminder(user)
    with_locale(user) do
      build_email t(:start_using_mumuki), 'no_submissions_reminder'
    end
  end

  def delete_account(user)
    with_locale(user) do
      build_email t(:delete_account_mumuki), 'delete_account'
    end
  end

  def certificate(certificate)
    with_locale certificate.user, certificate.organization do
      attachments[certificate.filename] = pdf_for(certificate)
      mail to: certificate.user.email, subject: t(:certificate)
    end
  end

  def with_locale(user, organization = nil, &block)
    @user = user
    @unsubscribe_code = User.unsubscription_verifier.generate(user.id)
    @organization = organization || user.last_organization

    I18n.with_locale(@organization.locale, &block)
  end

  private

  def build_email(subject, template, **options)
    mail options.compact.merge(to: @user.email,
                               subject: subject,
                               content_type: 'text/html',
                               body: render(template))
  end
end
