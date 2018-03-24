# frozen_string_literal: true

class CleanupAspectsAndAddUniqueIndex < ActiveRecord::Migration[5.1]
  class Aspect < ApplicationRecord
  end

  def up
    cleanup_aspects
    add_index :aspects, %i[user_id name], name: :index_aspects_on_user_id_and_name, length: {name: 190}, unique: true
  end

  def down
    remove_index :aspects, name: :index_aspects_on_user_id_and_name
  end

  def cleanup_aspects
    Aspect.where(user_id: 0).delete_all
    Aspect.joins("INNER JOIN aspects as a2 ON aspects.user_id = a2.user_id AND aspects.name = a2.name")
          .where("aspects.id > a2.id").each do |aspect|
      aspect.update_attributes(name: "#{aspect.name}_#{UUID.generate(:compact)}")
    end
  end
end
