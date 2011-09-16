#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Encryptable do
  before do
    @comment = Factory(:comment, :author => bob.person)
  end
  describe '#sign_with_key' do
    it 'signs the object with RSA256 signature' do
      sig = @comment.sign_with_key bob.encryption_key
      bob.public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(sig), @comment.signable_string).should be_true
    end
  end

  describe '#verify_signature' do
    it 'verifies SHA256 signatures' do
      sig = @comment.sign_with_key bob.encryption_key
      @comment.verify_signature(sig, bob.person).should be_true
    end

    context "fallback" do
      it "checks the SHA if it's within the week of the rollout window" do
        sig = Base64.encode64s(bob.encryption_key.sign( "SHA", @comment.signable_string )) 
        @comment.verify_signature(sig, bob.person).should be_true
      end

      it 'does not verify the fallback after rollout window' do
        Kernel::silence_warnings { Diaspora::Encryptable.const_set(:LAST_FALLBACK_TIME,((Time.now - 1.week).to_s))}

        sig = Base64.encode64s(bob.encryption_key.sign( "SHA", @comment.signable_string )) 
        @comment.verify_signature(sig, bob.person).should be_false
      end
    end
  end
end
