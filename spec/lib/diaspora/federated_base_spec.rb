#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Federated::Base do
  describe '#subscribers' do
    it 'throws an error if the including module does not redefine it' do
      class Foo
        include Diaspora::Federated::Base 
      end

      f = Foo.new

      expect{ f.subscribers(1)}.to raise_error /override subscribers/
    end
  end
end
