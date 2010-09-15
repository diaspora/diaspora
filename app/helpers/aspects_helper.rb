#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


module AspectsHelper
  def link_for_aspect( aspect )
    link_to aspect.name, aspect
  end
end
