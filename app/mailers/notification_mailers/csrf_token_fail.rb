# frozen_string_literal: true

module NotificationMailers
  class CsrfTokenFail < NotificationMailers::Base
    def set_headers
      @headers[:subject] = I18n.t("notifier.csrf_token_fail.subject", name: @recipient.name)
    end
  end
end
