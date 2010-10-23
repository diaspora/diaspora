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
        if id == self.person.id
          self.person
        elsif friend = friends.first(:person_id => id)
          friend.person
        else
          visible_people.detect{|x| x.id == id }
        end
      end

      def friends_not_in_aspect( aspect ) 
        Contact.all(:user_id => self.id, :aspect_ids.ne => aspect._id).map{|c| c.person}
      end

      def aspect_by_id( id )
        id = id.to_id
        aspects.detect{|x| x.id == id }
      end

      def aspects_with_post( id )
        self.aspects.find_all_by_post_ids( id.to_id )
      end

      def aspects_with_person person
        contact_for(person).aspects
      end

      def contacts_in_aspects aspects
        aspects.inject([]) do |contacts,aspect|
          contacts | aspect.people
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
