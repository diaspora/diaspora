#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require 'autotest/growl'
Autotest.add_discovery { "rails" }
Autotest.add_discovery { "rspec2" }
Autotest.add_hook :initialize do |at| 
  at.add_mapping(%r%^spec/(intergration|mailers|config)/.*rb$%) { |filename, _| 
    filename 
  }

  at.add_mapping(%r%^spec/misc_spec.rb$%) { |filename, _| 
    filename 
  }
end
