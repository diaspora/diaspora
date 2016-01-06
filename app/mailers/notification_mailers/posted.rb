module NotificationMailers
  class Posted < NotificationMailers::Base
    attr_accessor :post
    delegate :author_name, to: :post, prefix: true

    def set_headers(target_id)
      @post = Post.find_by_id(target_id)

      @headers[:subject] = I18n.t("notifier.posted.subject", name: @sender.name)
    end
  end
end
