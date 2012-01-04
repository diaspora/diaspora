#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


if EnviromentConfiguration.cache_git_version?
	git_cmd = `git log -1 --pretty="format:%H %ci"`
	if git_cmd =~ /^([\d\w]+?)\s(.+)$/
	  AppConfig[:git_revision] = $1
	  AppConfig[:git_update] = $2.strip
	  ENV["RAILS_ASSET_ID"] = AppConfig[:git_revision][0..8] if Rails.env.production?
	end
end