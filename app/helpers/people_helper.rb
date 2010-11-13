#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PeopleHelper

  def search_or_index
    if params[:q]
      I18n.t 'people.helper.results_for',:params => params[:q]
    else
      I18n.t "people.helper.people_on_pod_are_aware_of"
    end
  end

  def action_link(person, is_contact)
    if is_contact
      link_to t('people.profile_sidebar.remove_contact'), person, :confirm => t('are_you_sure'), :method => :delete
    elsif person == current_user.person
      link_to t('people.profile_sidebar.edit_my_profile'), edit_person_path(person)
    end
  end

end
