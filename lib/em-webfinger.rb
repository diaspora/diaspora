require File.join(Rails.root, 'lib/hcard')
require File.join(Rails.root, 'lib/webfinger_profile')

class EMWebfinger
  TIMEOUT = 5
  REDIRECTS = 3
  OPTS = {:timeout => TIMEOUT, :redirects => REDIRECTS}
  def initialize(account)
    @account = account.strip.gsub('acct:','').to_s
    @ssl = true 
    Rails.logger.info("event=EMWebfinger status=initialized target=#{account}")
    # Raise an error if identifier has a port number 
    #raise "Identifier is invalid" if(@account.strip.match(/\:\d+$/))
    # Raise an error if identifier is not a valid email (generous regexp)
    #raise "Identifier is invalid" if !(@account=~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/)
  end 

  def fetch
    person = Person.by_account_identifier(@account)
    if person
      Rails.logger.info("event=EMWebfinger status=local target=#{@account}")
      return person
    else
      Rails.logger.info("event=EMWebfinger status=remote target=#{@account}")

      profile_url = get_xrd
      webfinger_profile = get_webfinger_profile(profile_url) 
      fingered_person = make_person_from_webfinger(webfinger_profile) 
      fingered_person
    end
  end

  private
  def get_xrd
    begin
      http = RestClient.get xrd_url, OPTS

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
      http = RestClient.get(profile_url, OPTS)

    rescue 
      raise I18n.t('webfinger.fetch_failed', :profile_url => profile_url) 
    end
    return http.body
  end

  def make_person_from_webfinger(webfinger_profile)
    unless webfinger_profile.strip == ""

      wf_profile = WebfingerProfile.new(@account, webfinger_profile)

      begin
        hcard = RestClient.get(wf_profile.hcard, OPTS)
      rescue
        return I18n.t('webfinger.hcard_fetch_failed', :account => @account)
      end

      card = HCard.build hcard.body
      p = Person.build_from_webfinger(wf_profile, card)
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
