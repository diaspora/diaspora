class FeaturedUsersStream < BaseStream
  def title
    "Featured users doing cool stuff!"
  end

  def link(opts={})
    Rails.application.routes.url_helpers.featured_path(opts)
  end

  def contacts_title
    "This week's featured users"
  end

  def contacts_link
    Rails.application.routes.url_helpers.featured_users_path
  end

  def contacts_link_title
    I18n.translate('aspects.selected_contacts.view_all_featured_users')
  end

  def posts
    Post.all_public.where(:author_id => people.map{|x| x.id}).for_a_stream(max_time, order)
  end

  def people
   Person.featured_users 
  end
end
