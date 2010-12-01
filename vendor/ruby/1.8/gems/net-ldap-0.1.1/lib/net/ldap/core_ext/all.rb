require 'net/ldap/core_ext/array'
require 'net/ldap/core_ext/string'
require 'net/ldap/core_ext/bignum'
require 'net/ldap/core_ext/fixnum'
require 'net/ldap/core_ext/false_class'
require 'net/ldap/core_ext/true_class'

class Array
  include Net::LDAP::Extensions::Array
end

class String
  include Net::BER::BERParser
  include Net::LDAP::Extensions::String
end

class Bignum
  include Net::LDAP::Extensions::Bignum
end

class Fixnum
  include Net::LDAP::Extensions::Fixnum
end

class FalseClass
  include Net::LDAP::Extensions::FalseClass
end

class TrueClass
  include Net::LDAP::Extensions::TrueClass
end

class IO
  include Net::BER::BERParser
end

class StringIO
  include Net::BER::BERParser
end

class OpenSSL::SSL::SSLSocket
  include Net::BER::BERParser
end
