# frozen_string_literal: true

class ResetExportStates < ActiveRecord::Migration[5.1]
  class User < ApplicationRecord
  end

  def up
    # rubocop:disable Rails/SkipsModelValidations
    User.where(exporting: true).update_all(exporting: false, export: nil, exported_at: nil)
    User.where(exporting_photos: true)
        .update_all(exporting_photos: false, exported_photos_file: nil, exported_photos_at: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
