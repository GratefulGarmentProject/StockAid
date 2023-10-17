class SurveyRequestMailer < ApplicationMailer
  def self.attempt(org_request, success)
    SurveyRequestMailer::MailAttempt.new(org_request, success)
  end

  def notify_organization(survey_request, org_request, params)
    @survey_request = survey_request
    @org_request = org_request
    subject = params[:email_subject].gsub("{{organization_name}}", org_request.organization.name)
    @body = params[:email_body].gsub("{{organization_name}}", org_request.organization.name)
    mail to: org_request.organization.email, subject: subject
  end

  def notify_receipt(current_user, survey_request, mail_attempts, params)
    @current_user = current_user
    @survey_request = survey_request
    @mail_attempts = mail_attempts
    @subject = params[:email_subject]
    @body = params[:email_body]
    mail to: current_user.email, subject: "#{Rails.application.config.site_name} Survey Notification Receipt"
  end

  class MailAttempt
    attr_accessor :org_request, :success

    def initialize(org_request, success)
      @org_request = org_request
      @success = success
    end
  end
end
