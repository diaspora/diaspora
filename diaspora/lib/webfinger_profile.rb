class WebfingerProfile
  attr_accessor :webfinger_profile, :account, :links, :hcard, :guid, :public_key, :seed_location

  def initialize(account, webfinger_profile)
    @account = account
    @webfinger_profile = webfinger_profile
    @links = {}
    set_fields
  end

  def valid_diaspora_profile?
    !(@webfinger_profile.nil? || @account.nil? || @links.nil? || @hcard.nil? ||
        @guid.nil? || @public_key.nil? || @seed_location.nil? )
  end

  private

  def set_fields
    doc = Nokogiri::XML.parse(webfinger_profile)

    account_string = doc.css('Subject').text.gsub('acct:', '').strip

    raise "account in profile(#{account_string}) and account requested (#{@account}) do not match" if account_string != @account

    doc.css('Link').each do |l|
      rel = text_of_attribute(l, 'rel')
      href = text_of_attribute(l, 'href')
      @links[rel] = href
      case rel
        when "http://microformats.org/profile/hcard"
          @hcard = href
        when "http://joindiaspora.com/guid"
          @guid = href
        when "http://joindiaspora.com/seed_location"
          @seed_location = href
      end
    end

    if doc.at('Link[rel=diaspora-public-key]')
      begin
        pubkey = text_of_attribute( doc.at('Link[rel=diaspora-public-key]'), 'href')
        @public_key = Base64.decode64 pubkey
      rescue Exception => e
        Rails.logger.info(:event => :invalid_profile, :identifier => @account)
      end
    end
  end

  def text_of_attribute(doc, attr)
    doc.attribute(attr) ? doc.attribute(attr).text : nil
  end
end
