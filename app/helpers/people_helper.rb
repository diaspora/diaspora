#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PeopleHelper

  def request_partial single_aspect_form
    if single_aspect_form
      'requests/new_request_with_aspect_to_person'
    else
      'requests/new_request_to_person'
    end
  end

  def search_or_index
    if params[:q]
      I18n.t 'people.helper.results_for',:params => params[:q]
    else
      I18n.t "people.helper.people_on_pod_are_aware_of"
    end
  end

  def birthday_format(bday)
    if bday.year == 1000
      I18n.l bday, :format => I18n.t('date.formats.birthday')
    else
      I18n.l bday, :format => I18n.t('date.formats.birthday_with_year')
    end
  end
end
