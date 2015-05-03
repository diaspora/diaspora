class HelpController < ApplicationController
  def faq
    gon.chatEnabled = AppConfig.chat.enabled?
  end
end
