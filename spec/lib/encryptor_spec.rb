#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'user encryption' do
  before do
    @user = alice
    @aspect = @user.aspects.first
  end

  describe 'encryption' do
    it 'should encrypt a string' do
      string = "Secretsauce"
      ciphertext = @user.person.encrypt string
      expect(ciphertext.include?(string)).to be false
      expect(@user.decrypt(ciphertext)).to eq(string)
    end
  end
end
