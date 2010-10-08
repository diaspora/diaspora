#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../spec_helper'

describe FbStatus do

  let(:fb_status) { Factory.create :fb_status }

  it 'is valid' do
    fb_status.should be_valid
  end

  describe '#from_api' do
    let!(:json_string) {File.open(File.dirname(__FILE__) + '/../fixtures/fb_status').read}
    let!(:json_object) { JSON.parse(json_string) }
    let!(:status_from_json) {FbStatus.from_api(json_object)}

    it 'has graph_id' do
      status_from_json.graph_id.should == json_object['id']
    end

    it 'has author_id' do
      status_from_json.author_id.should == json_object['from']['id']
    end

    it 'has author_name' do
      status_from_json.author_name.should == json_object['from']['name']
    end

    it 'has message' do
      status_from_json.message.should == json_object['message']
    end

    it 'has author_name' do
      status_from_json.updated_time.should == Time.parse(json_object['updated_time'])
    end
  end

end
