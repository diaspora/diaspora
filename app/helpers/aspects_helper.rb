#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

module AspectsHelper
  def link_for_aspect( aspect )
    link_to aspect.name, aspect
  end

  def remove_link( aspect )
    if aspect.people.size == 0
      link_to I18n.t('aspects.helper.remove'), aspect, :method => :delete
    else
      "<span class='grey' title=#{I18n.t('aspects.helper.aspect_not_empty')}>#{I18n.t('aspects.helper.remove')}</span>"
    end
  end
end
