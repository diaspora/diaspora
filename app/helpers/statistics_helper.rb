# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StatisticsHelper
  def registrations_status statistics
    if statistics.open_registrations?
      I18n.t('statistics.open')
    else
      I18n.t('statistics.closed')
    end
  end

  def registrations_status_class statistics
    if statistics.open_registrations?
      "serv-enabled"
    else
      "serv-disabled"
    end
  end
end
