# frozen_string_literal: true

module NotificationMailers
  class Mentioned < NotificationMailers::Base
    attr_accessor :post
    delegate :author_name, to: :post, prefix: true

    def set_headers(target_id)
      @post = Mention.find_by_id(target_id).mentions_container

      @headers[:subject] = I18n.t('notifier.mentioned.subject', :name => @sender.name)
      @headers[:in_reply_to] = @headers[:references] = "<#{@post.guid}@#{AppConfig.pod_uri.host}>"
    end
  end
end
