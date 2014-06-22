
module Diaspora::Mentionable

  # regex for finding mention markup in plain text
  # ex.
  #   "message @{User Name; user@pod.net} text"
  #   will yield "User Name" and "user@pod.net"
  REGEX = /(@\{([^\}]+)\})/

  # class attribute that will be added to all mention html links
  PERSON_HREF_CLASS = "mention hovercardable"

  def self.mention_attrs(mention_str)
    mention = mention_str.match(REGEX)[2]
    del_pos = mention.rindex(/;/)

    name   = mention[0..(del_pos-1)].strip
    handle = mention[(del_pos+1)..-1].strip

    [name, handle]
  end

  # takes a message text and returns the text with mentions in (html escaped)
  # plain text or formatted with html markup linking to user profiles.
  # default is html output.
  #
  # @param [String] text containing mentions
  # @param [Array<Person>] list of mentioned people
  # @param [Hash] formatting options
  # @return [String] formatted message
  def self.format(msg_text, people, opts={})
    people = [*people]

    msg_text.to_s.gsub(REGEX) {|match_str|
      name, handle = mention_attrs(match_str)
      person = people.find {|p| p.diaspora_handle == handle }

      ERB::Util.h(MentionsInternal.mention_link(person, name, opts))
    }
  end

  # takes a message text and returns an array of people constructed from the
  # contained mentions
  #
  # @param [String] text containing mentions
  # @return [Array<Person>] array of people
  def self.people_from_string(msg_text)
    identifiers = msg_text.to_s.scan(REGEX).map do |match_str|
      _, handle = mention_attrs(match_str.first)
      handle
    end

    return [] if identifiers.empty?
    Person.where(diaspora_handle: identifiers)
  end

  # takes a message text and converts mentions for people that are not in the
  # given aspects to simple markdown links, leaving only mentions for people who
  # will actually be able to receive notifications for being mentioned.
  #
  # @param [String] message text
  # @param [User] aspect owner
  # @param [Mixed] array containing aspect ids or "all"
  # @return [String] message text with filtered mentions
  def self.filter_for_aspects(msg_text, user, *aspects)
    aspect_ids = MentionsInternal.get_aspect_ids(user, *aspects)

    mentioned_ppl = people_from_string(msg_text)
    aspects_ppl = AspectMembership.where(aspect_id: aspect_ids)
                                  .includes(:contact => :person)
                                  .map(&:person)

    msg_text.to_s.gsub(REGEX) {|match_str|
      name, handle = mention_attrs(match_str)
      person = mentioned_ppl.find {|p| p.diaspora_handle == handle }
      mention = MentionsInternal.profile_link(person, name) unless aspects_ppl.include?(person)

      mention || match_str
    }
  end

  private

  # inline module for namespacing
  module MentionsInternal
    extend ::PeopleHelper

    # output a formatted mention link as defined by the given options,
    # use the fallback name if the person is unavailable
    # @see Diaspora::Mentions#format
    #
    # @param [Person] AR Person
    # @param [String] fallback name
    # @param [Hash] formatting options
    def self.mention_link(person, fallback_name, opts)
      return fallback_name unless person.present?

      if opts[:plain_text]
        person.name
      else
        person_link(person, class: PERSON_HREF_CLASS)
      end
    end

    # output a markdown formatted link to the given person or the given fallback
    # string, in case the person is not present
    #
    # @param [Person] AR Person
    # @param [String] fallback name
    # @return [String] markdown person link
    def self.profile_link(person, fallback_name)
      return fallback_name unless person.present?

      "[#{person.name}](#{local_or_remote_person_path(person)})"
    end

    # takes a user and an array of aspect ids or an array containing "all" as
    # the first element. will do some checking on ids and return them in an array
    # in case of "all", returns an array with all the users aspect ids
    #
    # @param [User] owner of the aspects
    # @param [Array] aspect ids or "all"
    # @return [Array] aspect ids
    def self.get_aspect_ids(user, *aspects)
      return [] if aspects.empty?

      if (!aspects.first.is_a?(Integer)) && aspects.first.to_s == 'all'
        return user.aspects.pluck(:id)
      end

      ids = aspects.reject {|id| Integer(id) == nil } # only numeric

      #make sure they really belong to the user
      user.aspects.where(id: ids).pluck(:id)
    end
  end

end
