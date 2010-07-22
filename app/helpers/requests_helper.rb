module RequestsHelper

  def subscription_mode(profile)
    if diaspora?(profile)
      :friend
    elsif ostatus?(profile)
      :subscribe
    else
      :none
    end
  end

  def diaspora?(profile)
    profile_contains(profile, 'http://joindiaspora.com/seed_location')
  end

  def ostatus?(profile)
    profile_contains(profile, 'http://ostatus.org/schema/1.0/subscribe') 
  end

  def profile_contains(profile, rel)
    profile.links.each{|x|  return true if x.rel == rel}
    false
  end

  def subscription_url(action, profile)
    if action == :subscribe
      profile.links.select{|x| x.rel == 'http://schemas.google.com/g/2010#updates-from'}.first.href
    elsif action == :friend
      profile.links.select{|x| x.rel == 'http://joindiaspora.com/seed_location'}.first.href
    else
      ''
    end
  end

  def relationship_flow(identifier)
    unless identifier.include?( '@')
      return {:friend => identifier}
    end

    f = Redfinger.finger(identifier)
    action = subscription_mode(f)
    url = subscription_url(action, f)

    { action => url }
  end

end
