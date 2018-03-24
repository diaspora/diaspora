# frozen_string_literal: true

describe Workers::RemoveOldUser do
  describe 'remove_old_users is active' do
    before do
      AppConfig.settings.maintenance.remove_old_users.enable = true
    end
    
    it '#removes user whose remove_after timestamp has passed' do
      user = double(id: 1, remove_after: 1.day.ago, last_seen: 1000.days.ago)
      allow(User).to receive(:find).with(user.id).and_return(user)
      expect(user).to receive(:close_account!)
      Workers::RemoveOldUser.new.perform(user.id)
    end
    
    it '#doesnt remove user whose remove_after timestamp hasnt passed' do
      user = double(id: 1, remove_after: 1.day.from_now, last_seen: 1000.days.ago)
      allow(User).to receive(:find).with(user.id).and_return(user)
      expect(user).to_not receive(:close_account!)
      Workers::RemoveOldUser.new.perform(user.id)
    end
    
    it '#doesnt remove user whose remove_after timestamp has passed but last_seen is recent' do
      user = double(id: 1, remove_after: 1.day.ago, last_seen: 1.day.ago)
      allow(User).to receive(:find).with(user.id).and_return(user)
      expect(user).to_not receive(:close_account!)
      Workers::RemoveOldUser.new.perform(user.id)
    end
    
  end
  
  describe 'remove_old_users is inactive' do
    before do
      AppConfig.settings.maintenance.remove_old_users.enable = false
    end
    
    it '#doesnt remove user whose remove_after timestamp has passed' do
      user = double(id: 1, remove_after: 1.day.ago, last_seen: 1000.days.ago)
      allow(User).to receive(:find).with(user.id).and_return(user)
      expect(user).to_not receive(:close_account!)
      Workers::RemoveOldUser.new.perform(user.id)
    end
    
    it '#doesnt remove user whose remove_after timestamp hasnt passed' do
      user = double(id: 1, remove_after: 1.day.from_now, last_seen: 1000.days.ago)
      allow(User).to receive(:find).with(user.id).and_return(user)
      expect(user).to_not receive(:close_account!)
      Workers::RemoveOldUser.new.perform(user.id)
    end
    
  end
end
