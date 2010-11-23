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
        opts[:pending] ||= false
        opts[:_type] ||= ["StatusMessage","Photo"]

        if opts[:by_members_of] && opts[:by_members_of] != :all
          aspect = self.aspects.find_by_id( opts[:by_members_of].id )
          aspect.posts.find_all_by_pending_and__type(opts[:pending], opts[:_type], :order => opts[:order])
        else
          self.raw_visible_posts.all(opts)
        end
      end

      def visible_person_by_id( id )
        id = id.to_id
        if id == self.person.id
          self.person
        elsif contact = contacts.first(:person_id => id)
          contact.person
        else
          visible_people.detect{|x| x.id == id }
        end
      end

      def my_posts
        Post.where(:diaspora_handle => person.diaspora_handle)
      end

      def contact_for(person)
        id = person.id
        contact_for_person_id(id) 
      end

      def contact_for_person_id(person_id)
        contacts.first(:person_id => person_id.to_id) if person_id

      end

      def contacts_not_in_aspect( aspect ) 
        person_ids = Contact.all(:user_id => self.id, :aspect_ids.ne => aspect._id).collect{|x| x.person_id }
        Person.all(:id.in => person_ids)
      end

      def person_objects(contacts = self.contacts)
        person_ids = contacts.collect{|x| x.person_id} 
        Person.all(:id.in => person_ids)
      end

      def people_in_aspects(aspects)
        person_ids = contacts_in_aspects(aspects).collect{|contact| contact.person_id}
        Person.all(:id.in => person_ids)
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
          contacts | aspect.contacts
        end
      end

      def all_aspect_ids
        self.aspects.all.collect{|x| x.id}
      end

      def request_for(to_person)
        Request.from(self.person).to(to_person).first
      end
    end
  end
end
