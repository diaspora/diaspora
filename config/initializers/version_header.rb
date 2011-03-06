#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


git_cmd = `git log -1 --format="%H %ci"`
if git_cmd =~ /^([\d\w]+?)\s(.+)$/
  AppConfig[:git_revision] = $1
  AppConfig[:git_update] = $2.strip
end
