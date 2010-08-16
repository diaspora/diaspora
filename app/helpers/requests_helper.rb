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
    puts request.host
    if identifier.include?(request.host)
      person = Person.by_webfinger identifier
      action = (person == current_user.person ? :none : :friend)
      url = person.owner.receive_url
    else
      f = Redfinger.finger(identifier)
      action = subscription_mode(f)
      url = subscription_url(action, f)
    end
    { action => url }
  end

end
