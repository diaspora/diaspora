#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class MongoToMysql
  def id_sed
    @id_sed = sed_replace('{\ \"$oid\"\ :\ \(\"[^"]*\"\)\ }')
  end
  def date_sed
    @date_sed = sed_replace('{\ \"$date\"\ :\ \([0-9]*\)\ }')
  end
  def sed_replace(regex)
    "sed 's/#{regex}/\\1/g'"
  end
end
