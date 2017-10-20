# frozen_string_literal: true

module NotificationMailers
  class Reshared < NotificationMailers::Base
    attr_accessor :reshare

    delegate :root, to: :reshare, prefix: true

    def set_headers(reshare_id)
      @reshare = Reshare.find(reshare_id)

      @headers[:subject] = I18n.t('notifier.reshared.reshared', :name => @sender.name)
      @headers[:in_reply_to] = @headers[:references] = "<#{@reshare.root_guid}@#{AppConfig.pod_uri.host}>"
    end
  end
end
