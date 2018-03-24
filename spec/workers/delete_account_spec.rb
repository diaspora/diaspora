# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Workers::DeleteAccount do
  describe '#perform' do
    it 'performs the account deletion' do
      account_deletion = double
      allow(AccountDeletion).to receive(:find).and_return(account_deletion)
      expect(account_deletion).to receive(:perform!)
      
      Workers::DeleteAccount.new.perform(1)
    end
  end
end
