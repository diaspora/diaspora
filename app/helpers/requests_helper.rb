#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


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
    person = Person.by_webfinger identifier
    if person
      action = (person == current_user.person ? :none : :friend)
    end
    { action => person }
  end

end
