class HelpController < ApplicationController
  layout -> (c) { request.format == :mobile ? "application" : "with_header_with_footer" }

  def faq
    gon.chatEnabled = AppConfig.chat.enabled?
  end
end
