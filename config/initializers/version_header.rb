#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


git_cmd = `git log -1 --format="%H %ci"`
if git_cmd =~ /^([\d\w]+?)\s(.+)$/
  GIT_REVISION = $1
  GIT_UPDATE = $2.strip
else
  GIT_REVISION = nil
  GIT_UPDATE = nil
end
