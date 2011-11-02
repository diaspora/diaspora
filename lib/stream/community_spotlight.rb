class Stream::CommunitySpotlight < Stream::Base
  def title
    "Community Spotlight doing cool stuff!"
  end

  def link(opts={})
    Rails.application.routes.url_helpers.spotlight_path(opts)
  end

  def contacts_title
    "This week's community spotlight"
  end

  def contacts_link
    Rails.application.routes.url_helpers.community_spotlight_path
  end

  def contacts_link_title
    I18n.translate('aspects.selected_contacts.view_all_community_spotlight')
  end

  def posts
    Post.all_public.where(:author_id => people.map{|x| x.id})
  end

  def people
   Person.community_spotlight
  end
end
