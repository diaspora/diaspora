# -*- ruby encoding: utf-8 -*-
require 'ostruct'

module Net # :nodoc:
  class LDAP
    begin
      require 'openssl'
      ##
      # Set to +true+ if OpenSSL is available and LDAPS is supported.
      HasOpenSSL = true
    rescue LoadError
      # :stopdoc:
      HasOpenSSL = false
      # :startdoc:
    end
  end
end
require 'socket'

require 'net/ber'
require 'net/ldap/pdu'
require 'net/ldap/filter'
require 'net/ldap/dataset'
require 'net/ldap/password'
require 'net/ldap/entry'

# == Quick-start for the Impatient
# === Quick Example of a user-authentication against an LDAP directory:
#
#  require 'rubygems'
#  require 'net/ldap'
#
#  ldap = Net::LDAP.new
#  ldap.host = your_server_ip_address
#  ldap.port = 389
#  ldap.auth "joe_user", "opensesame"
#  if ldap.bind
#    # authentication succeeded
#  else
#    # authentication failed
#  end
#
#
# === Quick Example of a search against an LDAP directory:
#
#  require 'rubygems'
#  require 'net/ldap'
#
#  ldap = Net::LDAP.new :host => server_ip_address,
#       :port => 389,
#       :auth => {
#             :method => :simple,
#             :username => "cn=manager, dc=example, dc=com",
#             :password => "opensesame"
#       }
#
#  filter = Net::LDAP::Filter.eq("cn", "George*")
#  treebase = "dc=example, dc=com"
#
#  ldap.search(:base => treebase, :filter => filter) do |entry|
#    puts "DN: #{entry.dn}"
#    entry.each do |attribute, values|
#      puts "   #{attribute}:"
#      values.each do |value|
#        puts "      --->#{value}"
#      end
#    end
#  end
#
#  p ldap.get_operation_result
#
#
# == A Brief Introduction to LDAP
#
# We're going to provide a quick, informal introduction to LDAP terminology
# and typical operations. If you're comfortable with this material, skip
# ahead to "How to use Net::LDAP." If you want a more rigorous treatment of
# this material, we recommend you start with the various IETF and ITU
# standards that relate to LDAP.
#
# === Entities
# LDAP is an Internet-standard protocol used to access directory servers.
# The basic search unit is the <i>entity, </i> which corresponds to a person
# or other domain-specific object. A directory service which supports the
# LDAP protocol typically stores information about a number of entities.
#
# === Principals
# LDAP servers are typically used to access information about people, but
# also very often about such items as printers, computers, and other
# resources. To reflect this, LDAP uses the term <i>entity, </i> or less
# commonly, <i>principal, </i> to denote its basic data-storage unit.
#
# === Distinguished Names
# In LDAP's view of the world, an entity is uniquely identified by a
# globally-unique text string called a <i>Distinguished Name, </i> originally
# defined in the X.400 standards from which LDAP is ultimately derived. Much
# like a DNS hostname, a DN is a "flattened" text representation of a string
# of tree nodes. Also like DNS (and unlike Java package names), a DN
# expresses a chain of tree-nodes written from left to right in order from
# the most-resolved node to the most-general one.
#
# If you know the DN of a person or other entity, then you can query an
# LDAP-enabled directory for information (attributes) about the entity.
# Alternatively, you can query the directory for a list of DNs matching a
# set of criteria that you supply.
#
# === Attributes
#
# In the LDAP view of the world, a DN uniquely identifies an entity.
# Information about the entity is stored as a set of <i>Attributes.</i> An
# attribute is a text string which is associated with zero or more values.
# Most LDAP-enabled directories store a well-standardized range of
# attributes, and constrain their values according to standard rules.
#
# A good example of an attribute is <tt>sn, </tt> which stands for "Surname."
# This attribute is generally used to store a person's surname, or last
# name. Most directories enforce the standard convention that an entity's
# <tt>sn</tt> attribute have <i>exactly one</i> value. In LDAP jargon, that
# means that <tt>sn</tt> must be <i>present</i> and <i>single-valued.</i>
#
# Another attribute is <tt>mail, </tt> which is used to store email
# addresses. (No, there is no attribute called "email, " perhaps because
# X.400 terminology predates the invention of the term <i>email.</i>)
# <tt>mail</tt> differs from <tt>sn</tt> in that most directories permit any
# number of values for the <tt>mail</tt> attribute, including zero.
#
# === Tree-Base
# We said above that X.400 Distinguished Names are <i>globally unique.</i>
# In a manner reminiscent of DNS, LDAP supposes that each directory server
# contains authoritative attribute data for a set of DNs corresponding to a
# specific sub-tree of the (notional) global directory tree. This subtree is
# generally configured into a directory server when it is created. It
# matters for this discussion because most servers will not allow you to
# query them unless you specify a correct tree-base.
#
# Let's say you work for the engineering department of Big Company, Inc.,
# whose internet domain is bigcompany.com. You may find that your
# departmental directory is stored in a server with a defined tree-base of
#    ou=engineering, dc=bigcompany, dc=com
# You will need to supply this string as the <i>tree-base</i> when querying
# this directory. (Ou is a very old X.400 term meaning "organizational
# unit." Dc is a more recent term meaning "domain component.")
#
# === LDAP Versions
# (stub, discuss v2 and v3)
#
# === LDAP Operations
# The essential operations are: #bind, #search, #add, #modify, #delete, and
# #rename.
#
# ==== Bind
# #bind supplies a user's authentication credentials to a server, which in
# turn verifies or rejects them. There is a range of possibilities for
# credentials, but most directories support a simple username and password
# authentication.
#
# Taken by itself, #bind can be used to authenticate a user against
# information stored in a directory, for example to permit or deny access to
# some other resource. In terms of the other LDAP operations, most
# directories require a successful #bind to be performed before the other
# operations will be permitted. Some servers permit certain operations to be
# performed with an "anonymous" binding, meaning that no credentials are
# presented by the user. (We're glossing over a lot of platform-specific
# detail here.)
#
# ==== Search
# Calling #search against the directory involves specifying a treebase, a
# set of <i>search filters, </i> and a list of attribute values. The filters
# specify ranges of possible values for particular attributes. Multiple
# filters can be joined together with AND, OR, and NOT operators. A server
# will respond to a #search by returning a list of matching DNs together
# with a set of attribute values for each entity, depending on what
# attributes the search requested.
#
# ==== Add
# #add specifies a new DN and an initial set of attribute values. If the
# operation succeeds, a new entity with the corresponding DN and attributes
# is added to the directory.
#
# ==== Modify
# #modify specifies an entity DN, and a list of attribute operations.
# #modify is used to change the attribute values stored in the directory for
# a particular entity. #modify may add or delete attributes (which are lists
# of values) or it change attributes by adding to or deleting from their
# values. Net::LDAP provides three easier methods to modify an entry's
# attribute values: #add_attribute, #replace_attribute, and
# #delete_attribute.
#
# ==== Delete
# #delete specifies an entity DN. If it succeeds, the entity and all its
# attributes is removed from the directory.
#
# ==== Rename (or Modify RDN)
# #rename (or #modify_rdn) is an operation added to version 3 of the LDAP
# protocol. It responds to the often-arising need to change the DN of an
# entity without discarding its attribute values. In earlier LDAP versions,
# the only way to do this was to delete the whole entity and add it again
# with a different DN.
#
# #rename works by taking an "old" DN (the one to change) and a "new RDN, "
# which is the left-most part of the DN string. If successful, #rename
# changes the entity DN so that its left-most node corresponds to the new
# RDN given in the request. (RDN, or "relative distinguished name, " denotes
# a single tree-node as expressed in a DN, which is a chain of tree nodes.)
#
# == How to use Net::LDAP
# To access Net::LDAP functionality in your Ruby programs, start by
# requiring the library:
#
#  require 'net/ldap'
#
# If you installed the Gem version of Net::LDAP, and depending on your
# version of Ruby and rubygems, you _may_ also need to require rubygems
# explicitly:
#
#  require 'rubygems'
#  require 'net/ldap'
#
# Most operations with Net::LDAP start by instantiating a Net::LDAP object.
# The constructor for this object takes arguments specifying the network
# location (address and port) of the LDAP server, and also the binding
# (authentication) credentials, typically a username and password. Given an
# object of class Net:LDAP, you can then perform LDAP operations by calling
# instance methods on the object. These are documented with usage examples
# below.
#
# The Net::LDAP library is designed to be very disciplined about how it
# makes network connections to servers. This is different from many of the
# standard native-code libraries that are provided on most platforms, which
# share bloodlines with the original Netscape/Michigan LDAP client
# implementations. These libraries sought to insulate user code from the
# workings of the network. This is a good idea of course, but the practical
# effect has been confusing and many difficult bugs have been caused by the
# opacity of the native libraries, and their variable behavior across
# platforms.
#
# In general, Net::LDAP instance methods which invoke server operations make
# a connection to the server when the method is called. They execute the
# operation (typically binding first) and then disconnect from the server.
# The exception is Net::LDAP#open, which makes a connection to the server
# and then keeps it open while it executes a user-supplied block.
# Net::LDAP#open closes the connection on completion of the block.
class Net::LDAP
  VERSION = "0.2.2"

  class LdapError < StandardError; end

  SearchScope_BaseObject = 0
  SearchScope_SingleLevel = 1
  SearchScope_WholeSubtree = 2
  SearchScopes = [ SearchScope_BaseObject, SearchScope_SingleLevel,
    SearchScope_WholeSubtree ]

  primitive = { 2 => :null } # UnbindRequest body
  constructed = {
    0 => :array, # BindRequest
    1 => :array, # BindResponse
    2 => :array, # UnbindRequest
    3 => :array, # SearchRequest
    4 => :array, # SearchData
    5 => :array, # SearchResult
    6 => :array, # ModifyRequest
    7 => :array, # ModifyResponse
    8 => :array, # AddRequest
    9 => :array, # AddResponse
    10 => :array, # DelRequest
    11 => :array, # DelResponse
    12 => :array, # ModifyRdnRequest
    13 => :array, # ModifyRdnResponse
    14 => :array, # CompareRequest
    15 => :array, # CompareResponse
    16 => :array, # AbandonRequest
    19 => :array, # SearchResultReferral
    24 => :array, # Unsolicited Notification
  }
  application = {
    :primitive => primitive,
    :constructed => constructed,
  }
  primitive = {
    0 => :string, # password
    1 => :string, # Kerberos v4
    2 => :string, # Kerberos v5
    3 => :string, # SearchFilter-extensible
    4 => :string, # SearchFilter-extensible
    7 => :string, # serverSaslCreds
  }
  constructed = {
    0 => :array, # RFC-2251 Control and Filter-AND
    1 => :array, # SearchFilter-OR
    2 => :array, # SearchFilter-NOT
    3 => :array, # Seach referral
    4 => :array, # unknown use in Microsoft Outlook
    5 => :array, # SearchFilter-GE
    6 => :array, # SearchFilter-LE
    7 => :array, # serverSaslCreds
    9 => :array, # SearchFilter-extensible
  }
  context_specific = {
    :primitive => primitive,
    :constructed => constructed,
  }

  AsnSyntax = Net::BER.compile_syntax(:application => application,
                                      :context_specific => context_specific)

  DefaultHost = "127.0.0.1"
  DefaultPort = 389
  DefaultAuth = { :method => :anonymous }
  DefaultTreebase = "dc=com"

  StartTlsOid = "1.3.6.1.4.1.1466.20037"

  ResultStrings = {
    0 => "Success",
    1 => "Operations Error",
    2 => "Protocol Error",
    3 => "Time Limit Exceeded",
    4 => "Size Limit Exceeded",
    12 => "Unavailable crtical extension",
    14 => "saslBindInProgress",
    16 => "No Such Attribute",
    17 => "Undefined Attribute Type",
    20 => "Attribute or Value Exists",
    32 => "No Such Object",
    34 => "Invalid DN Syntax",
    48 => "Inappropriate Authentication",
    49 => "Invalid Credentials",
    50 => "Insufficient Access Rights",
    51 => "Busy",
    52 => "Unavailable",
    53 => "Unwilling to perform",
    65 => "Object Class Violation",
    68 => "Entry Already Exists"
  }

  module LdapControls
    PagedResults = "1.2.840.113556.1.4.319" # Microsoft evil from RFC 2696
  end

  def self.result2string(code) #:nodoc:
    ResultStrings[code] || "unknown result (#{code})"
  end

  attr_accessor :host
  attr_accessor :port
  attr_accessor :base

  # Instantiate an object of type Net::LDAP to perform directory operations.
  # This constructor takes a Hash containing arguments, all of which are
  # either optional or may be specified later with other methods as
  # described below. The following arguments are supported:
  # * :host => the LDAP server's IP-address (default 127.0.0.1)
  # * :port => the LDAP server's TCP port (default 389)
  # * :auth => a Hash containing authorization parameters. Currently
  #   supported values include: {:method => :anonymous} and {:method =>
  #   :simple, :username => your_user_name, :password => your_password }
  #   The password parameter may be a Proc that returns a String.
  # * :base => a default treebase parameter for searches performed against
  #   the LDAP server. If you don't give this value, then each call to
  #   #search must specify a treebase parameter. If you do give this value,
  #   then it will be used in subsequent calls to #search that do not
  #   specify a treebase. If you give a treebase value in any particular
  #   call to #search, that value will override any treebase value you give
  #   here.
  # * :encryption => specifies the encryption to be used in communicating
  #   with the LDAP server. The value is either a Hash containing additional
  #   parameters, or the Symbol :simple_tls, which is equivalent to
  #   specifying the Hash {:method => :simple_tls}. There is a fairly large
  #   range of potential values that may be given for this parameter. See
  #   #encryption for details.
  #
  # Instantiating a Net::LDAP object does <i>not</i> result in network
  # traffic to the LDAP server. It simply stores the connection and binding
  # parameters in the object.
  def initialize(args = {})
    @host = args[:host] || DefaultHost
    @port = args[:port] || DefaultPort
    @verbose = false # Make this configurable with a switch on the class.
    @auth = args[:auth] || DefaultAuth
    @base = args[:base] || DefaultTreebase
    encryption args[:encryption] # may be nil

    if pr = @auth[:password] and pr.respond_to?(:call)
      @auth[:password] = pr.call
    end

    # This variable is only set when we are created with LDAP::open. All of
    # our internal methods will connect using it, or else they will create
    # their own.
    @open_connection = nil
  end

  # Convenience method to specify authentication credentials to the LDAP
  # server. Currently supports simple authentication requiring a username
  # and password.
  #
  # Observe that on most LDAP servers, the username is a complete DN.
  # However, with A/D, it's often possible to give only a user-name rather
  # than a complete DN. In the latter case, beware that many A/D servers are
  # configured to permit anonymous (uncredentialled) binding, and will
  # silently accept your binding as anonymous if you give an unrecognized
  # username. This is not usually what you want. (See
  # #get_operation_result.)
  #
  # <b>Important:</b> The password argument may be a Proc that returns a
  # string. This makes it possible for you to write client programs that
  # solicit passwords from users or from other data sources without showing
  # them in your code or on command lines.
  #
  #  require 'net/ldap'
  #
  #  ldap = Net::LDAP.new
  #  ldap.host = server_ip_address
  #  ldap.authenticate "cn=Your Username, cn=Users, dc=example, dc=com", "your_psw"
  #
  # Alternatively (with a password block):
  #
  #  require 'net/ldap'
  #
  #  ldap = Net::LDAP.new
  #  ldap.host = server_ip_address
  #  psw = proc { your_psw_function }
  #  ldap.authenticate "cn=Your Username, cn=Users, dc=example, dc=com", psw
  #
  def authenticate(username, password)
    password = password.call if password.respond_to?(:call)
    @auth = {
      :method => :simple,
      :username => username,
      :password => password
    }
  end
  alias_method :auth, :authenticate

  # Convenience method to specify encryption characteristics for connections
  # to LDAP servers. Called implicitly by #new and #open, but may also be
  # called by user code if desired. The single argument is generally a Hash
  # (but see below for convenience alternatives). This implementation is
  # currently a stub, supporting only a few encryption alternatives. As
  # additional capabilities are added, more configuration values will be
  # added here.
  #
  # Currently, the only supported argument is { :method => :simple_tls }.
  # (Equivalently, you may pass the symbol :simple_tls all by itself,
  # without enclosing it in a Hash.)
  #
  # The :simple_tls encryption method encrypts <i>all</i> communications
  # with the LDAP server. It completely establishes SSL/TLS encryption with
  # the LDAP server before any LDAP-protocol data is exchanged. There is no
  # plaintext negotiation and no special encryption-request controls are
  # sent to the server. <i>The :simple_tls option is the simplest, easiest
  # way to encrypt communications between Net::LDAP and LDAP servers.</i>
  # It's intended for cases where you have an implicit level of trust in the
  # authenticity of the LDAP server. No validation of the LDAP server's SSL
  # certificate is performed. This means that :simple_tls will not produce
  # errors if the LDAP server's encryption certificate is not signed by a
  # well-known Certification Authority. If you get communications or
  # protocol errors when using this option, check with your LDAP server
  # administrator. Pay particular attention to the TCP port you are
  # connecting to. It's impossible for an LDAP server to support plaintext
  # LDAP communications and <i>simple TLS</i> connections on the same port.
  # The standard TCP port for unencrypted LDAP connections is 389, but the
  # standard port for simple-TLS encrypted connections is 636. Be sure you
  # are using the correct port.
  #
  # <i>[Note: a future version of Net::LDAP will support the STARTTLS LDAP
  # control, which will enable encrypted communications on the same TCP port
  # used for unencrypted connections.]</i>
  def encryption(args)
    case args
    when :simple_tls, :start_tls
      args = { :method => args }
    end
    @encryption = args
  end

  # #open takes the same parameters as #new. #open makes a network
  # connection to the LDAP server and then passes a newly-created Net::LDAP
  # object to the caller-supplied block. Within the block, you can call any
  # of the instance methods of Net::LDAP to perform operations against the
  # LDAP directory. #open will perform all the operations in the
  # user-supplied block on the same network connection, which will be closed
  # automatically when the block finishes.
  #
  #  # (PSEUDOCODE)
  #  auth = { :method => :simple, :username => username, :password => password }
  #  Net::LDAP.open(:host => ipaddress, :port => 389, :auth => auth) do |ldap|
  #    ldap.search(...)
  #    ldap.add(...)
  #    ldap.modify(...)
  #  end
  def self.open(args)
    ldap1 = new(args)
    ldap1.open { |ldap| yield ldap }
  end

  # Returns a meaningful result any time after a protocol operation (#bind,
  # #search, #add, #modify, #rename, #delete) has completed. It returns an
  # #OpenStruct containing an LDAP result code (0 means success), and a
  # human-readable string.
  #
  #  unless ldap.bind
  #    puts "Result: #{ldap.get_operation_result.code}"
  #    puts "Message: #{ldap.get_operation_result.message}"
  #  end
  #
  # Certain operations return additional information, accessible through
  # members of the object returned from #get_operation_result. Check
  # #get_operation_result.error_message and
  # #get_operation_result.matched_dn.
  #
  #--
  # Modified the implementation, 20Mar07. We might get a hash of LDAP
  # response codes instead of a simple numeric code.
  #++
  def get_operation_result
    os = OpenStruct.new
    if @result.is_a?(Hash)
      # We might get a hash of LDAP response codes instead of a simple
      # numeric code.
      os.code = (@result[:resultCode] || "").to_i
      os.error_message = @result[:errorMessage]
      os.matched_dn = @result[:matchedDN]
    elsif @result
      os.code = @result
    else
      os.code = 0
    end
    os.message = Net::LDAP.result2string(os.code)
    os
  end

  # Opens a network connection to the server and then passes <tt>self</tt>
  # to the caller-supplied block. The connection is closed when the block
  # completes. Used for executing multiple LDAP operations without requiring
  # a separate network connection (and authentication) for each one.
  # <i>Note:</i> You do not need to log-in or "bind" to the server. This
  # will be done for you automatically. For an even simpler approach, see
  # the class method Net::LDAP#open.
  #
  #  # (PSEUDOCODE)
  #  auth = { :method => :simple, :username => username, :password => password }
  #  ldap = Net::LDAP.new(:host => ipaddress, :port => 389, :auth => auth)
  #  ldap.open do |ldap|
  #    ldap.search(...)
  #    ldap.add(...)
  #    ldap.modify(...)
  #  end
  def open
    # First we make a connection and then a binding, but we don't do
    # anything with the bind results. We then pass self to the caller's
    # block, where he will execute his LDAP operations. Of course they will
    # all generate auth failures if the bind was unsuccessful.
    raise Net::LDAP::LdapError, "Open already in progress" if @open_connection

    begin
      @open_connection = Net::LDAP::Connection.new(:host => @host,
                                                   :port => @port,
                                                   :encryption =>
                                                   @encryption)
      @open_connection.bind(@auth)
      yield self
    ensure
      @open_connection.close if @open_connection
      @open_connection = nil
    end
  end

  # Searches the LDAP directory for directory entries. Takes a hash argument
  # with parameters. Supported parameters include:
  # * :base (a string specifying the tree-base for the search);
  # * :filter (an object of type Net::LDAP::Filter, defaults to
  #   objectclass=*);
  # * :attributes (a string or array of strings specifying the LDAP
  #   attributes to return from the server);
  # * :return_result (a boolean specifying whether to return a result set).
  # * :attributes_only (a boolean flag, defaults false)
  # * :scope (one of: Net::LDAP::SearchScope_BaseObject,
  #   Net::LDAP::SearchScope_SingleLevel,
  #   Net::LDAP::SearchScope_WholeSubtree. Default is WholeSubtree.)
  # * :size (an integer indicating the maximum number of search entries to
  #   return. Default is zero, which signifies no limit.)
  #
  # #search queries the LDAP server and passes <i>each entry</i> to the
  # caller-supplied block, as an object of type Net::LDAP::Entry. If the
  # search returns 1000 entries, the block will be called 1000 times. If the
  # search returns no entries, the block will not be called.
  #
  # #search returns either a result-set or a boolean, depending on the value
  # of the <tt>:return_result</tt> argument. The default behavior is to
  # return a result set, which is an Array of objects of class
  # Net::LDAP::Entry. If you request a result set and #search fails with an
  # error, it will return nil. Call #get_operation_result to get the error
  # information returned by
  # the LDAP server.
  #
  # When <tt>:return_result => false, </tt> #search will return only a
  # Boolean, to indicate whether the operation succeeded. This can improve
  # performance with very large result sets, because the library can discard
  # each entry from memory after your block processes it.
  #
  #  treebase = "dc=example, dc=com"
  #  filter = Net::LDAP::Filter.eq("mail", "a*.com")
  #  attrs = ["mail", "cn", "sn", "objectclass"]
  #  ldap.search(:base => treebase, :filter => filter, :attributes => attrs,
  #              :return_result => false) do |entry|
  #    puts "DN: #{entry.dn}"
  #    entry.each do |attr, values|
  #      puts ".......#{attr}:"
  #      values.each do |value|
  #        puts "          #{value}"
  #      end
  #    end
  #  end
  def search(args = {})
    unless args[:ignore_server_caps]
      args[:paged_searches_supported] = paged_searches_supported?
    end

    args[:base] ||= @base
    result_set = (args and args[:return_result] == false) ? nil : []

    if @open_connection
      @result = @open_connection.search(args) { |entry|
        result_set << entry if result_set
        yield entry if block_given?
      }
    else
      @result = 0
      begin
        conn = Net::LDAP::Connection.new(:host => @host, :port => @port,
                                         :encryption => @encryption)
        if (@result = conn.bind(args[:auth] || @auth)) == 0
          @result = conn.search(args) { |entry|
            result_set << entry if result_set
            yield entry if block_given?
          }
        end
      ensure
        conn.close if conn
      end
    end

    @result == 0 and result_set
  end

  # #bind connects to an LDAP server and requests authentication based on
  # the <tt>:auth</tt> parameter passed to #open or #new. It takes no
  # parameters.
  #
  # User code does not need to call #bind directly. It will be called
  # implicitly by the library whenever you invoke an LDAP operation, such as
  # #search or #add.
  #
  # It is useful, however, to call #bind in your own code when the only
  # operation you intend to perform against the directory is to validate a
  # login credential. #bind returns true or false to indicate whether the
  # binding was successful. Reasons for failure include malformed or
  # unrecognized usernames and incorrect passwords. Use
  # #get_operation_result to find out what happened in case of failure.
  #
  # Here's a typical example using #bind to authenticate a credential which
  # was (perhaps) solicited from the user of a web site:
  #
  #  require 'net/ldap'
  #  ldap = Net::LDAP.new
  #  ldap.host = your_server_ip_address
  #  ldap.port = 389
  #  ldap.auth your_user_name, your_user_password
  #  if ldap.bind
  #    # authentication succeeded
  #  else
  #    # authentication failed
  #    p ldap.get_operation_result
  #  end
  #
  # Here's a more succinct example which does exactly the same thing, but
  # collects all the required parameters into arguments:
  #
  #  require 'net/ldap'
  #  ldap = Net::LDAP.new(:host => your_server_ip_address, :port => 389)
  #  if ldap.bind(:method => :simple, :username => your_user_name,
  #               :password => your_user_password)
  #    # authentication succeeded
  #  else
  #    # authentication failed
  #    p ldap.get_operation_result
  #  end
  #
  # You don't need to pass a user-password as a String object to bind. You
  # can also pass a Ruby Proc object which returns a string. This will cause
  # bind to execute the Proc (which might then solicit input from a user
  # with console display suppressed). The String value returned from the
  # Proc is used as the password.
  #
  # You don't have to create a new instance of Net::LDAP every time you
  # perform a binding in this way. If you prefer, you can cache the
  # Net::LDAP object and re-use it to perform subsequent bindings,
  # <i>provided</i> you call #auth to specify a new credential before
  # calling #bind. Otherwise, you'll just re-authenticate the previous user!
  # (You don't need to re-set the values of #host and #port.) As noted in
  # the documentation for #auth, the password parameter can be a Ruby Proc
  # instead of a String.
  def bind(auth = @auth)
    if @open_connection
      @result = @open_connection.bind(auth)
    else
      begin
        conn = Connection.new(:host => @host, :port => @port,
                              :encryption => @encryption)
        @result = conn.bind(auth)
      ensure
        conn.close if conn
      end
    end

    @result == 0
  end

  # #bind_as is for testing authentication credentials.
  #
  # As described under #bind, most LDAP servers require that you supply a
  # complete DN as a binding-credential, along with an authenticator such as
  # a password. But for many applications (such as authenticating users to a
  # Rails application), you often don't have a full DN to identify the user.
  # You usually get a simple identifier like a username or an email address,
  # along with a password. #bind_as allows you to authenticate these
  # user-identifiers.
  #
  # #bind_as is a combination of a search and an LDAP binding. First, it
  # connects and binds to the directory as normal. Then it searches the
  # directory for an entry corresponding to the email address, username, or
  # other string that you supply. If the entry exists, then #bind_as will
  # <b>re-bind</b> as that user with the password (or other authenticator)
  # that you supply.
  #
  # #bind_as takes the same parameters as #search, <i>with the addition of
  # an authenticator.</i> Currently, this authenticator must be
  # <tt>:password</tt>. Its value may be either a String, or a +proc+ that
  # returns a String. #bind_as returns +false+ on failure. On success, it
  # returns a result set, just as #search does. This result set is an Array
  # of objects of type Net::LDAP::Entry. It contains the directory
  # attributes corresponding to the user. (Just test whether the return
  # value is logically true, if you don't need this additional information.)
  #
  # Here's how you would use #bind_as to authenticate an email address and
  # password:
  #
  #  require 'net/ldap'
  #
  #  user, psw = "joe_user@yourcompany.com", "joes_psw"
  #
  #  ldap = Net::LDAP.new
  #  ldap.host = "192.168.0.100"
  #  ldap.port = 389
  #  ldap.auth "cn=manager, dc=yourcompany, dc=com", "topsecret"
  #
  #  result = ldap.bind_as(:base => "dc=yourcompany, dc=com",
  #                        :filter => "(mail=#{user})",
  #                        :password => psw)
  #  if result
  #    puts "Authenticated #{result.first.dn}"
  #  else
  #    puts "Authentication FAILED."
  #  end
  def bind_as(args = {})
    result = false
    open { |me|
      rs = search args
      if rs and rs.first and dn = rs.first.dn
        password = args[:password]
        password = password.call if password.respond_to?(:call)
        result = rs if bind(:method => :simple, :username => dn,
                            :password => password)
      end
    }
    result
  end

  # Adds a new entry to the remote LDAP server.
  # Supported arguments:
  # :dn :: Full DN of the new entry
  # :attributes :: Attributes of the new entry.
  #
  # The attributes argument is supplied as a Hash keyed by Strings or
  # Symbols giving the attribute name, and mapping to Strings or Arrays of
  # Strings giving the actual attribute values. Observe that most LDAP
  # directories enforce schema constraints on the attributes contained in
  # entries. #add will fail with a server-generated error if your attributes
  # violate the server-specific constraints.
  #
  # Here's an example:
  #
  #  dn = "cn=George Smith, ou=people, dc=example, dc=com"
  #  attr = {
  #    :cn => "George Smith",
  #    :objectclass => ["top", "inetorgperson"],
  #    :sn => "Smith",
  #    :mail => "gsmith@example.com"
  #  }
  #  Net::LDAP.open(:host => host) do |ldap|
  #    ldap.add(:dn => dn, :attributes => attr)
  #  end
  def add(args)
    if @open_connection
      @result = @open_connection.add(args)
    else
      @result = 0
      begin
        conn = Connection.new(:host => @host, :port => @port,
                              :encryption => @encryption)
        if (@result = conn.bind(args[:auth] || @auth)) == 0
          @result = conn.add(args)
        end
      ensure
        conn.close if conn
      end
    end
    @result == 0
  end

  # Modifies the attribute values of a particular entry on the LDAP
  # directory. Takes a hash with arguments. Supported arguments are:
  # :dn :: (the full DN of the entry whose attributes are to be modified)
  # :operations :: (the modifications to be performed, detailed next)
  #
  # This method returns True or False to indicate whether the operation
  # succeeded or failed, with extended information available by calling
  # #get_operation_result.
  #
  # Also see #add_attribute, #replace_attribute, or #delete_attribute, which
  # provide simpler interfaces to this functionality.
  #
  # The LDAP protocol provides a full and well thought-out set of operations
  # for changing the values of attributes, but they are necessarily somewhat
  # complex and not always intuitive. If these instructions are confusing or
  # incomplete, please send us email or create a bug report on rubyforge.
  #
  # The :operations parameter to #modify takes an array of
  # operation-descriptors. Each individual operation is specified in one
  # element of the array, and most LDAP servers will attempt to perform the
  # operations in order.
  #
  # Each of the operations appearing in the Array must itself be an Array
  # with exactly three elements: an operator:: must be :add, :replace, or
  # :delete an attribute name:: the attribute name (string or symbol) to
  # modify a value:: either a string or an array of strings.
  #
  # The :add operator will, unsurprisingly, add the specified values to the
  # specified attribute. If the attribute does not already exist, :add will
  # create it. Most LDAP servers will generate an error if you try to add a
  # value that already exists.
  #
  # :replace will erase the current value(s) for the specified attribute, if
  # there are any, and replace them with the specified value(s).
  #
  # :delete will remove the specified value(s) from the specified attribute.
  # If you pass nil, an empty string, or an empty array as the value
  # parameter to a :delete operation, the _entire_ _attribute_ will be
  # deleted, along with all of its values.
  #
  # For example:
  #
  #  dn = "mail=modifyme@example.com, ou=people, dc=example, dc=com"
  #  ops = [
  #    [:add, :mail, "aliasaddress@example.com"],
  #    [:replace, :mail, ["newaddress@example.com", "newalias@example.com"]],
  #    [:delete, :sn, nil]
  #  ]
  #  ldap.modify :dn => dn, :operations => ops
  #
  # <i>(This example is contrived since you probably wouldn't add a mail
  # value right before replacing the whole attribute, but it shows that
  # order of execution matters. Also, many LDAP servers won't let you delete
  # SN because that would be a schema violation.)</i>
  #
  # It's essential to keep in mind that if you specify more than one
  # operation in a call to #modify, most LDAP servers will attempt to
  # perform all of the operations in the order you gave them. This matters
  # because you may specify operations on the same attribute which must be
  # performed in a certain order.
  #
  # Most LDAP servers will _stop_ processing your modifications if one of
  # them causes an error on the server (such as a schema-constraint
  # violation). If this happens, you will probably get a result code from
  # the server that reflects only the operation that failed, and you may or
  # may not get extended information that will tell you which one failed.
  # #modify has no notion of an atomic transaction. If you specify a chain
  # of modifications in one call to #modify, and one of them fails, the
  # preceding ones will usually not be "rolled back, " resulting in a
  # partial update. This is a limitation of the LDAP protocol, not of
  # Net::LDAP.
  #
  # The lack of transactional atomicity in LDAP means that you're usually
  # better off using the convenience methods #add_attribute,
  # #replace_attribute, and #delete_attribute, which are are wrappers over
  # #modify. However, certain LDAP servers may provide concurrency
  # semantics, in which the several operations contained in a single #modify
  # call are not interleaved with other modification-requests received
  # simultaneously by the server. It bears repeating that this concurrency
  # does _not_ imply transactional atomicity, which LDAP does not provide.
  def modify(args)
    if @open_connection
      @result = @open_connection.modify(args)
    else
      @result = 0
      begin
        conn = Connection.new(:host => @host, :port => @port,
                              :encryption => @encryption)
        if (@result = conn.bind(args[:auth] || @auth)) == 0
          @result = conn.modify(args)
        end
      ensure
        conn.close if conn
      end
    end
    @result == 0
  end

  # Add a value to an attribute. Takes the full DN of the entry to modify,
  # the name (Symbol or String) of the attribute, and the value (String or
  # Array). If the attribute does not exist (and there are no schema
  # violations), #add_attribute will create it with the caller-specified
  # values. If the attribute already exists (and there are no schema
  # violations), the caller-specified values will be _added_ to the values
  # already present.
  #
  # Returns True or False to indicate whether the operation succeeded or
  # failed, with extended information available by calling
  # #get_operation_result. See also #replace_attribute and
  # #delete_attribute.
  #
  #  dn = "cn=modifyme, dc=example, dc=com"
  #  ldap.add_attribute dn, :mail, "newmailaddress@example.com"
  def add_attribute(dn, attribute, value)
    modify(:dn => dn, :operations => [[:add, attribute, value]])
  end

  # Replace the value of an attribute. #replace_attribute can be thought of
  # as equivalent to calling #delete_attribute followed by #add_attribute.
  # It takes the full DN of the entry to modify, the name (Symbol or String)
  # of the attribute, and the value (String or Array). If the attribute does
  # not exist, it will be created with the caller-specified value(s). If the
  # attribute does exist, its values will be _discarded_ and replaced with
  # the caller-specified values.
  #
  # Returns True or False to indicate whether the operation succeeded or
  # failed, with extended information available by calling
  # #get_operation_result. See also #add_attribute and #delete_attribute.
  #
  #  dn = "cn=modifyme, dc=example, dc=com"
  #  ldap.replace_attribute dn, :mail, "newmailaddress@example.com"
  def replace_attribute(dn, attribute, value)
    modify(:dn => dn, :operations => [[:replace, attribute, value]])
  end

  # Delete an attribute and all its values. Takes the full DN of the entry
  # to modify, and the name (Symbol or String) of the attribute to delete.
  #
  # Returns True or False to indicate whether the operation succeeded or
  # failed, with extended information available by calling
  # #get_operation_result. See also #add_attribute and #replace_attribute.
  #
  #  dn = "cn=modifyme, dc=example, dc=com"
  #  ldap.delete_attribute dn, :mail
  def delete_attribute(dn, attribute)
    modify(:dn => dn, :operations => [[:delete, attribute, nil]])
  end

  # Rename an entry on the remote DIS by changing the last RDN of its DN.
  #
  # _Documentation_ _stub_
  def rename(args)
    if @open_connection
      @result = @open_connection.rename(args)
    else
      @result = 0
      begin
        conn = Connection.new(:host => @host, :port => @port,
                              :encryption => @encryption)
        if (@result = conn.bind(args[:auth] || @auth)) == 0
          @result = conn.rename(args)
        end
      ensure
        conn.close if conn
      end
    end
    @result == 0
  end
  alias_method :modify_rdn, :rename

  # Delete an entry from the LDAP directory. Takes a hash of arguments. The
  # only supported argument is :dn, which must give the complete DN of the
  # entry to be deleted.
  #
  # Returns True or False to indicate whether the delete succeeded. Extended
  # status information is available by calling #get_operation_result.
  #
  #  dn = "mail=deleteme@example.com, ou=people, dc=example, dc=com"
  #  ldap.delete :dn => dn
  def delete(args)
    if @open_connection
      @result = @open_connection.delete(args)
    else
      @result = 0
      begin
        conn = Connection.new(:host => @host, :port => @port,
                              :encryption => @encryption)
        if (@result = conn.bind(args[:auth] || @auth)) == 0
          @result = conn.delete(args)
        end
      ensure
        conn.close
      end
    end
    @result == 0
  end

  # This method is experimental and subject to change. Return the rootDSE
  # record from the LDAP server as a Net::LDAP::Entry, or an empty Entry if
  # the server doesn't return the record.
  #--
  # cf. RFC4512 graf 5.1.
  # Note that the rootDSE record we return on success has an empty DN, which
  # is correct. On failure, the empty Entry will have a nil DN. There's no
  # real reason for that, so it can be changed if desired. The funky
  # number-disagreements in the set of attribute names is correct per the
  # RFC. We may be called by #search itself, which may need to determine
  # things like paged search capabilities. So to avoid an infinite regress,
  # set :ignore_server_caps, which prevents us getting called recursively.
  #++
  def search_root_dse
    rs = search(:ignore_server_caps => true, :base => "",
                :scope => SearchScope_BaseObject,
                :attributes => [ :namingContexts, :supportedLdapVersion,
                  :altServer, :supportedControl, :supportedExtension,
                  :supportedFeatures, :supportedSASLMechanisms])
    (rs and rs.first) or Net::LDAP::Entry.new
  end

  # Return the root Subschema record from the LDAP server as a
  # Net::LDAP::Entry, or an empty Entry if the server doesn't return the
  # record. On success, the Net::LDAP::Entry returned from this call will
  # have the attributes :dn, :objectclasses, and :attributetypes. If there
  # is an error, call #get_operation_result for more information.
  #
  #  ldap = Net::LDAP.new
  #  ldap.host = "your.ldap.host"
  #  ldap.auth "your-user-dn", "your-psw"
  #  subschema_entry = ldap.search_subschema_entry
  #
  #  subschema_entry.attributetypes.each do |attrtype|
  #    # your code
  #  end
  #
  #  subschema_entry.objectclasses.each do |attrtype|
  #    # your code
  #  end
  #--
  # cf. RFC4512 section 4, particulary graff 4.4.
  # The :dn attribute in the returned Entry is the subschema name as
  # returned from the server. Set :ignore_server_caps, see the notes in
  # search_root_dse.
  #++
  def search_subschema_entry
    rs = search(:ignore_server_caps => true, :base => "",
                :scope => SearchScope_BaseObject,
                :attributes => [:subschemaSubentry])
    return Net::LDAP::Entry.new unless (rs and rs.first)

    subschema_name = rs.first.subschemasubentry
    return Net::LDAP::Entry.new unless (subschema_name and subschema_name.first)

    rs = search(:ignore_server_caps => true, :base => subschema_name.first,
                :scope => SearchScope_BaseObject,
                :filter => "objectclass=subschema",
                :attributes => [:objectclasses, :attributetypes])
    (rs and rs.first) or Net::LDAP::Entry.new
  end

  #--
  # Convenience method to query server capabilities.
  # Only do this once per Net::LDAP object.
  # Note, we call a search, and we might be called from inside a search!
  # MUST refactor the root_dse call out.
  #++
  def paged_searches_supported?
    @server_caps ||= search_root_dse
    @server_caps[:supportedcontrol].include?(Net::LDAP::LdapControls::PagedResults)
  end
end # class LDAP

# This is a private class used internally by the library. It should not
# be called by user code.
class Net::LDAP::Connection #:nodoc:
  LdapVersion = 3
  MaxSaslChallenges = 10

  def initialize(server)
    begin
      @conn = TCPSocket.new(server[:host], server[:port])
    rescue SocketError
      raise Net::LDAP::LdapError, "No such address or other socket error."
    rescue Errno::ECONNREFUSED
      raise Net::LDAP::LdapError, "Server #{server[:host]} refused connection on port #{server[:port]}."
    end

    if server[:encryption]
      setup_encryption server[:encryption]
    end

    yield self if block_given?
  end

  module GetbyteForSSLSocket
    def getbyte
      getc.ord
    end
  end

  def self.wrap_with_ssl(io)
    raise Net::LDAP::LdapError, "OpenSSL is unavailable" unless Net::LDAP::HasOpenSSL
    ctx = OpenSSL::SSL::SSLContext.new
    conn = OpenSSL::SSL::SSLSocket.new(io, ctx)
    conn.connect
    conn.sync_close = true

    conn.extend(GetbyteForSSLSocket) unless conn.respond_to?(:getbyte)

    conn
  end

  #--
  # Helper method called only from new, and only after we have a
  # successfully-opened @conn instance variable, which is a TCP connection.
  # Depending on the received arguments, we establish SSL, potentially
  # replacing the value of @conn accordingly. Don't generate any errors here
  # if no encryption is requested. DO raise Net::LDAP::LdapError objects if encryption
  # is requested and we have trouble setting it up. That includes if OpenSSL
  # is not set up on the machine. (Question: how does the Ruby OpenSSL
  # wrapper react in that case?) DO NOT filter exceptions raised by the
  # OpenSSL library. Let them pass back to the user. That should make it
  # easier for us to debug the problem reports. Presumably (hopefully?) that
  # will also produce recognizable errors if someone tries to use this on a
  # machine without OpenSSL.
  #
  # The simple_tls method is intended as the simplest, stupidest, easiest
  # solution for people who want nothing more than encrypted comms with the
  # LDAP server. It doesn't do any server-cert validation and requires
  # nothing in the way of key files and root-cert files, etc etc. OBSERVE:
  # WE REPLACE the value of @conn, which is presumed to be a connected
  # TCPSocket object.
  #
  # The start_tls method is supported by many servers over the standard LDAP
  # port. It does not require an alternative port for encrypted
  # communications, as with simple_tls. Thanks for Kouhei Sutou for
  # generously contributing the :start_tls path.
  #++
  def setup_encryption(args)
    case args[:method]
    when :simple_tls
      @conn = self.class.wrap_with_ssl(@conn)
      # additional branches requiring server validation and peer certs, etc.
      # go here.
    when :start_tls
      msgid = next_msgid.to_ber
      request = [Net::LDAP::StartTlsOid.to_ber].to_ber_appsequence(Net::LDAP::PDU::ExtendedRequest)
      request_pkt = [msgid, request].to_ber_sequence
      @conn.write request_pkt
      be = @conn.read_ber(Net::LDAP::AsnSyntax)
      raise Net::LDAP::LdapError, "no start_tls result" if be.nil?
      pdu = Net::LDAP::PDU.new(be)
      raise Net::LDAP::LdapError, "no start_tls result" if pdu.nil?
      if pdu.result_code.zero?
        @conn = self.class.wrap_with_ssl(@conn)
      else
        raise Net::LDAP::LdapError, "start_tls failed: #{pdu.result_code}"
      end
    else
      raise Net::LDAP::LdapError, "unsupported encryption method #{args[:method]}"
    end
  end

  #--
  # This is provided as a convenience method to make sure a connection
  # object gets closed without waiting for a GC to happen. Clients shouldn't
  # have to call it, but perhaps it will come in handy someday.
  #++
  def close
    @conn.close
    @conn = nil
  end

  def next_msgid
    @msgid ||= 0
    @msgid += 1
  end

  def bind(auth)
    meth = auth[:method]
    if [:simple, :anonymous, :anon].include?(meth)
      bind_simple auth
    elsif meth == :sasl
      bind_sasl(auth)
    elsif meth == :gss_spnego
      bind_gss_spnego(auth)
    else
      raise Net::LDAP::LdapError, "Unsupported auth method (#{meth})"
    end
  end

  #--
  # Implements a simple user/psw authentication. Accessed by calling #bind
  # with a method of :simple or :anonymous.
  #++
  def bind_simple(auth)
    user, psw = if auth[:method] == :simple
                  [auth[:username] || auth[:dn], auth[:password]]
                else
                  ["", ""]
                end

    raise Net::LDAP::LdapError, "Invalid binding information" unless (user && psw)

    msgid = next_msgid.to_ber
    request = [LdapVersion.to_ber, user.to_ber,
      psw.to_ber_contextspecific(0)].to_ber_appsequence(0)
    request_pkt = [msgid, request].to_ber_sequence
    @conn.write request_pkt

    (be = @conn.read_ber(Net::LDAP::AsnSyntax) and pdu = Net::LDAP::PDU.new(be)) or raise Net::LDAP::LdapError, "no bind result"

    pdu.result_code
  end

  #--
  # Required parameters: :mechanism, :initial_credential and
  # :challenge_response
  #
  # Mechanism is a string value that will be passed in the SASL-packet's
  # "mechanism" field.
  #
  # Initial credential is most likely a string. It's passed in the initial
  # BindRequest that goes to the server. In some protocols, it may be empty.
  #
  # Challenge-response is a Ruby proc that takes a single parameter and
  # returns an object that will typically be a string. The
  # challenge-response block is called when the server returns a
  # BindResponse with a result code of 14 (saslBindInProgress). The
  # challenge-response block receives a parameter containing the data
  # returned by the server in the saslServerCreds field of the LDAP
  # BindResponse packet. The challenge-response block may be called multiple
  # times during the course of a SASL authentication, and each time it must
  # return a value that will be passed back to the server as the credential
  # data in the next BindRequest packet.
  #++
  def bind_sasl(auth)
    mech, cred, chall = auth[:mechanism], auth[:initial_credential],
      auth[:challenge_response]
    raise Net::LDAP::LdapError, "Invalid binding information" unless (mech && cred && chall)

    n = 0
    loop {
      msgid = next_msgid.to_ber
      sasl = [mech.to_ber, cred.to_ber].to_ber_contextspecific(3)
      request = [LdapVersion.to_ber, "".to_ber, sasl].to_ber_appsequence(0)
      request_pkt = [msgid, request].to_ber_sequence
      @conn.write request_pkt

      (be = @conn.read_ber(Net::LDAP::AsnSyntax) and pdu = Net::LDAP::PDU.new(be)) or raise Net::LDAP::LdapError, "no bind result"
      return pdu.result_code unless pdu.result_code == 14 # saslBindInProgress
      raise Net::LDAP::LdapError, "sasl-challenge overflow" if ((n += 1) > MaxSaslChallenges)

      cred = chall.call(pdu.result_server_sasl_creds)
    }

    raise Net::LDAP::LdapError, "why are we here?"
  end
  private :bind_sasl

  #--
  # PROVISIONAL, only for testing SASL implementations. DON'T USE THIS YET.
  # Uses Kohei Kajimoto's Ruby/NTLM. We have to find a clean way to
  # integrate it without introducing an external dependency.
  #
  # This authentication method is accessed by calling #bind with a :method
  # parameter of :gss_spnego. It requires :username and :password
  # attributes, just like the :simple authentication method. It performs a
  # GSS-SPNEGO authentication with the server, which is presumed to be a
  # Microsoft Active Directory.
  #++
  def bind_gss_spnego(auth)
    require 'ntlm'

    user, psw = [auth[:username] || auth[:dn], auth[:password]]
    raise Net::LDAP::LdapError, "Invalid binding information" unless (user && psw)

    nego = proc { |challenge|
      t2_msg = NTLM::Message.parse(challenge)
      t3_msg = t2_msg.response({ :user => user, :password => psw },
                               { :ntlmv2 => true })
      t3_msg.serialize
    }

    bind_sasl(:method => :sasl, :mechanism => "GSS-SPNEGO",
              :initial_credential => NTLM::Message::Type1.new.serialize,
              :challenge_response => nego)
  end
  private :bind_gss_spnego

  #--
  # Alternate implementation, this yields each search entry to the caller as
  # it are received.
  #
  # TODO: certain search parameters are hardcoded.
  # TODO: if we mis-parse the server results or the results are wrong, we
  # can block forever. That's because we keep reading results until we get a
  # type-5 packet, which might never come. We need to support the time-limit
  # in the protocol.
  #++
  def search(args = {})
    search_filter = (args && args[:filter]) || 
      Net::LDAP::Filter.eq("objectclass", "*")
    search_filter = Net::LDAP::Filter.construct(search_filter) if search_filter.is_a?(String)
    search_base = (args && args[:base]) || "dc=example, dc=com"
    search_attributes = ((args && args[:attributes]) || []).map { |attr| attr.to_s.to_ber}
    return_referrals = args && args[:return_referrals] == true
    sizelimit = (args && args[:size].to_i) || 0
    raise Net::LDAP::LdapError, "invalid search-size" unless sizelimit >= 0
    paged_searches_supported = (args && args[:paged_searches_supported])

    attributes_only = (args and args[:attributes_only] == true)
    scope = args[:scope] || Net::LDAP::SearchScope_WholeSubtree
    raise Net::LDAP::LdapError, "invalid search scope" unless Net::LDAP::SearchScopes.include?(scope)

    # An interesting value for the size limit would be close to A/D's
    # built-in page limit of 1000 records, but openLDAP newer than version
    # 2.2.0 chokes on anything bigger than 126. You get a silent error that
    # is easily visible by running slapd in debug mode. Go figure.
    #
    # Changed this around 06Sep06 to support a caller-specified search-size
    # limit. Because we ALWAYS do paged searches, we have to work around the
    # problem that it's not legal to specify a "normal" sizelimit (in the
    # body of the search request) that is larger than the page size we're
    # requesting. Unfortunately, I have the feeling that this will break
    # with LDAP servers that don't support paged searches!!!
    #
    # (Because we pass zero as the sizelimit on search rounds when the
    # remaining limit is larger than our max page size of 126. In these
    # cases, I think the caller's search limit will be ignored!)
    #
    # CONFIRMED: This code doesn't work on LDAPs that don't support paged
    # searches when the size limit is larger than 126. We're going to have
    # to do a root-DSE record search and not do a paged search if the LDAP
    # doesn't support it. Yuck.
    rfc2696_cookie = [126, ""]
    result_code = 0
    n_results = 0

    loop {
      # should collect this into a private helper to clarify the structure
      query_limit = 0
      if sizelimit > 0
        if paged_searches_supported
          query_limit = (((sizelimit - n_results) < 126) ? (sizelimit -
                                                            n_results) : 0)
        else
          query_limit = sizelimit
        end
      end

      request = [
        search_base.to_ber,
        scope.to_ber_enumerated,
        0.to_ber_enumerated,
        query_limit.to_ber, # size limit
        0.to_ber,
        attributes_only.to_ber,
        search_filter.to_ber,
        search_attributes.to_ber_sequence
      ].to_ber_appsequence(3)

      controls = []
      controls <<
        [
          Net::LDAP::LdapControls::PagedResults.to_ber,
          # Criticality MUST be false to interoperate with normal LDAPs.
          false.to_ber,
          rfc2696_cookie.map{ |v| v.to_ber}.to_ber_sequence.to_s.to_ber
        ].to_ber_sequence if paged_searches_supported
      controls = controls.to_ber_contextspecific(0)

      pkt = [next_msgid.to_ber, request, controls].to_ber_sequence
      @conn.write pkt

      result_code = 0
      controls = []

      while (be = @conn.read_ber(Net::LDAP::AsnSyntax)) && (pdu = Net::LDAP::PDU.new(be))
        case pdu.app_tag
        when 4 # search-data
          n_results += 1
          yield pdu.search_entry if block_given?
        when 19 # search-referral
          if return_referrals
            if block_given?
              se = Net::LDAP::Entry.new
              se[:search_referrals] = (pdu.search_referrals || [])
              yield se
            end
          end
        when 5 # search-result
          result_code = pdu.result_code
          controls = pdu.result_controls
          break
        else
          raise Net::LDAP::LdapError, "invalid response-type in search: #{pdu.app_tag}"
        end
      end

      # When we get here, we have seen a type-5 response. If there is no
      # error AND there is an RFC-2696 cookie, then query again for the next
      # page of results. If not, we're done. Don't screw this up or we'll
      # break every search we do.
      #
      # Noticed 02Sep06, look at the read_ber call in this loop, shouldn't
      # that have a parameter of AsnSyntax? Does this just accidentally
      # work? According to RFC-2696, the value expected in this position is
      # of type OCTET STRING, covered in the default syntax supported by
      # read_ber, so I guess we're ok.
      more_pages = false
      if result_code == 0 and controls
        controls.each do |c|
          if c.oid == Net::LDAP::LdapControls::PagedResults
            # just in case some bogus server sends us more than 1 of these.
            more_pages = false
            if c.value and c.value.length > 0
              cookie = c.value.read_ber[1]
              if cookie and cookie.length > 0
                rfc2696_cookie[1] = cookie
                more_pages = true
              end
            end
          end
        end
      end

      break unless more_pages
    } # loop

    result_code
  end

  MODIFY_OPERATIONS = { #:nodoc:
    :add => 0,
    :delete => 1,
    :replace => 2
  }

  def self.modify_ops(operations)
    ops = []
    if operations
      operations.each { |op, attrib, values|
        # TODO, fix the following line, which gives a bogus error if the
        # opcode is invalid.
        op_ber = MODIFY_OPERATIONS[op.to_sym].to_ber_enumerated
        values = [ values ].flatten.map { |v| v.to_ber if v }.to_ber_set
        values = [ attrib.to_s.to_ber, values ].to_ber_sequence
        ops << [ op_ber, values ].to_ber
      }
    end
    ops
  end

  #--
  # TODO: need to support a time limit, in case the server fails to respond.
  # TODO: We're throwing an exception here on empty DN. Should return a
  # proper error instead, probaby from farther up the chain.
  # TODO: If the user specifies a bogus opcode, we'll throw a confusing
  # error here ("to_ber_enumerated is not defined on nil").
  #++
  def modify(args)
    modify_dn = args[:dn] or raise "Unable to modify empty DN"
    ops = self.class.modify_ops args[:operations]
    request = [ modify_dn.to_ber,
      ops.to_ber_sequence ].to_ber_appsequence(6)
    pkt = [ next_msgid.to_ber, request ].to_ber_sequence
    @conn.write pkt

    (be = @conn.read_ber(Net::LDAP::AsnSyntax)) && (pdu = Net::LDAP::PDU.new(be)) && (pdu.app_tag == 7) or raise Net::LDAP::LdapError, "response missing or invalid"
    pdu.result_code
  end

  #--
  # TODO: need to support a time limit, in case the server fails to respond.
  # Unlike other operation-methods in this class, we return a result hash
  # rather than a simple result number. This is experimental, and eventually
  # we'll want to do this with all the others. The point is to have access
  # to the error message and the matched-DN returned by the server.
  #++
  def add(args)
    add_dn = args[:dn] or raise Net::LDAP::LdapError, "Unable to add empty DN"
    add_attrs = []
    a = args[:attributes] and a.each { |k, v|
      add_attrs << [ k.to_s.to_ber, Array(v).map { |m| m.to_ber}.to_ber_set ].to_ber_sequence
    }

    request = [add_dn.to_ber, add_attrs.to_ber_sequence].to_ber_appsequence(8)
    pkt = [next_msgid.to_ber, request].to_ber_sequence
    @conn.write pkt

    (be = @conn.read_ber(Net::LDAP::AsnSyntax)) && (pdu = Net::LDAP::PDU.new(be)) && (pdu.app_tag == 9) or raise Net::LDAP::LdapError, "response missing or invalid"
    pdu.result_code
  end

  #--
  # TODO: need to support a time limit, in case the server fails to respond.
  #++
  def rename args
    old_dn = args[:olddn] or raise "Unable to rename empty DN"
    new_rdn = args[:newrdn] or raise "Unable to rename to empty RDN"
    delete_attrs = args[:delete_attributes] ? true : false
		new_superior = args[:new_superior]

		request = [old_dn.to_ber, new_rdn.to_ber, delete_attrs.to_ber]
		request << new_superior.to_ber unless new_superior == nil
  	
    pkt = [next_msgid.to_ber, request.to_ber_appsequence(12)].to_ber_sequence
    @conn.write pkt

    (be = @conn.read_ber(AsnSyntax)) && (pdu = LdapPdu.new( be )) && (pdu.app_tag == 13) or raise LdapError.new( "response missing or invalid" )
    pdu.result_code
  end

  #--
  # TODO, need to support a time limit, in case the server fails to respond.
  #++
  def delete(args)
    dn = args[:dn] or raise "Unable to delete empty DN"

    request = dn.to_s.to_ber_application_string(10)
    pkt = [next_msgid.to_ber, request].to_ber_sequence
    @conn.write pkt

    (be = @conn.read_ber(Net::LDAP::AsnSyntax)) && (pdu = Net::LDAP::PDU.new(be)) && (pdu.app_tag == 11) or raise Net::LDAP::LdapError, "response missing or invalid"
    pdu.result_code
  end
end # class Connection
