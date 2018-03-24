# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ExportedPhotos < SecureUploader
  def store_dir
    "uploads/users"
  end

  def filename
    "#{model.username}_photos_#{secure_token}.zip" if original_filename.present?
  end
end
