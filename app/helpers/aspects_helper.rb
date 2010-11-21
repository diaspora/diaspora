#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectsHelper
  def link_for_aspect( aspect )
    link_to aspect.name, aspect
  end

  def remove_link( aspect )
    if aspect.contacts.size == 0
      link_to I18n.t('aspects.helper.remove'), aspect, :method => :delete, :confirm => I18n.t('aspects.helper.are_you_sure')
    else
      "<span class='grey' title=#{I18n.t('aspects.helper.aspect_not_empty')}>#{I18n.t('aspects.helper.remove')}</span>"
    end
  end

  def add_to_aspect_button(aspect_id, person_id)
    link_to '+', {:action => 'add_to_aspect', :aspect_id => aspect_id, :person_id => person_id}, :remote => true, :class => 'add button'
  end

  def remove_from_aspect_button(aspect_id, person_id)
    link_to 'x', {:action => 'remove_from_aspect', :aspect_id => aspect_id, :person_id => person_id}, :remote => true, :class => 'remove button'
  end
end
