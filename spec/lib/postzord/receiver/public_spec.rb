#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/postzord')
require File.join(Rails.root, 'lib/postzord/receiver/public')

describe Postzord::Receiver::Public do

  describe '#initialize' do
    it 'sets xml as instance variable' do
      receiver = Postzord::Receiver::Public.new("blah")
      receiver.xml.should == 'blah'
    end
  end

  describe '#perform' do
    it 'calls verify_signature' do

    end

    context 'if signature is valid' do
      it 'calls collect_recipients' do

      end

      it 'saves the parsed object' do

      end

      it 'calls batch_insert_visibilities' do

      end

      it 'calls batch_notify' do

      end
    end
  end

  describe '#verify_signature' do

  end

  describe '#collect_recipients' do

  end

  describe '#batch_insert_visibilities' do

  end

  describe '#batch_notify' do

  end

end
