# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ExportedUser < SecureUploader
  def store_dir
    "uploads/users"
  end

  def extension_whitelist
    %w[gz]
  end

  def filename
    "#{model.username}_diaspora_data_#{secure_token}.json.gz" if original_filename.present?
  end
end
