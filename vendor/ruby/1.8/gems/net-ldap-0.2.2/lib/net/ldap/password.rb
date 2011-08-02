# -*- ruby encoding: utf-8 -*-
require 'digest/sha1'
require 'digest/md5'

class Net::LDAP::Password
  class << self
    # Generate a password-hash suitable for inclusion in an LDAP attribute.
    # Pass a hash type (currently supported: :md5 and :sha) and a plaintext
    # password. This function will return a hashed representation.
    #
    #--
    # STUB: This is here to fulfill the requirements of an RFC, which
    # one?
    #
    # TODO, gotta do salted-sha and (maybe)salted-md5. Should we provide
    # sha1 as a synonym for sha1? I vote no because then should you also
    # provide ssha1 for symmetry?
    def generate(type, str)
      digest, digest_name = case type
                            when :md5
                              [Digest::MD5.new, 'MD5']
                            when :sha
                              [Digest::SHA1.new, 'SHA']
                            else
                              raise Net::LDAP::LdapError, "Unsupported password-hash type (#{type})"
                            end
      digest << str.to_s
      return "{#{digest_name}}#{[digest.digest].pack('m').chomp }"
    end
  end
end
