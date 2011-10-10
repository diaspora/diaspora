module NotificationMailers
  class Liked < NotificationMailers::Base
    attr_accessor :like

    def set_headers(like_id)
      @like = Like.find(like_id)

      @headers[:subject] = I18n.t('notifier.liked.liked', :name => @sender.name)
    end
  end
end