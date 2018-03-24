# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def self.new_report(report_id)
    report = Report.find_by_id(report_id)
    Role.moderators.map {|role| super(report.item_type, report.item_id, report.text, role) }
  end

  def new_report(type, id, reason, role)
    resource = {
      url:    report_index_url,
      type:   I18n.t("notifier.report_email.type.#{type.downcase}"),
      id:     id,
      reason: reason
    }
    person = Person.find(role.person_id)
    return unless person.local?
    user = User.find_by_id(person.owner_id)
    return if user.user_preferences.exists?(email_type: :someone_reported)
    I18n.with_locale(user.language) do
      resource[:email] = user.email
      format(resource)
    end
  end

  private

  def format(resource)
    mail(to: resource[:email], subject: I18n.t("notifier.report_email.subject", type: resource[:type])) do |format|
      format.html { render "report/report_email", locals: {resource: resource} }
      format.text { render "report/report_email", locals: {resource: resource} }
    end
  end
end
