module StreamElementHelper
  def block_user_control(author)
    if user_signed_in?
      button_to "block a mofo", blocks_path(:block => {:person_id => author.id}), :class => "block_button"
    end
  end
end