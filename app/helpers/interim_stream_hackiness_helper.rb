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

  def publisher_prefill_text
    if params[:prefill].present?
      params[:prefill]
    elsif defined?(@stream)
      @stream.publisher_prefill_text
    else
      nil
    end
  end

  def from_group(post)
    if defined?(@stream) && params[:controller]== 'soups'
      @stream.post_from_group(post)
    else
     [] 
    end
  end

  def what_soup_sentence(post)
    from_group(post).map{|x| x.to_s.gsub("_soup", '').gsub('_',' ').titleize}.to_sentence
  end
end
