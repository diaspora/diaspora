#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Querying

      def find_visible_post_by_id( id )
        self.raw_visible_posts.where(:id => id).first
      end

      def raw_visible_posts
        Post.joins(:aspects).where(:aspects => {:user_id => self.id})
      end

      def visible_posts( opts = {} )
        order = opts.delete(:order)
        order ||= 'created_at DESC'
        opts[:pending] ||= false
        opts[:type] ||= ["StatusMessage","Photo"]

        if opts[:by_members_of] && opts[:by_members_of] != :all
          aspect = opts[:by_members_of] unless opts[:by_members_of].user_id != self.id
          Post.joins(:aspects).where(:aspects => {:id => aspect.id}).order(order)
        else
          self.raw_visible_posts.where(opts).order(order)
        end
      end

      def contact_for(person)
        contact_for_person_id(person.id)
      end

      def contact_for_person_id(person_id)
        Contact.where(:user_id => self.id, :person_id => person_id).first if person_id
      end

      def contacts_not_in_aspect( aspect )
        person_ids = Contact.where(:user_id => self.id, :aspect_ids.ne => aspect.id).collect{|x| x.person_id }
        Person.all(:id.in => person_ids)
      end

      def people_in_aspects(aspects, opts={})
        person_ids = contacts_in_aspects(aspects).collect{|contact| contact.person_id}
        people = Person.where(:id => person_ids)

        if opts[:type] == 'remote'
          people.delete_if{ |p| !p.owner.blank? }
        elsif opts[:type] == 'local'
          people.delete_if{ |p| p.owner.blank? }
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

      def request_for(to_person)
        Request.from(self.person).to(to_person).first
      end

      def posts_from(person)
        public_posts = person.posts.where(:public => true)
        directed_posts = raw_visible_posts.where(:person_id => person.id)
        posts = public_posts | directed_posts
        posts.sort!{|p1,p2| p1.created_at <=> p2.created_at }
      end
    end
  end
end
