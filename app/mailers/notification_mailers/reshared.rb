module NotificationMailers
  class Reshared < NotificationMailers::Base
    attr_accessor :reshare
    
    delegate :root, to: :reshare, prefix: true

    def set_headers(reshare_id)
      @reshare = Reshare.find(reshare_id)

      @headers[:subject] = I18n.t('notifier.reshared.reshared', :name => @sender.name)
    end
  end
end
