# frozen_string_literal: true

class CleanupRootGuidsFromReshares < ActiveRecord::Migration[5.1]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    Reshare.joins("LEFT OUTER JOIN posts as root ON root.guid = posts.root_guid")
           .where("root.id is NULL AND posts.root_guid is NOT NULL")
           .update_all(root_guid: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
