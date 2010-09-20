#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


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
    person = nil
    puts identifier
    person = Person.by_webfinger identifier
    if person
      action = (person == current_user.person ? :none : :friend)
    end
    { action => person }
  end

end
