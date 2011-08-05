module ServicesHelper
  GSUB_THIS = "FIUSDHVIUSHDVIUBAIUHAPOIUXJM"
  def contact_proxy(friend)
    friend.contact || Contact.new(:person => friend.person)
  end

  # This method memoizes the facebook invite form in order to avoid the overhead of rendering it on every post.
  # @param [ServiceUser] friend
  # @return [String] The HTML for the form.
  def facebook_invite_form friend
    @form ||= controller.render_to_string(
      :partial => 'services/facebook_invite',
      :locals => {:uid => GSUB_THIS})
    @form.gsub(GSUB_THIS, friend.uid).html_safe
  end
end
