# frozen_string_literal: true

module ApplicationCukeHelpers
  def flash_message_success?
    flash_message(selector: "success").visible?
  end

  def flash_message_failure?
    flash_message(selector: "danger").visible?
  end

  def flash_message_alert?
    flash_message(selector: "danger").visible?
  end

  def flash_message_containing?(text)
    expect(flash_message(text: text)).to be_visible
  end

  def flash_message(opts={})
    selector = opts.delete(:selector)
    selector &&= ".alert-#{selector}"
    find(selector || ".flash-message", {match: :first}.merge(opts))
  end

  def confirm_form_validation_error(element)
    expect(page.evaluate_script("$('#{element}')[0].checkValidity();")).to be false
  end

  def check_fields_validation_error(field_list)
    field_list.split(",").each do |f|
      confirm_form_validation_error("input##{f.strip}")
    end
  end
end

World(ApplicationCukeHelpers)
