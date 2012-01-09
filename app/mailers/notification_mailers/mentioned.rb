module NotificationMailers
  class Mentioned < NotificationMailers::Base
    attr_accessor :post, :text_owner

    def set_headers(target_id)
      @post = Mention.find_by_id(target_id).post
      @text_owner = @post.author.owner

      @headers[:subject] = I18n.t('notifier.mentioned.subject', :name => @sender.name)
    end
  end
end
