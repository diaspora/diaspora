module NotificationMailers
  class MentionedInComment < NotificationMailers::Base
    attr_reader :comment

    def set_headers(target_id) # rubocop:disable Style/AccessorMethodName
      @comment = Mention.find_by_id(target_id).mentions_container

      @headers[:subject] = I18n.t("notifier.mentioned.subject", name: @sender.name)
    end
  end
end
