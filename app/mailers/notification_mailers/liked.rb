module NotificationMailers
  class Liked < NotificationMailers::Base
    attr_accessor :like, :text_owner

    def set_headers(like_id)
      @like = Like.find(like_id)
      @text_owner = @like.target.author.owner

      @headers[:subject] = I18n.t('notifier.liked.liked', :name => @sender.name)
    end
  end
end
