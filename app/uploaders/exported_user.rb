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
    if original_filename.present? # rubocop:disable Style/GuardClause
      extension = File.extname(@filename) if @filename
      "#{model.username}_data_#{secure_token}#{extension}"
    end
  end
end
