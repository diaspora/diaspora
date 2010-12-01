require "openid"
require "openid/fetchers"
require "openid/consumer/discovery"
require 'rexml/document'
require 'rexml/element'
require 'rexml/xpath'
require 'openssl'
require 'base64'

# Copyright 2009 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Extends ruby-openid to support the discovery protocol used by Google Apps.  Usage is
# generally simple.  Where using ruby-openid's Consumer, add the line
#
#   require 'gapps_openid'
#
# Caching of discovery information is enabled when used with rails.  In other environments,
# a cache can be set via:
#
#   OpenID.cache = ...
#
# The cache must implement methods read(key) and write(key,value)
#
# Similarly, logging will attempt to use the default Rail's logger, but can be overriden
# by calling
#
#   OpenID.logger = ...
#
# The logger must respond to warn, debug, and info methods
#
# In some cases additional setup is required, particularly to set the location of trusted
# root certificates for validating XRDS signatures.  If standard locations don't work, additional
# files and directories can be added via:
#
#   OpenID::SimpleSign.store.add_file(path_to_cacert_pem)
#
# or
#
#   OpenID::SimpleSign.store.add_path(path_to_ca_dir)
#
# TODO:
# - Memcache support for caching host-meta and site XRDS docs
# - Better packaging (gem/rails)
module OpenID

  class << self
    alias_method :default_discover, :discover
    attr_accessor :cache, :logger
  end
    
  def self.discover(uri)
    discovery = GoogleDiscovery.new
    info = discovery.perform_discovery(uri)
    if not info.nil?
      OpenID.logger.debug("Discovery info = #{info}") unless OpenID.logger.nil?
      return info
    end
    return self.default_discover(uri)
  end

  # Handles the bulk of Google's modified discovery prototcol
  # See http://groups.google.com/group/google-federated-login-api/web/openid-discovery-for-hosted-domains
  class GoogleDiscovery
    
    OpenID.cache = RAILS_CACHE rescue nil
    OpenID.logger = RAILS_DEFAULT_LOGGER rescue nil
    
    NAMESPACES = {
      'xrds' => 'xri://$xrd*($v*2.0)',
      'xrd' => 'xri://$xrds',
      'openid' => 'http://namespace.google.com/openid/xmlns'
    }

    # Main entry point for discovery.  Attempts to detect whether or not the URI is a raw domain name ('mycompany.com')
    # vs. a user's claimed ID ('http://mycompany.com/openid?id=12345') and performs the site or user discovery appropriately
    def perform_discovery(uri)
      OpenID.logger.debug("Performing discovery for #{uri}") unless OpenID.logger.nil?
      begin
        domain = uri
        parsed_uri = URI::parse(uri)
        domain = parsed_uri.host unless parsed_uri.host.nil?
        if site_identifier?(parsed_uri)
          return discover_site(domain)
        end
        return discover_user(domain, uri)
      rescue Exception => e
        # If we fail, just return nothing and fallback on default discovery mechanisms
        OpenID.logger.warn("Unexpected exception performing discovery for id #{uri}: #{e}") unless OpenID.logger.nil?
        return nil
      end
    end
    
    def site_identifier?(parsed_uri)
      return parsed_uri.scheme.nil? || parsed_uri.path.nil? || parsed_uri.path.strip.empty?
    end
    
    # Handles discovery for a user's claimed ID.  
    def discover_user(domain, claimed_id)
      OpenID.logger.debug("Discovering user identity #{claimed_id} for domain #{domain}") unless OpenID.logger.nil?
      url = fetch_host_meta(domain)
      if url.nil?
        OpenID.logger.debug("#{domain} is not a Google Apps domain, aborting") unless OpenID.logger.nil?
        return nil # Not a Google Apps domain
      end

      xrds, signed = fetch_secure_xrds(domain, url)

      unless xrds.nil?
        # TODO - Need to propogate secure discovery info up through stack
        user_url, authority = get_user_xrds_url(xrds, claimed_id)
        user_xrds, signed = fetch_secure_xrds(domain, user_url, false)
      
        # No user xrds -- likely that identifier was just OP identifier
        if user_xrds.nil?
          endpoints = OpenID::OpenIDServiceEndpoint.from_xrds(domain, xrds)
          return [claimed_id, OpenID.get_op_or_user_services(endpoints)]
        end
      
        endpoints = OpenID::OpenIDServiceEndpoint.from_xrds(claimed_id, user_xrds)
        return [claimed_id, OpenID.get_op_or_user_services(endpoints)]
      end
    end
    
    # Handles discovery for a domain
    def discover_site(domain)
      OpenID.logger.debug("Discovering domain #{domain}") unless OpenID.logger.nil?
      url = fetch_host_meta(domain)
      if url.nil?
        OpenID.logger.debug("#{domain} is not a Google Apps domain, aborting") unless OpenID.logger.nil?
        return nil # Not a Google Apps domain
      end
      xrds, secure = fetch_secure_xrds(domain, url)
      
      unless xrds.nil?
        # TODO - Need to propogate secure discovery info up through stack
        endpoints = OpenID::OpenIDServiceEndpoint.from_xrds(domain, xrds)
        return [domain, OpenID.get_op_or_user_services(endpoints)]
      end
      return nil
    end

    # Kickstart the discovery process by checking against Google's well-known location for hosted domains.
    # This gives us the location of the site's XRDS doc
    def fetch_host_meta(domain) 
      cached_value = get_cache(domain)
      return cached_value unless cached_value.nil?
      
      host_meta_url = "https://www.google.com/accounts/o8/.well-known/host-meta?hd=#{CGI::escape(domain)}"
      http_resp = fetch_url(host_meta_url)
      return nil if http_resp.nil?

      matches = /Link: <(.*)>/.match( http_resp.body )
      if matches.nil? 
        OpenID.logger.debug("No link tag found at #{host_meta_url}") unless OpenID.logger.nil?
        return nil
      end
      put_cache(domain, matches[1])
      return matches[1]
    end

    def fetch_url(url)
      http_resp = OpenID.fetch(url)
      if http_resp.code != "200" and http_resp.code != "206"
        OpenID.logger.debug("Received #{http_resp.code} when fetching #{url}") unless OpenID.logger.nil?
        return nil
      end
      return http_resp
    end
    
    # Fetches the XRDS and verifies the signature and authority for the doc
    def fetch_secure_xrds(authority, url, cache=true) 
      return if url.nil?

      OpenID.logger.debug("Retrieving XRDS from #{url}") unless OpenID.logger.nil?
 
      cached_xrds = get_cache("XRDS_#{url}")
      return cached_xrds unless cached_xrds.nil?

      http_resp = fetch_url(url)
      return nil if http_resp.nil?

      body = http_resp.body
      put_cache("XRDS_#{url}", body)

      signature = http_resp["Signature"]
      signed_by = SimpleSign.verify(body, signature)

      if signed_by.nil?
        put_cache("XRDS_#{url}", body) if cache
        return [body, false]      
      elsif signed_by.casecmp(authority) || signed_by.casecmp('hosted-id.google.com')
        put_cache("XRDS_#{url}", body) if cache
        return [body, true]
      else
        OpenID.logger.warn("Expected signature from #{authority} but found #{signed_by}") unless OpenID.logger.nil?        
        return nil # Signed, but not by the right domain.
      end
    end    
    
    # Process the URITemplate in the XRDS to derive the location of the claimed id's XRDS
    def get_user_xrds_url(xrds, claimed_id)
      types_to_match = ['http://www.iana.org/assignments/relation/describedby']
      services = OpenID::Yadis::apply_filter(claimed_id, xrds)
      services.each do | service | 
        if service.match_types(types_to_match) 
          template = REXML::XPath.first(service.service_element, '//openid:URITemplate', NAMESPACES)
          authority = REXML::XPath.first(service.service_element, '//openid:NextAuthority', NAMESPACES)
          url = template.text.gsub('{%uri}', CGI::escape(claimed_id))
          return [url, authority.text]
        end
      end
    end
    
    def put_cache(key, item)
      return if OpenID.cache.nil?
      OpenID.cache.write("__GAPPS_OPENID__#{key}", item)
    end
    
    def get_cache(key)
      return nil if OpenID.cache.nil?
      return OpenID.cache.read("__GAPPS_OPENID__#{key}")
    end
  end

  # Basic implementation of the XML Simple Sign algorithm.  Currently only supports
  # RSA-SHA1
  class SimpleSign 

    @@store = nil

    C14N_RAW_OCTETS = 'http://docs.oasis-open.org/xri/xrd/2009/01#canonicalize-raw-octets'
    SIGN_RSA_SHA1 = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'

    NAMESPACES = {
      'ds' => 'http://www.w3.org/2000/09/xmldsig#',
      'xrds' => 'xri://xrds'
    }

    # Initialize the store
    def self.store
      if @@store.nil?
        OpenID.logger.info("Initializing CA bundle") unless OpenID.logger.nil?        
        ca_bundle_path = File.join(File.dirname(__FILE__), 'ca-bundle.crt')
        @@store = OpenSSL::X509::Store.new
        @@store.set_default_paths
        @@store.add_file(ca_bundle_path)        
      end
      return @@store
    end

    # Extracts the signer's certificates from the XML
    def self.parse_certificates(doc) 
      certs = []
      REXML::XPath.each(doc, "//ds:Signature/ds:KeyInfo/ds:X509Data/ds:X509Certificate", NAMESPACES ) { | encoded |
        encoded = encoded.text.strip.scan(/.{1,64}/).join("\n")
        encoded = "-----BEGIN CERTIFICATE-----\n#{encoded}\n-----END CERTIFICATE-----\n"
        cert = OpenSSL::X509::Certificate.new(encoded)
        certs << cert
      }
      return certs
    end

    # Verifies the chain of trust for the signing certificates
    def self.valid_chain?(chain)
      if chain.nil? or chain.empty?
        return false
      end
      cert = chain.shift
      if self.store.verify(cert)
        return true
      end
      if chain.empty? or not cert.verify(chain.first.public_key)
        return false
      end
      return self.valid_chain?(chain)
    end 

    # Verifies the signature of the doc, returning the CN of the signer if valid
    def self.verify(xml, signature_value) 
      doc = REXML::Document.new(xml)

      return nil if REXML::XPath.first(doc, "//ds:Signature").nil? and signature_value.nil?    

      decoded_sig = Base64.decode64(signature_value)
      certs = self.parse_certificates(doc)
      raise "No signature in document" if certs.nil? or certs.empty?
      raise "Missing signature value" if signature_value.nil?


      signing_certificate = certs.first
      raise "Invalid signature" if !signing_certificate.public_key.verify(OpenSSL::Digest::SHA1.new, decoded_sig, xml)
      raise "Certificate chain not valid" if !self.valid_chain?(certs)

      # Signature is valid, return CN of the subject
      subject = signing_certificate.subject.to_a
      signed_by = subject.last[1]
      return signed_by
    end    
  end

end    


