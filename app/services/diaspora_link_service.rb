# frozen_string_literal: true

# Encapsulates logic of processing diaspora:// links
class DiasporaLinkService
  attr_reader :type, :author, :guid

  def initialize(link)
    @link = link.dup
    parse
  end

  def find_or_fetch_entity
    entity_finder.find || fetch_entity
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

  def normalize
    link.gsub!(%r{^web\+diaspora://}, "diaspora://") ||
      link.gsub!(%r{^//}, "diaspora://") ||
      %r{^diaspora://}.match(link) ||
      self.link = "diaspora://#{link}"
  end

  def parse
    normalize
    match = DiasporaFederation::Federation::DiasporaUrlParser::DIASPORA_URL_REGEX.match(link)
    @author = match[1]
    @type = match[2]
    @guid = match[3]
  end
end
