require File.join(Rails.root, 'lib/hcard')
require File.join(Rails.root, 'lib/webfinger_profile')

class Webfinger
  attr_accessor :host_meta_xrd, :webfinger_profile_xrd, 
                :webfinger_profile, :hcard, :hcard_xrd, :person, 
                :account, :ssl

  def initialize(account)
    self.account = account 
    self.ssl = true
    Rails.logger.info("event=webfinger status=initialized target=#{account}")
  end


  def fetch
    return person if existing_person_with_profile?
    create_or_update_person_from_webfinger_profile!
  end

  def self.in_background(account, opts={})
    Resque.enqueue(Jobs::FetchWebfinger, account)
  end

  #everything below should be private I guess
  def account=(str)
    @account = str.strip.gsub('acct:','').to_s.downcase
  end

  def get(url)
    Rails.logger.info("Getting: #{url} for #{account}")
    begin 
      Faraday.get(url).body
    rescue Exception => e
      Rails.logger.info("Failed to fetch: #{url} for #{account}; #{e.message}")
      raise e
    end
  end

  def existing_person_with_profile?
    cached_person.present? && cached_person.profile.present?
  end

  def cached_person
    self.person ||= Person.by_account_identifier(account)
  end

  def create_or_update_person_from_webfinger_profile!
    if person #update my profile please
      person.assign_new_profile_from_hcard(self.hcard)
    else
      person = make_person_from_webfinger
    end
    Rails.logger.info("event=webfinger status=success route=remote target=#{@account}")
    person
  end

  #this tries the xrl url with https first, then falls back to http
  def host_meta_xrd
    begin
      get(host_meta_url)
    rescue Exception => e
      if self.ssl
        self.ssl = false
        retry
      else
        raise I18n.t('webfinger.xrd_fetch_failed', :account => account)
      end
    end
  end


  def hcard
    @hcard ||= HCard.build(hcard_xrd)
  end

  def webfinger_profile
    @webfinger_profile ||= WebfingerProfile.new(account, webfinger_profile_xrd)
  end

  def hcard_url
    self.webfinger_profile.hcard
  end

  def webfinger_profile_url
    doc = Nokogiri::XML::Document.parse(self.host_meta_xrd)
    return nil if doc.namespaces["xmlns"] != "http://docs.oasis-open.org/ns/xri/xrd-1.0"
    swizzle doc.at('Link[rel=lrdd]').attribute('template').value
  end

  def webfinger_profile_xrd
    @webfinger_profile_xrd ||= get(webfinger_profile_url)
  end

  def hcard_xrd
    @hcard_xrd ||= get(hcard_url)
  end

  def make_person_from_webfinger
    Person.create_from_webfinger(webfinger_profile, hcard)
  end

  def host_meta_url
    domain = account.split('@')[1]
    "http#{'s' if self.ssl}://#{domain}/.well-known/host-meta"
  end

  def swizzle(template)
    template.gsub('{uri}', account)
  end
end
