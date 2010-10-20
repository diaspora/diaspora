#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Querying

      def find_visible_post_by_id( id )
        self.raw_visible_posts.find id.to_id
      end

      def visible_posts( opts = {} )
        opts[:order] ||= 'created_at DESC'
        if opts[:by_members_of]
          return raw_visible_posts if opts[:by_members_of] == :all
          aspect = self.aspects.find_by_id( opts[:by_members_of].id )
          aspect.posts
        else
          self.raw_visible_posts.all(opts)
        end
      end

      def visible_person_by_id( id )
        id = id.to_id
        return self.person if id == self.person.id
        result = friends.detect{|x| x.id == id }
        result = visible_people.detect{|x| x.id == id } unless result
        result
      end

      def friends_not_in_aspect( aspect )
        Person.all(:id.in => self.friend_ids, :id.nin => aspect.person_ids)
      end

      def aspect_by_id( id )
        id = id.to_id
        aspects.detect{|x| x.id == id }
      end

      def find_friend_by_id(id)
        id = id.to_id
        friends.detect{|x| x.id == id }
      end

      def aspects_with_post( id )
        self.aspects.find_all_by_post_ids( id.to_id )
      end

      def aspects_with_person person
        aspects.all(:person_ids => person.id)
      end

      def people_in_aspects aspects
        aspects.inject([]) do |found_people,aspect|
          found_people | aspect.people
        end
      end

      def all_aspect_ids
        self.aspects.all.collect{|x| x.id}
      end

      def albums_by_aspect aspect
        aspect == :all ? raw_visible_posts.find_all_by__type("Album") : aspect.posts.find_all_by__type("Album")
      end
    end
  end
end
