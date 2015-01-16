#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ExportedUser < CarrierWave::Uploader::Base

  def store_dir
    "uploads/users"
  end

  def extension_white_list
    %w(gz)
  end

  def filename
    "#{model.username}_diaspora_data.json.gz"
  end

end
