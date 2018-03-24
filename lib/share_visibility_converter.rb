# frozen_string_literal: true

#we dont have the environment, and it is not carring over from the migration
unless defined?(Person)
  class Person < ApplicationRecord
    belongs_to :owner, :class_name => 'User'
  end
end

unless defined?(User)
  class User < ApplicationRecord
    serialize :hidden_shareables, Hash
  end
end

unless defined?(Contact)
  class Contact < ApplicationRecord
    belongs_to :user
  end
end

unless defined?(ShareVisibility)
  class ShareVisibility < ApplicationRecord
    belongs_to :contact
  end
end

class ShareVisibilityConverter
  RECENT = 2 # number of weeks to do in the migration
  def self.copy_hidden_share_visibilities_to_users(only_recent = false)
    query = ShareVisibility.where(:hidden => true).includes(:contact => :user)
    query = query.where('share_visibilities.updated_at > ?', RECENT.weeks.ago) if only_recent
    count = query.count
    puts "Updating #{count} records in batches of 1000..."

    batch_count = 1
    query.find_in_batches do |visibilities|
      puts "Updating batch ##{batch_count} of #{(count/1000)+1}..."
      batch_count += 1
      visibilities.each do |visibility|
        begin
          type = visibility.shareable_type
          id = visibility.shareable_id.to_s
          u = visibility.contact.user
          u.hidden_shareables ||= {}
          u.hidden_shareables[type] ||= []
          u.hidden_shareables[type] << id unless u.hidden_shareables[type].include?(id)
          u.save!(:validate => false)
        rescue => e
          puts "ERROR: #{e.message} skipping pv with id: #{visibility.id}"
        end
      end
    end
  end
end
