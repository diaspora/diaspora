# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ProfileHelper
  def upper_limit_date_of_birth
    minimum_year = AppConfig.settings.terms.minimum_age.get
    minimum_year = minimum_year ?  minimum_year.to_i : 13
    minimum_year.years.ago.year
  end

  def lower_limit_date_of_birth
    125.years.ago.year
  end
end
