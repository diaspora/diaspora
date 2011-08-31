#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Add URL safe Base64 support
module Base64
  module_function
  # Returns the Base64-encoded version of +bin+.
  # This method complies with RFC 4648.
  # No line feeds are added.
  def strict_encode64(bin)
    [bin].pack("m0")
  end

  # Returns the Base64-decoded version of +str+.
  # This method complies with RFC 4648.
  # ArgumentError is raised if +str+ is incorrectly padded or contains
  # non-alphabet characters.  Note that CR or LF are also rejected.
  def strict_decode64(str)
    Rails.logger.info("trying to decode string: " + str)
    str.unpack("m0").first
  end

  # Returns the Base64-encoded version of +bin+.
  # This method complies with ``Base 64 Encoding with URL and Filename Safe
  # Alphabet'' in RFC 4648.
  # The alphabet uses '-' instead of '+' and '_' instead of '/'.
  def urlsafe_encode64(bin)
    strict_encode64(bin).tr("+/", "-_")
  end

  # Returns the Base64-decoded version of +str+.
  # This method complies with ``Base 64 Encoding with URL and Filename Safe
  # Alphabet'' in RFC 4648.
  # The alphabet uses '-' instead of '+' and '_' instead of '/'.
  def urlsafe_decode64(str)
    strict_decode64(str.tr("-_", "+/"))
  end
end

# Verify documents secured with Magic Signatures
module Salmon
  autoload :Slap,             File.join(Rails.root, "lib", "salmon", "slap")
  autoload :EncryptedSlap,    File.join(Rails.root, "lib", "salmon", "encrypted_slap")
  autoload :MagicSigEnvelope, File.join(Rails.root, "lib", "salmon", "magic_sig_envelope")
end
