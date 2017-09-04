# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
#
#
##Why? as of rails 3.0.4, objects are marshalled by calling to yaml, if it is a text field in the db. since we assume things are strings coming out, and pkey does not seem to define a to_yaml, it was getting set to nil
class OpenSSL::PKey::RSA
 def to_yaml(opts=nil)
   self.to_s
 end
end
#
#
