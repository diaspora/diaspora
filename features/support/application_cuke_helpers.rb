module ApplicationCukeHelpers
  def flash_message_success?
    flash_message(selector: "notice").visible?
  end

  def flash_message_failure?
    flash_message(selector: "error").visible?
  end

  def flash_message_containing?(text)
    flash_message(text: text).should be_visible
  end

  def flash_message(opts={})
    selector = opts.delete(:selector)
    selector &&= "#flash_#{selector}"
    find(selector || '.message', {match: :first}.merge(opts))
  end
end

World(ApplicationCukeHelpers)
