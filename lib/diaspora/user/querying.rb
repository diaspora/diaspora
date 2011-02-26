#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Querying

      def find_visible_post_by_id( id )
        self.raw_visible_posts.where(:id => id).includes({:person => :profile}, {:comments => {:person => :profile}}, :photos).first
      end

      def raw_visible_posts
        Post.joins(:aspects).where(:pending => false,
                                   :aspects => {:user_id => self.id}).select('DISTINCT `posts`.*')
      end

      def visible_photos
        p = Photo.arel_table
        Photo.joins(:aspects).where(p[:status_message_id].not_eq(nil).or(p[:pending].eq(false))
          ).where(:aspects => {:user_id => self.id}).select('DISTINCT `posts`.*').order("posts.updated_at DESC")
      end

      def visible_posts( opts = {} )
        order = opts.delete(:order)
        order ||= 'created_at DESC'
        opts[:type] ||= ["StatusMessage", "Photo"]

        if (aspect = opts[:by_members_of]) && opts[:by_members_of] != :all
          raw_visible_posts.where(:aspects => {:id => aspect.id}).order(order)
        else
          self.raw_visible_posts.where(opts).order(order)
        end
      end

      def contact_for(person)
        return nil unless person
        contact_for_person_id(person.id)
      end
      def aspects_with_post(post_id)
        self.aspects.joins(:post_visibilities).where(:post_visibilities => {:post_id => post_id})
      end

      def contact_for_person_id(person_id)
        Contact.unscoped.where(:user_id => self.id, :person_id => person_id).first if person_id
      end

      def people_in_aspects(aspects, opts={})
        person_ids = contacts_in_aspects(aspects).collect{|contact| contact.person_id}
        people = Person.where(:id => person_ids)

        if opts[:type] == 'remote'
          people = people.where(:owner_id => nil)
        elsif opts[:type] == 'local'
          people = people.where('`people`.`owner_id` IS NOT NULL')
        end
        people
      end

      def aspects_with_person person
        contact_for(person).aspects
      end

      def contacts_in_aspects aspects
        aspects.inject([]) do |contacts,aspect|
          contacts | aspect.contacts
        end
      end

      def all_aspect_ids
        self.aspects.all.collect{|x| x.id}
      end

      def request_from(person)
        Request.where(:sender_id => person.id,
                      :recipient_id => self.person.id).first
      end

      def posts_from(person)
        asp = Aspect.arel_table
        p = Post.arel_table
        person.posts.includes(:aspects, :comments).where( p[:public].eq(true).or(asp[:user_id].eq(self.id))).select('DISTINCT `posts`.*').order("posts.updated_at DESC")
      end
    end
  end
end
