class PostReportMailer < ActionMailer::Base
  default :from => AppConfig.mail.sender_address

  def new_report
    Role.admins.each do |role|
      email = User.find_by_id(role.person_id).email
      format(email).deliver
    end
  end

  private
    def format(email)
      mail(to: email, subject: I18n.t('notifier.post_report_email.subject')) do |format|
        format.text { render 'post_report/post_report_email' }
        format.html { render 'post_report/post_report_email' }
      end
    end
end
