#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Job::DeleteAccount do
  describe '#perform' do
    it 'calls remove_all_traces' do
      stub_find_for(bob)
      bob.should_receive(:remove_all_traces)
      Job::DeleteAccount.perform(bob.id)
    end

    it 'calls destroy' do
      stub_find_for(bob)
      bob.should_receive(:destroy)
      Job::DeleteAccount.perform(bob.id)
    end
    def stub_find_for model
      model.class.stub!(:find) do |id, conditions|
        if id == model.id
          model
        else
          model.class.find_by_id(id)
        end
      end
    end
  end
end
