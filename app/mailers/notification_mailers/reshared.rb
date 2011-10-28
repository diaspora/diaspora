module NotificationMailers
  class Reshared < NotificationMailers::Base
    attr_accessor :reshare, :text_owner

    def set_headers(reshare_id)
      @reshare = Reshare.find(reshare_id)
      @text_owner = @reshare.root.author.owner

      @headers[:subject] = I18n.t('notifier.reshared.reshared', :name => @sender.name)
    end
  end
end
