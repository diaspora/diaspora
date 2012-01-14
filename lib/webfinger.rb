require File.join(Rails.root, 'lib/hcard')
require File.join(Rails.root, 'lib/webfinger_profile')

class Webfinger
  class WebfingerFailedError < RuntimeError; end
  def initialize(account)
    @account = account.strip.gsub('acct:','').to_s.downcase
    @ssl = true
    Rails.logger.info("event=webfinger status=initialized target=#{account}")
  end

  def self.in_background(account, opts={})
    Resque.enqueue(Jobs::FetchWebfinger, account)
  end

  def fetch
    begin
      person = Person.by_account_identifier(@account)
      if person
        if person.profile
          Rails.logger.info("event=webfinger status=success route=local target=#{@account}")
          return person
        end
      end

      profile_url = get_xrd
      webfinger_profile = get_webfinger_profile(profile_url)
      if person
        person.assign_new_profile_from_hcard(get_hcard(webfinger_profile))
        fingered_person = person
      else
        fingered_person = make_person_from_webfinger(webfinger_profile)
      end

      if fingered_person
        Rails.logger.info("event=webfinger status=success route=remote target=#{@account}")
        fingered_person
      else
        Rails.logger.info("event=webfinger status=failure route=remote target=#{@account}")
        raise WebfingerFailedError.new(@account)
      end
    rescue Exception => e
      Rails.logger.info("event=receive status=abort recipient=#{@account} reason='#{e.message}'")
      nil
    end
  end

  private
  def get_xrd
    begin
      http = Faraday.get xrd_url

      profile_url = webfinger_profile_url(http.body)
      if profile_url
        return profile_url
      else
        raise "no profile URL"
      end
    rescue Exception => e
      if @ssl
        @ssl = false
        retry
      else
        raise e
        raise I18n.t('webfinger.xrd_fetch_failed', :account => @account)
      end
    end
  end


  def get_webfinger_profile(profile_url)
    begin
      http = Faraday.get(profile_url)

    rescue
      raise I18n.t('webfinger.fetch_failed', :profile_url => profile_url)
    end
    return http.body
  end

  def hcard_url
    @wf_profile.hcard
  end

  def get_hcard(webfinger_profile)
    unless webfinger_profile.strip == ""

      @wf_profile = WebfingerProfile.new(@account, webfinger_profile)

      begin
        hcard = Faraday.get(hcard_url)
      rescue
        return I18n.t('webfinger.hcard_fetch_failed', :account => @account)
      end

      HCard.build hcard.body
    else
      nil
    end
  end

  def make_person_from_webfinger(webfinger_profile)
    card = get_hcard(webfinger_profile)
    if card && @wf_profile
      Person.create_from_webfinger(@wf_profile, card)
    end
  end


  ##helpers
  private

  def webfinger_profile_url(xrd_response)
    doc = Nokogiri::XML::Document.parse(xrd_response)
    return nil if doc.namespaces["xmlns"] != "http://docs.oasis-open.org/ns/xri/xrd-1.0"
    swizzle doc.at('Link[rel=lrdd]').attribute('template').value
  end

  def xrd_url
    domain = @account.split('@')[1]
    "http#{'s' if @ssl}://#{domain}/.well-known/host-meta"
  end

  def swizzle(template)
    template.gsub '{uri}', @account
  end
end
