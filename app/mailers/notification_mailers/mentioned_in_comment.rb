# frozen_string_literal: true

module NotificationMailers
  class MentionedInComment < NotificationMailers::Base
    attr_reader :comment

    def set_headers(target_id) # rubocop:disable Naming/AccessorMethodName
      @comment = Mention.find_by_id(target_id).mentions_container

      @headers[:in_reply_to] = @headers[:references] = "<#{@comment.parent.guid}@#{AppConfig.pod_uri.host}>"
      @headers[:subject] = I18n.t("notifier.mentioned.subject", name: @sender.name)
    end
  end
end
