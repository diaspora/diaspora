# frozen_string_literal: true

# This is based on Mastodon doing the same, see
# https://github.com/mastodon/mastodon/blob/610cf6c3713e414995ea1a57110db400ccb88dd2/config/initializers/paperclip.rb#L157-L162
# At the time of writing, Mastodon is also licensed under the AGPL, see https://github.com/mastodon/mastodon/blob/610cf6c3713e414995ea1a57110db400ccb88dd2/LICENSE
# so the following snippet is Copyright (C) 2016-2022 Eugen Rochko & other Mastodon contributors.
ENV["MAGICK_CONFIGURE_PATH"] = begin
  imagemagick_config_paths = ENV.fetch("MAGICK_CONFIGURE_PATH", "").split(File::PATH_SEPARATOR)
  imagemagick_config_paths << Rails.root.join("config/imagemagick").expand_path.to_s
  imagemagick_config_paths.join(File::PATH_SEPARATOR)
end
# end of Mastodon snippet
