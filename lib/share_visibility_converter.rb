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
        type = visibility.shareable_type
        id = visibility.shareable_id.to_s
        u = visibility.contact.user
        u.hidden_shareables ||= {}
        u.hidden_shareables[type] ||= []
        u.hidden_shareables[type] << id unless u.hidden_shareables[type].include?(id)
        u.save!(:validate => false)
      end
    end
  end
end