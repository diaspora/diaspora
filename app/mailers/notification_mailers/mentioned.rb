module NotificationMailers
  class Mentioned < NotificationMailers::Base
    attr_accessor :post
    delegate :author_name, to: :post, prefix: true

    def set_headers(target_id)
      @post = Mention.find_by_id(target_id).post

      @headers[:subject] = I18n.t('notifier.mentioned.subject', :name => @sender.name)
    end
  end
end
