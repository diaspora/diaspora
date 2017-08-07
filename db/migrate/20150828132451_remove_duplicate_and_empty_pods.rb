class RemoveDuplicateAndEmptyPods < ActiveRecord::Migration[4.2]
  def up
    remove_dupes
    remove_empty_or_nil

    add_index :pods, :host, unique: true, length: 190 # =190*4 for utf8mb4
  end

  def down
    remove_index :pods, :host
  end

  private

  def remove_dupes
    duplicates = Pod.group(:host).count.select {|_, v| v > 1 }.keys
    ids = duplicates.flat_map {|pod| Pod.where(host: pod).order(created_at: :asc).pluck(:id).tap(&:shift) }
    Pod.where(id: ids).destroy_all
  end

  def remove_empty_or_nil
    Pod.where(host: [nil, ""]).destroy_all
  end
end
