
# frozen_string_literal: true

module Diaspora::Mentionable

  # regex for finding mention markup in plain text:
  #   "message @{user@pod.net} text"
  # it can also contain a name, which gets used as the link text:
  #   "message @{User Name; user@pod.net} text"
  #   will yield "User Name" and "user@pod.net"
  REGEX = /@\{(?:([^\}]+?); )?([^\} ]+)\}/

  # class attribute that will be added to all mention html links
  PERSON_HREF_CLASS = "mention hovercardable"

  def self.mention_attrs(mention_str)
    name, diaspora_id = mention_str.match(REGEX).captures

    [name.try(:strip).presence, diaspora_id.strip]
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
      name, diaspora_id = mention_attrs(match_str)
      person = people.find {|p| p.diaspora_handle == diaspora_id }

      "@#{ERB::Util.h(MentionsInternal.mention_link(person, name, diaspora_id, opts))}"
    }
  end

  # takes a message text and returns an array of people constructed from the
  # contained mentions
  #
  # @param [String] text containing mentions
  # @return [Array<Person>] array of people
  def self.people_from_string(msg_text)
    identifiers = msg_text.to_s.scan(REGEX).map {|match_str| match_str.second.strip }

    identifiers.compact.uniq.map {|identifier| find_or_fetch_person_by_identifier(identifier) }.compact
  end

  # takes a message text and converts mentions for people that are not in the
  # given array to simple markdown links, leaving only mentions for people who
  # will actually be able to receive notifications for being mentioned.
  #
  # @param [String] message text
  # @param [Array] allowed_people ids of people that are allowed to stay
  # @return [String] message text with filtered mentions
  def self.filter_people(msg_text, allowed_people)
    mentioned_ppl = people_from_string(msg_text)

    msg_text.to_s.gsub(REGEX) {|match_str|
      name, diaspora_id = mention_attrs(match_str)
      person = mentioned_ppl.find {|p| p.diaspora_handle == diaspora_id }

      if person && allowed_people.include?(person.id)
        match_str
      else
        "@#{MentionsInternal.profile_link(person, name, diaspora_id)}"
      end
    }
  end

  # Regex to find mentions with new syntax, only used for backporting to old syntax
  NEW_SYNTAX_REGEX = /@\{[^\} ]+\}/

  # replaces new syntax with old syntax, to be compatible with old pods
  # @deprecated remove when most of the posts can handle the new syntax
  def self.backport_mention_syntax(text)
    text.to_s.gsub(NEW_SYNTAX_REGEX) do |match_str|
      _, diaspora_id = mention_attrs(match_str)
      person = find_or_fetch_person_by_identifier(diaspora_id)
      old_syntax = "@{#{person.name.delete('{}')}; #{diaspora_id}}" if person
      old_syntax || match_str
    end
  end

  private_class_method def self.find_or_fetch_person_by_identifier(identifier)
    Person.find_or_fetch_by_identifier(identifier) if Validation::Rule::DiasporaId.new.valid_value?(identifier)
  rescue DiasporaFederation::Discovery::DiscoveryError
    nil
  end

  # inline module for namespacing
  module MentionsInternal
    extend ::PeopleHelper

    # output a formatted mention link as defined by the given arguments.
    # if the display name is blank, falls back to the person's name.
    # @see Diaspora::Mentions#format
    #
    # @param [Person] AR Person
    # @param [String] display name
    # @param [Hash] formatting options
    def self.mention_link(person, display_name, diaspora_id, opts)
      return display_name || diaspora_id unless person.present?

      if opts[:plain_text]
        display_name || person.name
      else
        person_link(person, class: PERSON_HREF_CLASS, display_name: display_name)
      end
    end

    # output a markdown formatted link to the given person with the display name as the link text.
    # if the display name is blank, falls back to the person's name.
    #
    # @param [Person] AR Person
    # @param [String] display name
    # @return [String] markdown person link
    def self.profile_link(person, display_name, diaspora_id)
      return display_name || diaspora_id unless person.present?

      "[#{display_name || person.name}](#{local_or_remote_person_path(person)})"
    end
  end
end
