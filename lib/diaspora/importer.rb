#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora

  class Importer
    def initialize(strategy)
      self.class.send(:include, strategy)
    end
    
    def commit(user, person, aspects, people, posts, contacts, opts = {})
      filter = verify_and_clean(user, person, people, aspects, posts, contacts)
  
      #assume data is good
      
      # to go 
      user.email = opts[:email]
      user.password= opts[:password]
      user.password_confirmation = opts[:pasword_confirmation]

     
     
      user.person = person


      user.person.diaspora_handle = opts[:diaspora_handle] 
      
      user.visible_post_ids = filter[:whitelist].keys

      #user.friend_ids =       
      user.visible_person_ids = people.collect{ |x| x.id }

      
      posts.each do |post|
        post.save! if filter[:unknown].include? post.id
      end



      aspects.each do |aspect|
        user.aspects << aspect
      end

      people.each do |p|
        p.save! if filter[:people].include? p.id.to_s
      end

      contacts.each do |contact|
        contact.user = user

        user.friends << contact
        contact.save!
      end


      puts user.persisted?

      puts user.inspect
      user.save(:validate => false)


    end

    def assign_aspect_ids(contacts, aspects)
      a_hash = {}
      aspects.each{|x| a_hash[x.name]=x.id}

      contacts.each do |contact|
        contact.aspect_names.each  do |x|
          contact.aspect_ids << a_hash[x]
        end
        contact.aspect_names = nil
      end


    end

    ### verification (to be module) ################

    def verify_and_clean(user, person, people, aspects, posts, contacts)
      verify_user(user)
      verify_person_for_user(user, person)
      filters = filter_posts(posts, person)
      clean_aspects(aspects, filters[:whitelist])
      filters[:all_person_ids] = people.collect{ |x| x.id.to_id }

      raise "incorrect number of contacts" unless verify_contacts(contacts, filters[:all_person_ids])
      assign_aspect_ids(contacts, aspects)
      filters[:people] = filter_people(people)
      filters  
    end

    def verify_contacts(contacts, person_ids)
      return false if contacts.count != person_ids.count
      contacts.all?{|x| person_ids.include?(x.person_id)} 
    end
 
    def verify_user(user)
      User.find_by_id(user.id).nil? ? true : raise("User already exists!")
    end

    def verify_person_for_user(user, person)
      local_person = Person.find_by_id(person.id)
      if local_person
        unless user.encryption_key.public_key.to_s == local_person.public_key.to_s
          raise "local person found with different owner" 
        end
      end
      true
    end


    def filter_people(people)
      person_ids = people.collect{|x| x.id}
      people_from_db = Person.find_all_by_id(person_ids)  #this query should be limited to only return person_id
      person_ids = person_ids - people_from_db.collect{ |x| x.id }

      person_hash = {}
      person_ids.each{|x| person_hash[x.to_s] = true }  
      person_hash
    end

    def filter_posts(posts, person)
      post_ids = posts.collect{|x| x.id}
      posts_from_db = Post.find_all_by_id(post_ids)  #this query should be limited to only return post id and owner id
 
      unknown_posts = post_ids - posts_from_db.collect{|x| x.id}

      posts_from_db.delete_if{|x| x.person_id == person.id}
      unauthorized_post_ids = posts_from_db.collect{|x| x.id}
      post_whitelist = post_ids - unauthorized_post_ids

      unknown = {}
      unknown_posts.each{|x| unknown[x.to_s] = true }
      
      whitelist = {}
      post_whitelist.each{|x| whitelist[x.to_s] = true }
      
      return {
          :unknown => unknown,
          :whitelist => whitelist }
    end


    def clean_aspects(aspects, whitelist)
      aspects.each do |aspect|
        aspect.post_ids.delete_if{ |x| !whitelist.include? x.to_s }
      end
    end
  end

  module Parsers
    module XML
      def execute(xml, opts = {})
        doc = Nokogiri::XML.parse(xml)

        user, person = parse_user_and_person(doc)
        aspects = parse_aspects(doc)
        contacts = parse_contacts(doc)
        people = parse_people(doc)
        posts = parse_posts(doc)
      
        user
        commit(user, person, aspects, people, posts, contacts, opts)
      end

      def parse_user_and_person(doc)
        user = User.new
        user_doc = doc.xpath('/export/user')
        user.username = user_doc.xpath('//user/username').text
        user.serialized_private_key=  user_doc.xpath('//user/serialized_private_key').text
        person = Person.from_xml(user_doc.xpath('//user/person').to_s)
        [user, person]
      end

      def parse_aspects(doc)
       aspects = []
        aspect_doc = doc.xpath('/export/aspects/aspect')

        aspect_doc.each do |x| 
          a = Nokogiri::XML.parse(x.to_s)

          aspect = Aspect.new
          aspect.name = a.xpath('/aspect/name').text
          aspect.post_ids = a.xpath('/aspect/post_ids/post_id').collect{ |x| x.text.to_id }
          aspects << aspect
        end
        aspects
      end

      def parse_people(doc)
        people_doc = doc.xpath('/export/people/person')
        people_doc.inject([]) do |people,curr|
          people << Person.from_xml(curr.to_s)
        end
      end

      def parse_contacts(doc)
        contacts = []
        contact_doc = doc.xpath('/export/contacts/contact') 

        contact_doc.each do |x|
          contact = Contact.new
          contact.person_id = x.xpath("person_id").text.to_id
          contact.aspect_names = x.xpath('aspects/aspect/name').collect{ |x| x.text}
          contacts << contact
        end
        contacts
      end

      def parse_posts(doc)
        post_doc = doc.xpath('/export/posts/status_message')
        post_doc.inject([]) do |posts,curr|
          posts << StatusMessage.from_xml(curr.to_s)
        end
      end

    end

  end
end
