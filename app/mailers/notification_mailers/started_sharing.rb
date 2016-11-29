module NotificationMailers
  class StartedSharing < NotificationMailers::Base
    def set_headers(*_args) # rubocop:disable Style/AccessorMethodName
      @headers[:subject] = I18n.t("notifier.started_sharing.subject", name: @sender.name)
    end
  end
end
