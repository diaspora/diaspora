# frozen_string_literal: true

module InterimStreamHackinessHelper
  def commenting_disabled?(post)
    return true unless user_signed_in?
    if defined?(@commenting_disabled)
      @commenting_disabled
    elsif defined?(@stream)
      !@stream.can_comment?(post)
    else
      false
    end
  end

  ##### These methods need to go away once we pass publisher object into the partial ######
  def publisher_formatted_text
    if params[:prefill].present?
      params[:prefill]
    elsif defined?(@stream)
      @stream.publisher.prefill
    else
      nil
    end
  end

  def from_group(post)
    if defined?(@stream) && params[:controller] == 'multis'
      @stream.post_from_group(post)
    else
     []
    end
  end
end
