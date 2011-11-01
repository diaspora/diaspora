module StreamElementHelper
  def block_user_control(author)
    if user_signed_in?
      link_to block_path(author), :class => "block_button"
    end
  end
end