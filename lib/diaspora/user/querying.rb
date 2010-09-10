module Diaspora
  module UserModules
    module Querying
      def visible_posts_from_others(opts ={})
        if opts[:from].class == Person
            Post.where(:person_id => opts[:from].id, :_id.in => self.visible_post_ids)
        elsif opts[:from].class == Group
            Post.where(:_id.in => opts[:from].post_ids) unless opts[:from].user != self
        else
            Post.where(:_id.in => self.visible_post_ids)
        end
      end

      def visible_posts( opts = {} )
        if opts[:by_members_of]
          return raw_visible_posts if opts[:by_members_of] == :all
          group = self.groups.find_by_id( opts[:by_members_of].id )
          group.posts
        end
      end

      def visible_person_by_id( id )
        id = id.to_id
        return self.person if id == self.person.id
        result = friends.detect{|x| x.id == id }
        result = visible_people.detect{|x| x.id == id } unless result
        result
      end

      def group_by_id( id )
        id = id.to_id
        groups.detect{|x| x.id == id }
      end

      def album_by_id( id )
        id = id.to_id
        albums.detect{|x| x.id == id }
      end

      def groups_with_post( id )
        self.groups.find_all_by_post_ids( id.to_id )
      end

      def groups_with_person person
        id = person.id.to_id
        groups.select { |g| g.person_ids.include? id}
      end

      def all_group_ids
        self.groups.all.collect{|x| x.id}
      end
    end
  end
end
