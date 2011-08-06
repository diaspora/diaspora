#   Copyright (c) 2010, Diaspora Inc.  This file is
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
      ciphertext.include?(string).should be false
      @user.decrypt(ciphertext).should == string
    end
  end
end
