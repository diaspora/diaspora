#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Adapters
  class Webfinger
    attr_accessor :host_meta_xrd, :webfinger_profile_xrd, :webfinger_profile,
                  :hcard, :hcard_xrd, :person, :account, :ssl
   #attr_reader :acct_uri, :alias_url, :hcard_url, :seed_url, :profile_url, :updates_url

    def initialize(account_handle)
      self.account = account_handle
      self.ssl = true
    end

    def fetch
      return person if existing_person_with_profile?
      create_or_update_person_from_webfinger_profile!
    end

    def self.in_background(account, opts = {})
      Workers::FetchWebfinger.perform_async(account)
    end

    # everything below should be private I guess
    def account=(str)
      @account = str.strip.gsub('acct:', '').to_s.downcase
    end

    def get(url)
      Rails.logger.info("Getting: #{url} for #{account}")
      begin
        res = Faraday.get(url)
        fail "Failed to fetch #{url}: #{res.status}" unless res.success?
        res.body
      rescue OpenSSL::SSL::SSLError => e
        Rails.logger.info "Failed to fetch #{url}: SSL setup invalid"
        raise e
      rescue => e
        Rails.logger.info "Failed to fetch: #{url} for #{account}; #{e.message}"
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
      FEDERATION_LOGGER.info "webfingering #{account}, it is not known or needs updating"
      if person
        # update my profile please
        person.assign_new_profile_from_hcard(hcard)
      else
        person = make_person_from_webfinger
      end
      FEDERATION_LOGGER.info "successfully webfingered #{@account}" if person
      person
    end

    # this tries the xrl url with https first, then falls back to http
    def host_meta_xrd
      begin
        get(host_meta_url)
      rescue => e
        if ssl
          self.ssl = false
          retry
        else
          raise "there was an error getting the xrd from account #{@account}: #{e.message}"
        end
      end
    end

    def hcard
      @hcard ||= Adapters::HCard.build(hcard_xrd)
    end

    def hcard_url
      webfinger_profile.hcard
    end

    def webfinger_profile_url
      doc = Nokogiri::XML(self.host_meta_xrd)
      return nil if doc.namespaces["xmlns"] != "http://docs.oasis-open.org/ns/xri/xrd-1.0"
      swizzle doc.search('Link').find{|x| x['rel']=='lrdd'}['template']
    end

    def webfinger_profile_xrd
      @webfinger_profile_xrd ||= get(webfinger_profile_url)
      FEDERATION_LOGGER.warn "#{@account} doesn't exists anymore" if @webfinger_profile_xrd == false
      @webfinger_profile_xrd
    end

    def hcard_xrd
      @hcard_xrd ||= get(hcard_url)
    end

    def make_person_from_webfinger
      Person.create_from_webfinger(webfinger_profile, hcard) unless webfinger_profile_xrd == false
    end

    def webfinger_profile
      @webfinger_profile ||= DiasporaFederation::WebFinger::WebFinger.from_account(webfinger_profile_xrd)
    end

    def host_meta_url
      domain = account.split('@')[1]
      "http#{'s' if ssl}://#{domain}/.well-known/host-meta"
    end

    def swizzle(template)
      template.gsub('{uri}', account)
    end
  end
end
