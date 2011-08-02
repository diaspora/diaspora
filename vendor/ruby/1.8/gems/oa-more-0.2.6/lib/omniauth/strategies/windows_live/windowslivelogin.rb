#######################################################################
# FILE:        windowslivelogin.rb
#
# DESCRIPTION: Sample implementation of Web Authentication and
#              Delegated Authentication protocol in Ruby. Also
#              includes trusted sign-in and application verification
#              sample implementations.
#
# VERSION:     1.1
#
# Copyright (c) 2008 Microsoft Corporation.  All Rights Reserved.
#######################################################################

require 'cgi'
require 'uri'
require 'base64'
require 'openssl'
require 'net/https'
require 'rexml/document'

module OmniAuth; module Strategies; class WindowsLive; class WindowsLiveLogin

  #####################################################################
  # Stub implementation for logging errors. If you want to enable
  # debugging output using the default mechanism, specify true.
  # By default, debug information will be printed to the standard
  # error output and should be visible in the web server logs.
  #####################################################################
  def setDebug(flag)
    @debug = flag
  end

  #####################################################################
  # Stub implementation for logging errors. By default, this function
  # does nothing if the debug flag has not been set with setDebug.
  # Otherwise, it tries to log the error message.
  #####################################################################
  def debug(error)
    return unless @debug
    return if error.nil? or error.empty?
    warn("Windows Live ID Authentication SDK #{error}")
    nil
  end

  #####################################################################
  # Stub implementation for handling a fatal error.
  #####################################################################
  def fatal(error)
    debug(error)
    raise(error)
  end

  #####################################################################
  # Initialize the WindowsLiveLogin module with the application ID,
  # secret key, and security algorithm.
  #
  # We recommend that you employ strong measures to protect the
  # secret key. The secret key should never be exposed to the Web
  # or other users.
  #
  # Be aware that if you do not supply these settings at
  # initialization time, you may need to set the corresponding
  # properties manually.
  #
  # For Delegated Authentication, you may optionally specify the
  # privacy policy URL and return URL. If you do not specify these
  # values here, the default values that you specified when you
  # registered your application will be used.
  #
  # The 'force_delauth_nonprovisioned' flag also indicates whether
  # your application is registered for Delegated Authentication
  # (that is, whether it uses an application ID and secret key). We
  # recommend that your Delegated Authentication application always
  # be registered for enhanced security and functionality.
  #####################################################################
  def initialize(appid=nil, secret=nil, securityalgorithm=nil,
                 force_delauth_nonprovisioned=nil,
                 policyurl=nil, returnurl=nil)
    self.force_delauth_nonprovisioned = force_delauth_nonprovisioned
    self.appid = appid if appid
    self.secret = secret if secret
    self.securityalgorithm = securityalgorithm if securityalgorithm
    self.policyurl = policyurl if policyurl
    self.returnurl = returnurl if returnurl
  end

  #####################################################################
  # Initialize the WindowsLiveLogin module from a settings file.
  #
  # 'settingsFile' specifies the location of the XML settings file
  # that contains the application ID, secret key, and security
  # algorithm. The file is of the following format:
  #
  # <windowslivelogin>
  #   <appid>APPID</appid>
  #   <secret>SECRET</secret>
  #   <securityalgorithm>wsignin1.0</securityalgorithm>
  # </windowslivelogin>
  #
  # In a Delegated Authentication scenario, you may also specify
  # 'returnurl' and 'policyurl' in the settings file, as shown in the
  # Delegated Authentication samples.
  #
  # We recommend that you store the WindowsLiveLogin settings file
  # in an area on your server that cannot be accessed through the
  # Internet. This file contains important confidential information.
  #####################################################################
  def self.initFromXml(settingsFile)
    o = self.new
    settings = o.parseSettings(settingsFile)

    o.setDebug(settings['debug'] == 'true')
    o.force_delauth_nonprovisioned =
      (settings['force_delauth_nonprovisioned'] == 'true')

    o.appid = settings['appid']
    o.secret = settings['secret']
    o.oldsecret = settings['oldsecret']
    o.oldsecretexpiry = settings['oldsecretexpiry']
    o.securityalgorithm = settings['securityalgorithm']
    o.policyurl = settings['policyurl']
    o.returnurl = settings['returnurl']
    o.baseurl = settings['baseurl']
    o.secureurl = settings['secureurl']
    o.consenturl = settings['consenturl']
    o
  end

  #####################################################################
  # Sets the application ID. Use this method if you did not specify
  # an application ID at initialization.
  #####################################################################
  def appid=(appid)
    if (appid.nil? or appid.empty?)
      return if force_delauth_nonprovisioned
      fatal("Error: appid: Null application ID.")
    end
    if (not appid =~ /^\w+$/)
      fatal("Error: appid: Application ID must be alpha-numeric: " + appid)
    end
    @appid = appid
  end

  #####################################################################
  # Returns the application ID.
  #####################################################################
  def appid
    if (@appid.nil? or @appid.empty?)
      fatal("Error: appid: App ID was not set. Aborting.")
    end
    @appid
  end

  #####################################################################
  # Sets your secret key. Use this method if you did not specify
  # a secret key at initialization.
  #####################################################################
  def secret=(secret)
    if (secret.nil? or secret.empty?)
      return if force_delauth_nonprovisioned
      fatal("Error: secret=: Secret must be non-null.")
    end
    if (secret.size < 16)
      fatal("Error: secret=: Secret must be at least 16 characters.")
    end
    @signkey = derive(secret, "SIGNATURE")
    @cryptkey = derive(secret, "ENCRYPTION")
  end

  #####################################################################
  # Sets your old secret key.
  #
  # Use this property to set your old secret key if you are in the
  # process of transitioning to a new secret key. You may need this
  # property because the Windows Live ID servers can take up to
  # 24 hours to propagate a new secret key after you have updated
  # your application settings.
  #
  # If an old secret key is specified here and has not expired
  # (as determined by the oldsecretexpiry setting), it will be used
  # as a fallback if token decryption fails with the new secret
  # key.
  #####################################################################
  def oldsecret=(secret)
    return if (secret.nil? or secret.empty?)
    if (secret.size < 16)
      fatal("Error: oldsecret=: Secret must be at least 16 characters.")
    end
    @oldsignkey = derive(secret, "SIGNATURE")
    @oldcryptkey = derive(secret, "ENCRYPTION")
  end

  #####################################################################
  # Sets the expiry time for your old secret key.
  #
  # After this time has passed, the old secret key will no longer be
  # used even if token decryption fails with the new secret key.
  #
  # The old secret expiry time is represented as the number of seconds
  # elapsed since January 1, 1970.
  #####################################################################
  def oldsecretexpiry=(timestamp)
    return if (timestamp.nil? or timestamp.empty?)
    timestamp = timestamp.to_i
    fatal("Error: oldsecretexpiry=: Invalid timestamp: #{timestamp}") if (timestamp <= 0)
    @oldsecretexpiry = Time.at timestamp
  end

  #####################################################################
  # Gets the old secret key expiry time.
  #####################################################################
  attr_accessor :oldsecretexpiry

  #####################################################################
  # Sets or gets the version of the security algorithm being used.
  #####################################################################
  attr_accessor :securityalgorithm

  def securityalgorithm
    if(@securityalgorithm.nil? or @securityalgorithm.empty?)
      "wsignin1.0"
    else
      @securityalgorithm
    end
  end

  #####################################################################
  # Sets a flag that indicates whether Delegated Authentication
  # is non-provisioned (i.e. does not use an application ID or secret
  # key).
  #####################################################################
  attr_accessor :force_delauth_nonprovisioned

  #####################################################################
  # Sets the privacy policy URL, to which the Windows Live ID consent
  # service redirects users to view the privacy policy of your Web
  # site for Delegated Authentication.
  #####################################################################
  def policyurl=(policyurl)
    if ((policyurl.nil? or policyurl.empty?) and force_delauth_nonprovisioned)
      fatal("Error: policyurl=: Invalid policy URL specified.")
    end
    @policyurl = policyurl
  end

  #####################################################################
  # Gets the privacy policy URL for your site.
  #####################################################################
  def policyurl
    if (@policyurl.nil? or @policyurl.empty?)
      debug("Warning: In the initial release of Del Auth, a Policy URL must be configured in the SDK for both provisioned and non-provisioned scenarios.")
      raise("Error: policyurl: Policy URL must be set in a Del Auth non-provisioned scenario. Aborting.") if force_delauth_nonprovisioned
    end
    @policyurl
  end

  #####################################################################
  # Sets the return URL--the URL on your site to which the consent
  # service redirects users (along with the action, consent token,
  # and application context) after they have successfully provided
  # consent information for Delegated Authentication. This value will
  # override the return URL specified during registration.
  #####################################################################
  def returnurl=(returnurl)
    if ((returnurl.nil? or returnurl.empty?) and force_delauth_nonprovisioned)
      fatal("Error: returnurl=: Invalid return URL specified.")
    end
    @returnurl = returnurl
  end


  #####################################################################
  # Returns the return URL of your site.
  #####################################################################
  def returnurl
    if ((@returnurl.nil? or @returnurl.empty?) and force_delauth_nonprovisioned)
      fatal("Error: returnurl: Return URL must be set in a Del Auth non-provisioned scenario. Aborting.")
    end
    @returnurl
  end

  #####################################################################
  # Sets or gets the base URL to use for the Windows Live Login server. You
  # should not have to change this property. Furthermore, we recommend
  # that you use the Sign In control instead of the URL methods
  # provided here.
  #####################################################################
  attr_accessor :baseurl

  def baseurl
    if(@baseurl.nil? or @baseurl.empty?)
      "http://login.live.com/"
    else
      @baseurl
    end
  end

  #####################################################################
  # Sets or gets the secure (HTTPS) URL to use for the Windows Live Login
  # server. You should not have to change this property.
  #####################################################################
  attr_accessor :secureurl

  def secureurl
    if(@secureurl.nil? or @secureurl.empty?)
      "https://login.live.com/"
    else
      @secureurl
    end
  end

  #####################################################################
  # Sets or gets the Consent Base URL to use for the Windows Live Consent
  # server. You should not have to use or change this property directly.
  #####################################################################
  attr_accessor :consenturl

  def consenturl
    if(@consenturl.nil? or @consenturl.empty?)
      "https://consent.live.com/"
    else
      @consenturl
    end
  end
end

#######################################################################
# Implementation of the basic methods needed for Web Authentication.
#######################################################################
class WindowsLiveLogin
  #####################################################################
  # Returns the sign-in URL to use for the Windows Live Login server.
  # We recommend that you use the Sign In control instead.
  #
  # If you specify it, 'context' will be returned as-is in the sign-in
  # response for site-specific use.
  #####################################################################
  def getLoginUrl(context=nil, market=nil)
    url = baseurl + "wlogin.srf?appid=#{appid}"
    url += "&alg=#{securityalgorithm}"
    url += "&appctx=#{CGI.escape(context)}" if context
    url += "&mkt=#{CGI.escape(market)}" if market
    url
  end

  #####################################################################
  # Returns the sign-out URL to use for the Windows Live Login server.
  # We recommend that you use the Sign In control instead.
  #####################################################################
  def getLogoutUrl(market=nil)
    url = baseurl + "logout.srf?appid=#{appid}"
    url += "&mkt=#{CGI.escape(market)}" if market
    url
  end

  #####################################################################
  # Holds the user information after a successful sign-in.
  #
  # 'timestamp' is the time as obtained from the SSO token.
  # 'id' is the pairwise unique ID for the user.
  # 'context' is the application context that was originally passed to
  # the sign-in request, if any.
  # 'token' is the encrypted Web Authentication token that contains the
  # UID. This can be cached in a cookie and the UID can be retrieved by
  # calling the processToken method.
  # 'usePersistentCookie?' indicates whether the application is
  # expected to store the user token in a session or persistent
  # cookie.
  #####################################################################
  class User
    attr_reader :timestamp, :id, :context, :token

    def usePersistentCookie?
      @usePersistentCookie
    end


  #####################################################################
  # Initialize the User with time stamp, userid, flags, context and token.
  #####################################################################
    def initialize(timestamp, id, flags, context, token)
      self.timestamp = timestamp
      self.id = id
      self.flags = flags
      self.context = context
      self.token = token
    end

    private
    attr_writer :timestamp, :id, :flags, :context, :token

  #####################################################################
  # Sets or gets the Unix timestamp as obtained from the SSO token.
  #####################################################################
    def timestamp=(timestamp)
      raise("Error: User: Null timestamp in token.") unless timestamp
      timestamp = timestamp.to_i
      raise("Error: User: Invalid timestamp: #{timestamp}") if (timestamp <= 0)
      @timestamp = Time.at timestamp
    end

  #####################################################################
  # Sets or gets the pairwise unique ID for the user.
  #####################################################################
    def id=(id)
      raise("Error: User: Null id in token.") unless id
      raise("Error: User: Invalid id: #{id}") unless (id =~ /^\w+$/)
      @id = id
    end

  #####################################################################
  # Sets or gets the usePersistentCookie flag for the user.
  #####################################################################
    def flags=(flags)
      @usePersistentCookie = false
      if flags
        @usePersistentCookie = ((flags.to_i % 2) == 1)
      end
    end
  end

  #####################################################################
  # Processes the sign-in response from the Windows Live sign-in server.
  #
  # 'query' contains the preprocessed POST table, such as that
  # returned by CGI.params or Rails. (The unprocessed POST string
  # could also be used here but we do not recommend it).
  #
  # This method returns a User object on successful sign-in; otherwise
  # it returns nil.
  #####################################################################
  def processLogin(query)
    query = parse query
    unless query
      debug("Error: processLogin: Failed to parse query.")
      return
    end
    action = query['action']
    unless action == 'login'
      debug("Warning: processLogin: query action ignored: #{action}.")
      return
    end
    token = query['stoken']
    context = CGI.unescape(query['appctx']) if query['appctx']
    processToken(token, context)
  end

  #####################################################################
  # Decodes and validates a Web Authentication token. Returns a User
  # object on success. If a context is passed in, it will be returned
  # as the context field in the User object.
  #####################################################################
  def processToken(token, context=nil)
    if token.nil? or token.empty?
      debug("Error: processToken: Null/empty token.")
      return
    end
    stoken = decodeAndValidateToken token
    stoken = parse stoken
    unless stoken
      debug("Error: processToken: Failed to decode/validate token: #{token}")
      return
    end
    sappid = stoken['appid']
    unless sappid == appid
      debug("Error: processToken: Application ID in token did not match ours: #{sappid}, #{appid}")
      return
    end
    begin
      user = User.new(stoken['ts'], stoken['uid'], stoken['flags'],
                      context, token)
      return user
    rescue Exception => e
      debug("Error: processToken: Contents of token considered invalid: #{e}")
      return
    end
  end

  #####################################################################
  # Returns an appropriate content type and body response that the
  # application handler can return to signify a successful sign-out
  # from the application.
  #
  # When a user signs out of Windows Live or a Windows Live
  # application, a best-effort attempt is made at signing the user out
  # from all other Windows Live applications the user might be signed
  # in to. This is done by calling the handler page for each
  # application with 'action' set to 'clearcookie' in the query
  # string. The application handler is then responsible for clearing
  # any cookies or data associated with the sign-in. After successfully
  # signing the user out, the handler should return a GIF (any GIF)
  # image as response to the 'action=clearcookie' query.
  #####################################################################
  def getClearCookieResponse()
    type = "image/gif"
    content = "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAEALAAAAAABAAEAAAIBTAA7"
    content = Base64.decode64(content)
    return type, content
  end
end

#######################################################################
# Implementation of the basic methods needed for Delegated
# Authentication.
#######################################################################
class WindowsLiveLogin
  #####################################################################
  # Returns the consent URL to use for Delegated Authentication for
  # the given comma-delimited list of offers.
  #
  # If you specify it, 'context' will be returned as-is in the consent
  # response for site-specific use.
  #
  # The registered/configured return URL can also be overridden by
  # specifying 'ru' here.
  #
  # You can change the language in which the consent page is displayed
  # by specifying a culture ID (For example, 'fr-fr' or 'en-us') in the
  # 'market' parameter.
  #####################################################################
  def getConsentUrl(offers, context=nil, ru=nil, market=nil)
    if (offers.nil? or offers.empty?)
      fatal("Error: getConsentUrl: Invalid offers list.")
    end
    url = consenturl + "Delegation.aspx?ps=#{CGI.escape(offers)}"
    url += "&appctx=#{CGI.escape(context)}" if context
    ru = returnurl if (ru.nil? or ru.empty?)
    url += "&ru=#{CGI.escape(ru)}" if ru
    pu = policyurl
    url += "&pl=#{CGI.escape(pu)}" if pu
    url += "&mkt=#{CGI.escape(market)}" if market
    url += "&app=#{getAppVerifier()}" unless force_delauth_nonprovisioned
    url
  end

  #####################################################################
  # Returns the URL to use to download a new consent token, given the
  # offers and refresh token.
  # The registered/configured return URL can also be overridden by
  # specifying 'ru' here.
  #####################################################################
  def getRefreshConsentTokenUrl(offers, refreshtoken, ru)
    if (offers.nil? or offers.empty?)
      fatal("Error: getRefreshConsentTokenUrl: Invalid offers list.")
    end
    if (refreshtoken.nil? or refreshtoken.empty?)
      fatal("Error: getRefreshConsentTokenUrl: Invalid refresh token.")
    end
    url = consenturl + "RefreshToken.aspx?ps=#{CGI.escape(offers)}"
    url += "&reft=#{refreshtoken}"
    ru = returnurl if (ru.nil? or ru.empty?)
    url += "&ru=#{CGI.escape(ru)}" if ru
    url += "&app=#{getAppVerifier()}" unless force_delauth_nonprovisioned
    url
  end

  #####################################################################
  # Returns the URL for the consent-management user interface.
  # You can change the language in which the consent page is displayed
  # by specifying a culture ID (For example, 'fr-fr' or 'en-us') in the
  # 'market' parameter.
  #####################################################################
  def getManageConsentUrl(market=nil)
    url = consenturl + "ManageConsent.aspx"
    url += "?mkt=#{CGI.escape(market)}" if market
    url
  end

  class ConsentToken
    attr_reader :delegationtoken, :refreshtoken, :sessionkey, :expiry
    attr_reader :offers, :offers_string, :locationid, :context
    attr_reader :decodedtoken, :token

    #####################################################################
    # Indicates whether the delegation token is set and has not expired.
    #####################################################################
    def isValid?
      return false unless delegationtoken
      return ((Time.now.to_i-300) < expiry.to_i)
    end

    #####################################################################
    # Refreshes the current token and replace it. If operation succeeds
    # true is returned to signify success.
    #####################################################################
    def refresh
      ct = @wll.refreshConsentToken(self)
      return false unless ct
      copy(ct)
      true
    end

    #####################################################################
    # Initialize the ConsentToken module with the WindowsLiveLogin,
    # delegation token, refresh token, session key, expiry, offers,
    # location ID, context, decoded token, and raw token.
    #####################################################################
    def initialize(wll, delegationtoken, refreshtoken, sessionkey, expiry,
                   offers, locationid, context, decodedtoken, token)
      @wll = wll
      self.delegationtoken = delegationtoken
      self.refreshtoken = refreshtoken
      self.sessionkey = sessionkey
      self.expiry = expiry
      self.offers = offers
      self.locationid = locationid
      self.context = context
      self.decodedtoken = decodedtoken
      self.token = token
    end

    private
    attr_writer :delegationtoken, :refreshtoken, :sessionkey, :expiry
    attr_writer :offers, :offers_string, :locationid, :context
    attr_writer :decodedtoken, :token, :locationid

    #####################################################################
    # Sets the delegation token.
    #####################################################################
    def delegationtoken=(delegationtoken)
      if (delegationtoken.nil? or delegationtoken.empty?)
        raise("Error: ConsentToken: Null delegation token.")
      end
      @delegationtoken = delegationtoken
    end

    #####################################################################
    # Sets the session key.
    #####################################################################
    def sessionkey=(sessionkey)
      if (sessionkey.nil? or sessionkey.empty?)
        raise("Error: ConsentToken: Null session key.")
      end
      @sessionkey = @wll.u64(sessionkey)
    end

    #####################################################################
    # Sets the expiry time of the delegation token.
    #####################################################################
    def expiry=(expiry)
      if (expiry.nil? or expiry.empty?)
        raise("Error: ConsentToken: Null expiry time.")
      end
      expiry = expiry.to_i
      raise("Error: ConsentToken: Invalid expiry: #{expiry}") if (expiry <= 0)
      @expiry = Time.at expiry
    end

    #####################################################################
    # Sets the offers/actions for which the user granted consent.
    #####################################################################
    def offers=(offers)
      if (offers.nil? or offers.empty?)
        raise("Error: ConsentToken: Null offers.")
      end

      @offers_string = ""
      @offers = []

      offers = CGI.unescape(offers)
      offers = offers.split(";")
      offers.each{|offer|
        offer = offer.split(":")[0]
        @offers_string += "," unless @offers_string.empty?
        @offers_string += offer
        @offers.push(offer)
      }
    end

    #####################################################################
    # Sets the LocationID.
    #####################################################################
    def locationid=(locationid)
      if (locationid.nil? or locationid.empty?)
        raise("Error: ConsentToken: Null Location ID.")
      end
      @locationid = locationid
    end

    #####################################################################
    # Makes a copy of the ConsentToken object.
    #####################################################################
    def copy(consenttoken)
      @delegationtoken = consenttoken.delegationtoken
      @refreshtoken = consenttoken.refreshtoken
      @sessionkey = consenttoken.sessionkey
      @expiry = consenttoken.expiry
      @offers = consenttoken.offers
      @locationid = consenttoken.locationid
      @offers_string = consenttoken.offers_string
      @decodedtoken = consenttoken.decodedtoken
      @token = consenttoken.token
    end
  end

  #####################################################################
  # Processes the POST response from the Delegated Authentication
  # service after a user has granted consent. The processConsent
  # function extracts the consent token string and returns the result
  # of invoking the processConsentToken method.
  #####################################################################
  def processConsent(query)
    query = parse query
    unless query
      debug("Error: processConsent: Failed to parse query.")
      return
    end
    action = query['action']
    unless action == 'delauth'
      debug("Warning: processConsent: query action ignored: #{action}.")
      return
    end
    responsecode = query['ResponseCode']
    unless responsecode == 'RequestApproved'
      debug("Error: processConsent: Consent was not successfully granted: #{responsecode}")
      return
    end
    token = query['ConsentToken']
    context = CGI.unescape(query['appctx']) if query['appctx']
    processConsentToken(token, context)
  end

  #####################################################################
  # Processes the consent token string that is returned in the POST
  # response by the Delegated Authentication service after a
  # user has granted consent.
  #####################################################################
  def processConsentToken(token, context=nil)
    if token.nil? or token.empty?
      debug("Error: processConsentToken: Null token.")
      return
    end
    decodedtoken = token
    parsedtoken = parse(CGI.unescape(decodedtoken))
    unless parsedtoken
      debug("Error: processConsentToken: Failed to parse token: #{token}")
      return
    end
    eact = parsedtoken['eact']
    if eact
      decodedtoken = decodeAndValidateToken eact
      unless decodedtoken
        debug("Error: processConsentToken: Failed to decode/validate token: #{token}")
        return
      end
      parsedtoken = parse(decodedtoken)
      decodedtoken = CGI.escape(decodedtoken)
    end
    begin
      consenttoken = ConsentToken.new(self,
                                      parsedtoken['delt'],
                                      parsedtoken['reft'],
                                      parsedtoken['skey'],
                                      parsedtoken['exp'],
                                      parsedtoken['offer'],
                                      parsedtoken['lid'],
                                      context, decodedtoken, token)
      return consenttoken
    rescue Exception => e
      debug("Error: processConsentToken: Contents of token considered invalid: #{e}")
      return
    end
  end

  #####################################################################
  # Attempts to obtain a new, refreshed token and return it. The
  # original token is not modified.
  #####################################################################
  def refreshConsentToken(consenttoken, ru=nil)
    if consenttoken.nil?
      debug("Error: refreshConsentToken: Null consent token.")
      return
    end
    refreshConsentToken2(consenttoken.offers_string, consenttoken.refreshtoken, ru)
  end

  #####################################################################
  # Helper function to obtain a new, refreshed token and return it.
  # The original token is not modified.
  #####################################################################
  def refreshConsentToken2(offers_string, refreshtoken, ru=nil)
    url = nil
    begin
      url = getRefreshConsentTokenUrl(offers_string, refreshtoken, ru)
      ret = fetch url
      ret.value # raises exception if fetch failed
      body = ret.body
      body.scan(/\{"ConsentToken":"(.*)"\}/){|match|
      return processConsentToken("#{match}")
      }
      debug("Error: refreshConsentToken2: Failed to extract token: #{body}")
    rescue Exception => e
      debug("Error: Failed to refresh consent token: #{e}")
    end
    return
  end
end

#######################################################################
# Common methods.
#######################################################################
class WindowsLiveLogin

  #####################################################################
  # Decodes and validates the token.
  #####################################################################
  def decodeAndValidateToken(token, cryptkey=@cryptkey, signkey=@signkey,
                             internal_allow_recursion=true)
    haveoldsecret = false
    if (oldsecretexpiry and (Time.now.to_i < oldsecretexpiry.to_i))
      haveoldsecret = true if (@oldcryptkey and @oldsignkey)
    end
    haveoldsecret = (haveoldsecret and internal_allow_recursion)

    stoken = decodeToken(token, cryptkey)
    stoken = validateToken(stoken, signkey) if stoken
    if (stoken.nil? and haveoldsecret)
      debug("Warning: Failed to validate token with current secret, attempting old secret.")
      stoken = decodeAndValidateToken(token, @oldcryptkey, @oldsignkey, false)
    end
    stoken
  end

  #####################################################################
  # Decodes the given token string; returns undef on failure.
  #
  # First, the string is URL-unescaped and base64 decoded.
  # Second, the IV is extracted from the first 16 bytes of the string.
  # Finally, the string is decrypted using the encryption key.
  #####################################################################
  def decodeToken(token, cryptkey=@cryptkey)
    if (cryptkey.nil? or cryptkey.empty?)
      fatal("Error: decodeToken: Secret key was not set. Aborting.")
    end
    token =  u64(token)
    if (token.nil? or (token.size <= 16) or !(token.size % 16).zero?)
      debug("Error: decodeToken: Attempted to decode invalid token.")
      return
    end
    iv = token[0..15]
    crypted = token[16..-1]
    begin
      aes128cbc = OpenSSL::Cipher::AES128.new("CBC")
      aes128cbc.decrypt
      aes128cbc.iv = iv
      aes128cbc.key = cryptkey
      decrypted = aes128cbc.update(crypted) + aes128cbc.final
    rescue Exception => e
      debug("Error: decodeToken: Decryption failed: #{token}, #{e}")
      return
    end
    decrypted
  end

  #####################################################################
  # Creates a signature for the given string by using the signature
  # key.
  #####################################################################
  def signToken(token, signkey=@signkey)
    if (signkey.nil? or signkey.empty?)
      fatal("Error: signToken: Secret key was not set. Aborting.")
    end
    begin
      digest = OpenSSL::Digest::SHA256.new
      return OpenSSL::HMAC.digest(digest, signkey, token)
    rescue Exception => e
      debug("Error: signToken: Signing failed: #{token}, #{e}")
      return
    end
  end

  #####################################################################
  # Extracts the signature from the token and validates it.
  #####################################################################
  def validateToken(token, signkey=@signkey)
    if (token.nil? or token.empty?)
      debug("Error: validateToken: Null token.")
      return
    end
    body, sig = token.split("&sig=")
    if (body.nil? or sig.nil?)
      debug("Error: validateToken: Invalid token: #{token}")
      return
    end
    sig = u64(sig)
    return token if (sig == signToken(body, signkey))
    debug("Error: validateToken: Signature did not match.")
    return
  end
end

#######################################################################
# Implementation of the methods needed to perform Windows Live
# application verification as well as trusted sign-in.
#######################################################################
class WindowsLiveLogin
  #####################################################################
  # Generates an application verifier token. An IP address can
  # optionally be included in the token.
  #####################################################################
  def getAppVerifier(ip=nil)
    token = "appid=#{appid}&ts=#{timestamp}"
    token += "&ip=#{ip}" if ip
    token += "&sig=#{e64(signToken(token))}"
    CGI.escape token
  end

  #####################################################################
  # Returns the URL that is required to retrieve the application
  # security token.
  #
  # By default, the application security token is generated for
  # the Windows Live site; a specific Site ID can optionally be
  # specified in 'siteid'. The IP address can also optionally be
  # included in 'ip'.
  #
  # If 'js' is nil, a JavaScript Output Notation (JSON) response is
  # returned in the following format:
  #
  # {"token":"<value>"}
  #
  # Otherwise, a JavaScript response is returned. It is assumed that
  # WLIDResultCallback is a custom function implemented to handle the
  # token value:
  #
  # WLIDResultCallback("<tokenvalue>");
  #####################################################################
  def getAppLoginUrl(siteid=nil, ip=nil, js=nil)
    url = secureurl + "wapplogin.srf?app=#{getAppVerifier(ip)}"
    url += "&alg=#{securityalgorithm}"
    url += "&id=#{siteid}" if siteid
    url += "&js=1" if js
    url
  end

  #####################################################################
  # Retrieves the application security token for application
  # verification from the application sign-in URL.
  #
  # By default, the application security token will be generated for
  # the Windows Live site; a specific Site ID can optionally be
  # specified in 'siteid'. The IP address can also optionally be
  # included in 'ip'.
  #
  # Implementation note: The application security token is downloaded
  # from the application sign-in URL in JSON format:
  #
  # {"token":"<value>"}
  #
  # Therefore we must extract <value> from the string and return it as
  # seen here.
  #####################################################################
  def getAppSecurityToken(siteid=nil, ip=nil)
    url = getAppLoginUrl(siteid, ip)
    begin
      ret = fetch url
      ret.value # raises exception if fetch failed
      body = ret.body
      body.scan(/\{"token":"(.*)"\}/){|match|
        return match
      }
      debug("Error: getAppSecurityToken: Failed to extract token: #{body}")
    rescue Exception => e
      debug("Error: getAppSecurityToken: Failed to get token: #{e}")
    end
    return
  end

  #####################################################################
  # Returns a string that can be passed to the getTrustedParams
  # function as the 'retcode' parameter. If this is specified as the
  # 'retcode', the application will be used as return URL after it
  # finishes trusted sign-in.
  #####################################################################
  def getAppRetCode
    "appid=#{appid}"
  end

  #####################################################################
  # Returns a table of key-value pairs that must be posted to the
  # sign-in URL for trusted sign-in. Use HTTP POST to do this. Be aware
  # that the values in the table are neither URL nor HTML escaped and
  # may have to be escaped if you are inserting them in code such as
  # an HTML form.
  #
  # The user to be trusted on the local site is passed in as string
  # 'user'.
  #
  # Optionally, 'retcode' specifies the resource to which successful
  # sign-in is redirected, such as Windows Live Mail, and is typically
  # a string in the format 'id=2000'. If you pass in the value from
  # getAppRetCode instead, sign-in will be redirected to the
  # application. Otherwise, an HTTP 200 response is returned.
  #####################################################################
  def getTrustedParams(user, retcode=nil)
    token = getTrustedToken(user)
    return unless token
    token = %{<wst:RequestSecurityTokenResponse xmlns:wst="http://schemas.xmlsoap.org/ws/2005/02/trust"><wst:RequestedSecurityToken><wsse:BinarySecurityToken xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">#{token}</wsse:BinarySecurityToken></wst:RequestedSecurityToken><wsp:AppliesTo xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy"><wsa:EndpointReference xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing"><wsa:Address>uri:WindowsLiveID</wsa:Address></wsa:EndpointReference></wsp:AppliesTo></wst:RequestSecurityTokenResponse>}
    params = {}
    params['wa'] = securityalgorithm
    params['wresult'] = token
    params['wctx'] = retcode if retcode
    params
  end

  #####################################################################
  # Returns the trusted sign-in token in the format that is needed by a
  # control doing trusted sign-in.
  #
  # The user to be trusted on the local site is passed in as string
  # 'user'.
  #####################################################################
  def getTrustedToken(user)
    if user.nil? or user.empty?
      debug('Error: getTrustedToken: Null user specified.')
      return
    end
    token = "appid=#{appid}&uid=#{CGI.escape(user)}&ts=#{timestamp}"
    token += "&sig=#{e64(signToken(token))}"
    CGI.escape token
  end

  #####################################################################
  # Returns the trusted sign-in URL to use for the Windows Live Login
  # server.
  #####################################################################
  def getTrustedLoginUrl
    secureurl + "wlogin.srf"
  end

  #####################################################################
  # Returns the trusted sign-out URL to use for the Windows Live Login
  # server.
  #####################################################################
  def getTrustedLogoutUrl
    secureurl + "logout.srf?appid=#{appid}"
  end
end

#######################################################################
# Helper methods.
#######################################################################
class WindowsLiveLogin

  #######################################################################
  # Function to parse the settings file.
  #######################################################################
  def parseSettings(settingsFile)
    settings = {}
    begin
      file = File.new(settingsFile)
      doc = REXML::Document.new file
      root = doc.root
      root.each_element{|e|
        settings[e.name] = e.text
      }
    rescue Exception => e
      fatal("Error: parseSettings: Error while reading #{settingsFile}: #{e}")
    end
    return settings
  end

  #####################################################################
  # Derives the key, given the secret key and prefix as described in the
  # Web Authentication SDK documentation.
  #####################################################################
  def derive(secret, prefix)
    begin
      fatal("Nil/empty secret.") if (secret.nil? or secret.empty?)
      key = prefix + secret
      key = OpenSSL::Digest::SHA256.digest(key)
      return key[0..15]
    rescue Exception => e
      debug("Error: derive: #{e}")
      return
    end
  end

  #####################################################################
  # Parses query string and return a table
  # {String=>String}
  #
  # If a table is passed in from CGI.params, we convert it from
  # {String=>[]} to {String=>String}. I believe Rails uses symbols
  # instead of strings in general, so we convert from symbols to
  # strings here also.
  #####################################################################
  def parse(input)
    if (input.nil? or input.empty?)
      debug("Error: parse: Nil/empty input.")
      return
    end

    pairs = {}
    if (input.class == String)
      input = input.split('&')
      input.each{|pair|
        k, v = pair.split('=')
        pairs[k] = v
      }
    else
      input.each{|k, v|
        v = v[0] if (v.class == Array)
        pairs[k.to_s] = v.to_s
      }
    end
    return pairs
  end

  #####################################################################
  # Generates a time stamp suitable for the application verifier token.
  #####################################################################
  def timestamp
    Time.now.to_i.to_s
  end

  #####################################################################
  # Base64-encodes and URL-escapes a string.
  #####################################################################
  def e64(s)
    return unless s
    CGI.escape Base64.encode64(s)
  end

  #####################################################################
  # URL-unescapes and Base64-decodes a string.
  #####################################################################
  def u64(s)
    return unless s
    Base64.decode64 CGI.unescape(s)
  end

  #####################################################################
  # Fetches the contents given a URL.
  #####################################################################
  def fetch(url)
      url = URI.parse url
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == "https")
      http.request_get url.request_uri
  end
end end end end

