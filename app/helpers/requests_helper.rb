module RequestsHelper

  def subscription_mode(profile)
    if diaspora?(profile)
      :friend
    else
      :none 
    end
  end

  def diaspora?(profile)
    profile_contains(profile, 'http://joindiaspora.com/seed_location')
  end

  def profile_contains(profile, rel)
    profile.links.each{|x|  return true if x.rel == rel}
    false
  end

  def subscription_url(action, profile)
    if action == :friend
      profile.links.select{|x| x.rel == 'http://joindiaspora.com/seed_location'}.first.href
    else
      nil
    end
  end

  def relationship_flow(identifier)
    action = :none
    url = nil
    local_person = Person.by_webfinger identifier
    if local_person
      action = (local_person == current_user.local_person ? :none : :friend)
      url = local_person.receive_url
    elsif !(identifier.include?(request.host) || identifier.include?("localhost"))
      f = Redfinger.finger(identifier)
      action = subscription_mode(f)
      url = subscription_url(action, f)
    end
    { action => url }
  end

end
