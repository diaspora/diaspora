#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root,  'lib/diaspora/ostatus_builder')


describe Diaspora::OstatusBuilder do

  let!(:user) { alice }
  let(:aspect) { user.aspects.first }
  let!(:public_status_messages) {
    3.times.inject([]) do |arr,n|
      s = user.post(:status_message, :message => "hey#{n}", :public => true, :to => aspect.id)
      arr << s
    end
  }
  let!(:private_status_messages) {
    3.times.inject([]) do |arr,n|
      s = user.post(:status_message, :message => "secret_ney#{n}", :public => false, :to => aspect.id)
      arr << s
    end
  }
  let!(:atom) { director = Diaspora::Director.new; director.build(Diaspora::OstatusBuilder.new(user)) }

  it 'should include a users posts' do
    public_status_messages.each{ |status| atom.should include status.message }
    private_status_messages.each{ |status| atom.should_not include status.message }
  end

end

