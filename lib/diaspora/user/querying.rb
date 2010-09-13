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



module Diaspora
  module UserModules
    module Querying
      def visible_posts_from_others(opts ={})
        if opts[:from].class == Person
            Post.where(:person_id => opts[:from].id, :_id.in => self.visible_post_ids)
        elsif opts[:from].class == Aspect
            Post.where(:_id.in => opts[:from].post_ids) unless opts[:from].user != self
        else
            Post.where(:_id.in => self.visible_post_ids)
        end
      end

      def visible_posts( opts = {} )
        if opts[:by_members_of]
          return raw_visible_posts if opts[:by_members_of] == :all
          aspect = self.aspects.find_by_id( opts[:by_members_of].id )
          aspect.posts
        end
      end

      def visible_person_by_id( id )
        id = id.to_id
        return self.person if id == self.person.id
        result = friends.detect{|x| x.id == id }
        result = visible_people.detect{|x| x.id == id } unless result
        result
      end

      def aspect_by_id( id )
        id = id.to_id
        aspects.detect{|x| x.id == id }
      end

      def album_by_id( id )
        id = id.to_id
        albums.detect{|x| x.id == id }
      end

      def aspects_with_post( id )
        self.aspects.find_all_by_post_ids( id.to_id )
      end

      def aspects_with_person person
        id = person.id.to_id
        aspects.select { |g| g.person_ids.include? id}
      end

      def people_in_aspects aspects
        people = []
        aspects.each{ |aspect|
          people = people | aspect.people
        }
        people
      end

      def all_aspect_ids
        self.aspects.all.collect{|x| x.id}
      end
    end
  end
end
