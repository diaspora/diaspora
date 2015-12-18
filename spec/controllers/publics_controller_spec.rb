#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PublicsController, :type => :controller do
  describe '#hub' do
    it 'succeeds' do
      get :hub
      expect(response).to be_success
    end
  end
end
