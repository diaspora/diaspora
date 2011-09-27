#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Add URL safe Base64 support
module Base64
  module_function
  # Returns the Base64-encoded version of +bin+.
  # This method complies with ``Base 64 Encoding with URL and Filename Safe
  # Alphabet'' in RFC 4648.
  # The alphabet uses '-' instead of '+' and '_' instead of '/'.
  def urlsafe_encode64(bin)
    self.encode64s(bin).tr("+/", "-_")
  end

  # Returns the Base64-decoded version of +str+.
  # This method complies with ``Base 64 Encoding with URL and Filename Safe
  # Alphabet'' in RFC 4648.
  # The alphabet uses '-' instead of '+' and '_' instead of '/'.
  def urlsafe_decode64(str)
    self.decode64(str.tr("-_", "+/"))
  end
end

# Verify documents secured with Magic Signatures
module Salmon
  autoload :Slap,             File.join(Rails.root, "lib", "salmon", "slap")
  autoload :EncryptedSlap,    File.join(Rails.root, "lib", "salmon", "encrypted_slap")
  autoload :MagicSigEnvelope, File.join(Rails.root, "lib", "salmon", "magic_sig_envelope")
end
