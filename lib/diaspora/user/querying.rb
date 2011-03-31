#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module UserModules
    module Querying

      def find_visible_post_by_id( id, opts={} )
        post = Post.where(:id => id).joins(:contacts).where(:contacts => {:user_id => self.id}).where(opts).first
        post ||= Post.where(:id => id, :author_id => self.person.id).where(opts).first
        post ||= Post.where(:id => id, :public => true).where(opts).first
      end

      def raw_visible_posts(opts = {})
        opts[:type] ||= ['StatusMessage', 'Photo']
        opts[:limit] ||= 20
        opts[:order] ||= 'updated_at DESC'
        opts[:hidden] ||= false
        opts[:order] = '`posts`.' + opts[:order]
        opts[:limit] = opts[:limit].to_i * opts[:page].to_i if opts[:page]

        posts_from_others = Post.joins(:contacts).where( :post_visibilities => {:hidden => opts[:hidden]}, :contacts => {:user_id => self.id})
        posts_from_self = self.person.posts

        if opts[:by_members_of]
          posts_from_others = posts_from_others.joins(:contacts => :aspect_memberships).where(
            :aspect_memberships => {:aspect_id => opts[:by_members_of]})
          posts_from_self = posts_from_self.joins(:aspect_visibilities).where(:aspect_visibilities => {:aspect_id => opts[:by_members_of]})
        end

        post_ids = Post.connection.execute(posts_from_others.select('posts.id').limit(opts[:limit]).order(opts[:order]).to_sql).map{|r| r.first}
        post_ids += Post.connection.execute(posts_from_self.select('posts.id').limit(opts[:limit]).order(opts[:order]).to_sql).map{|r| r.first}

        Post.where(:id => post_ids, :pending => false, :type => opts[:type]).select('DISTINCT `posts`.*').limit(opts[:limit])
      end

      def visible_photos
        raw_visible_posts(:type => 'Photo')
      end

      def contact_for(person)
        return nil unless person
        contact_for_person_id(person.id)
      end
      def aspects_with_post(post_id)
        self.aspects.joins(:aspect_visibilities).where(:aspect_visibilities => {:post_id => post_id})
      end

      def contact_for_person_id(person_id)
        Contact.unscoped.where(:user_id => self.id, :person_id => person_id).first if person_id
      end

      def people_in_aspects(requested_aspects, opts={})
        allowed_aspects = self.aspects & requested_aspects
        person_ids = contacts_in_aspects(allowed_aspects).collect{|contact| contact.person_id}
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
        return self.person.posts.where(:pending => false).order("created_at DESC") if person == self.person
        con = Contact.arel_table
        p = Post.arel_table
        post_ids = []
        if contact = self.contact_for(person)
          post_ids = Post.connection.execute(contact.post_visibilities.select('post_visibilities.post_id').to_sql).map{|r| r.first}
        end
        post_ids += Post.connection.execute(person.posts.where(:public => true).select('posts.id').to_sql).map{|r| r.first}

        Post.where(:id => post_ids, :pending => false).select('DISTINCT `posts`.*').order("posts.created_at DESC")
      end
    end
  end
end
