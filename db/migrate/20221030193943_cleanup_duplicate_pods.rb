# frozen_string_literal: true

class CleanupDuplicatePods < ActiveRecord::Migration[6.1]
  class Pod < ApplicationRecord
  end

  def change
    reversible do |change|
      change.up do
        remove_duplicates
        cleanup_mixed_case_pods

        Pod.where(port: nil).update_all(port: -1) # rubocop:disable Rails/SkipsModelValidations
      end

      change.down do
        Pod.where(port: -1).update_all(port: nil) # rubocop:disable Rails/SkipsModelValidations
      end
    end

    change_column_null :pods, :port, false
  end

  private

  def remove_duplicates
    Pod.where(port: nil).group(:host).having("count(*) > 1").pluck(:host).each do |host|
      cleanup_duplicates(Pod.where(host: host).order(:id).ids)
    end
  end

  def cleanup_mixed_case_pods
    Pod.where("lower(host) != host").pluck(:host, :port).each do |host, port|
      pod_ids = Pod.where("lower(host) = ?", host.downcase).where(port: port).order(:id).ids
      cleanup_duplicates(pod_ids.dup) if pod_ids.size > 1
      Pod.find(pod_ids.first).update(host: host.downcase)
    end
  end

  def cleanup_duplicates(duplicate_ids)
    target_pod_id = duplicate_ids.shift

    duplicate_ids.each do |pod_id|
      Person.where(pod_id: pod_id).update_all(pod_id: target_pod_id) # rubocop:disable Rails/SkipsModelValidations
      Pod.delete(pod_id)
    end
  end
end
