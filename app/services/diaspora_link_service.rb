# frozen_string_literal: true

# Encapsulates logic of processing diaspora:// links
class DiasporaLinkService
  attr_reader :type, :author, :guid

  def initialize(link)
    @link = link.dup
    parse
  end

  def find_or_fetch_entity
    if type && guid
      entity_finder.find || fetch_entity
    elsif author
      find_or_fetch_person
    end
  end

  private

  attr_accessor :link

  def fetch_entity
    DiasporaFederation::Federation::Fetcher.fetch_public(author, type, guid)
    entity_finder.find
  rescue DiasporaFederation::Federation::Fetcher::NotFetchable
    nil
  end

  def entity_finder
    @entity_finder ||= Diaspora::EntityFinder.new(type, guid)
  end

  def find_or_fetch_person
    Person.find_or_fetch_by_identifier(author)
  rescue DiasporaFederation::Discovery::DiscoveryError
    nil
  end

  def normalize
    link.gsub!(%r{^web\+diaspora://}, "diaspora://") ||
      link.gsub!(%r{^//}, "diaspora://") ||
      %r{^diaspora://}.match(link) ||
      self.link = "diaspora://#{link}"
  end

  def parse
    normalize
    match = DiasporaFederation::Federation::DiasporaUrlParser::DIASPORA_URL_REGEX.match(link)
    if match
      @author, @type, @guid = match.captures
    else
      @author = %r{^diaspora://(#{Validation::Rule::DiasporaId::DIASPORA_ID_REGEX})$}u.match(link)&.captures&.first
    end
  end
end
