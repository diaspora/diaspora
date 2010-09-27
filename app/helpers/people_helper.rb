#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

module PeopleHelper

  def search_or_index
    if params[:q]
      I18n.t 'people.helper.results_for',:params => params[:q]
    else
      I18n.t "people.helper.people_on_pod_are_aware_of"
    end

  end
end
