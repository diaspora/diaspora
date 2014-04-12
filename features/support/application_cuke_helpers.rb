module ApplicationCukeHelpers
  def flash_message_success?
    flash_message(selector: "notice").visible?
  end

  def flash_message_failure?
    flash_message(selector: "error").visible?
  end

  def flash_message_alert?
    flash_message(selector: "alert").visible?
  end

  def flash_message_containing?(text)
    flash_message(text: text).should be_visible
  end

  def flash_message(opts={})
    selector = opts.delete(:selector)
    selector &&= "#flash_#{selector}"
    find(selector || '.message', {match: :first}.merge(opts))
  end

  def confirm_form_validation_error(element)
    is_invalid = page.evaluate_script("$('#{element}').is(':invalid')")
    is_invalid.should be_true
  end

  def check_fields_validation_error(field_list)
    field_list.split(',').each do |f|
      confirm_form_validation_error('input#'+f.strip)
    end
  end

end

World(ApplicationCukeHelpers)
