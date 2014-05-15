class ReportMailer < ActionMailer::Base
  default :from => AppConfig.mail.sender_address

  def new_report(type, id)
    resource = {
      :url => report_index_url,
      :type => I18n.t('notifier.report_email.type.' + type),
      :id => id
    }
    Role.admins.each do |role|
      user = User.find_by_id(role.person_id)
      unless user.user_preferences.exists?(:email_type => :someone_reported)
        resource[:email] = user.email
        format(resource).deliver
      end
    end
  end

  private
    def format(resource)
      mail(to: resource[:email], subject: I18n.t('notifier.report_email.subject', :type => resource[:type])) do |format|
        format.html { render 'report/report_email', :locals => { :resource => resource } }
        format.text { render 'report/report_email', :locals => { :resource => resource } }
      end
    end
end
