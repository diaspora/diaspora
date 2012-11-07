module GroupsHelper
  
  def good_image_for_group( a_group )
    ( a_group.image_url.nil? ) ? '/images/user/default.png' : a_group.image_url
  end


end
  