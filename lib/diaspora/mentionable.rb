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
  # @param [Boolean] absolute_links (false) render mentions with absolute links
  # @return [String] message text with filtered mentions
  def self.filter_people(msg_text, allowed_people, absolute_links: false)
    mentioned_ppl = people_from_string(msg_text)

    msg_text.to_s.gsub(REGEX) {|match_str|
      name, diaspora_id = mention_attrs(match_str)
      person = mentioned_ppl.find {|p| p.diaspora_handle == diaspora_id }

      if person && allowed_people.include?(person.id)
        match_str
      else
        "@#{MentionsInternal.profile_link(person, name, diaspora_id, absolute: absolute_links)}"
      end
    }
  end

  private_class_method def self.find_or_fetch_person_by_identifier(identifier)
    Person.find_or_fetch_by_identifier(identifier) if Validation::Rule::DiasporaId.new.valid_value?(identifier)
  rescue DiasporaFederation::Discovery::DiscoveryError
    nil
  end

  # inline module for namespacing
  module MentionsInternal
    extend ERB::Util

    # output a formatted mention link as defined by the given arguments.
    # if the display name is blank, falls back to the person's name.
    # @see Diaspora::Mentions#format
    #
    # @param [Person] AR Person
    # @param [String] display name
    # @param [Hash] formatting options
    def self.mention_link(person, display_name, diaspora_id, opts)
      return display_name || diaspora_id unless person.present?

      display_name ||= person.name
      if opts[:plain_text]
        display_name
      else
        # rubocop:disable Rails/OutputSafety
        remote_or_hovercard_link = Rails.application.routes.url_helpers.person_path(person).html_safe
        "<a data-hovercard=\"#{remote_or_hovercard_link}\" href=\"#{remote_or_hovercard_link}\" " \
          "class=\"#{PERSON_HREF_CLASS}\">#{html_escape_once(display_name)}</a>".html_safe
        # rubocop:enable Rails/OutputSafety
      end
    end

    # output a markdown formatted link to the given person with the display name as the link text.
    # if the display name is blank, falls back to the person's name.
    #
    # @param [Person] AR Person
    # @param [String] display name
    # @param [String] diaspora_id
    # @param [Boolean] absolute (false) render absolute link
    # @return [String] markdown person link
    def self.profile_link(person, display_name, diaspora_id, absolute: false)
      return display_name || diaspora_id unless person.present?

      url_helper = Rails.application.routes.url_helpers
      "[#{display_name || person.name}](#{absolute ? url_helper.person_url(person) : url_helper.person_path(person)})"
    end
  end
end
