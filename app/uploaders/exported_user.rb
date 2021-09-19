# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ExportedUser < SecureUploader
  def store_dir
    "uploads/users"
  end

  def extension_allowlist
    %w[gz zip json]
  end

  def filename
    return if original_filename.blank?

    filename_parts = original_filename.split(".")
    extensions = filename_parts.join(".")
    "#{model.username}_data_#{secure_token}.#{extensions}"
  end
end
