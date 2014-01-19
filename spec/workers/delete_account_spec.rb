#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Workers::DeleteAccount do
  describe '#perform' do
    it 'performs the account deletion' do
      account_deletion = double
      AccountDeletion.stub(:find).and_return(account_deletion)
      account_deletion.should_receive(:perform!)
      
      Workers::DeleteAccount.new.perform(1)
    end
  end
end
