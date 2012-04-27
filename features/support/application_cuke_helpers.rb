module ApplicationCukeHelpers
  def flash_message_success?
    flash_message("notice").visible?
  end

  def flash_message_failure?
    flash_message("error").visible?
  end

  def flash_message_containing?(text)
    flash_message.should have_content(text)
  end

  def flash_message(selector=".message")
    selector = "#flash_#{selector}" unless selector == ".message"
    find(selector)
  end
end

World(ApplicationCukeHelpers)
