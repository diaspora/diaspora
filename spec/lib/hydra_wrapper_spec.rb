#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe HydraWrapper do
  before do
    @people = ["person", "person2", "person3"]
    @wrapper = HydraWrapper.new double, @people, "<encoded_xml>", double
  end

  describe 'initialize' do
    it 'it sets the proper instance variables' do
      user = "user"
      encoded_object_xml = "encoded xml"
      dispatcher_class = "Postzord::Dispatcher::Private"

      wrapper = HydraWrapper.new user, @people, encoded_object_xml, dispatcher_class
      expect(wrapper.user).to eq(user)
      expect(wrapper.people).to eq(@people)
      expect(wrapper.encoded_object_xml).to eq(encoded_object_xml)
    end
  end

  describe '#run' do
    it 'delegates #run to the @hydra' do
      hydra = double.as_null_object
      @wrapper.instance_variable_set :@hydra, hydra
      expect(hydra).to receive :run
      @wrapper.run
    end
  end

  describe '#xml_factory' do
    it 'calls the salmon method on the dispatcher class (and memoizes)' do
      allow(Base64).to receive(:decode64).and_return "#{@wrapper.encoded_object_xml} encoded"
      decoded = Base64.decode64 @wrapper.encoded_object_xml
      expect(@wrapper.dispatcher_class).to receive(:salmon).with(@wrapper.user, decoded).once.and_return true
      @wrapper.send :xml_factory
      @wrapper.send :xml_factory
    end
  end

  describe '#grouped_people' do
    it 'groups people given their receive_urls' do
      expect(@wrapper.dispatcher_class).to receive(:receive_url_for).and_return "foo.com", "bar.com", "bar.com"

      expect(@wrapper.send(:grouped_people)).to eq({"foo.com" => [@people[0]], "bar.com" => @people[1,2]})
    end
  end

  describe '#enqueue_batch' do
    it 'calls #grouped_people' do
      expect(@wrapper).to receive(:grouped_people).and_return []
      @wrapper.enqueue_batch
    end

    it 'inserts a job for every group of people' do
      allow(Base64).to receive(:decode64)
      @wrapper.dispatcher_class = double salmon: double(xml_for: "<XML>")
      allow(@wrapper).to receive(:grouped_people).and_return('https://foo.com' => @wrapper.people)
      expect(@wrapper.people).to receive(:first).once
      expect(@wrapper).to receive(:insert_job).with('https://foo.com', "<XML>", @wrapper.people).once
      @wrapper.enqueue_batch
    end

    it 'does not insert a job for a person whos xml returns false' do
      allow(Base64).to receive(:decode64)
      allow(@wrapper).to receive(:grouped_people).and_return('https://foo.com' => [double])
      @wrapper.dispatcher_class = double salmon: double(xml_for: false)
      expect(@wrapper).not_to receive :insert_job
      @wrapper.enqueue_batch
    end

  end

  describe '#redirecting_to_https?!' do
    it 'does not execute unless response has a 3xx code' do
      resp = double code: 200
      expect(@wrapper.send(:redirecting_to_https?, resp)).to be false
    end

    it "returns true if just the protocol is different" do
      host = "the-same.com/"
      resp = double(
        request: double(url: "http://#{host}"),
        code: 302,
        headers_hash: {
          'Location' => "https://#{host}"
        }
      )

      expect(@wrapper.send(:redirecting_to_https?, resp)).to be true
    end

    it "returns false if not just the protocol is different" do
      host = "the-same.com/"
      resp = double(
        request: double(url: "http://#{host}"),
        code: 302,
        headers_hash: {
          'Location' => "https://not-the-same/"
        }
      )

      expect(@wrapper.send(:redirecting_to_https?, resp)).to be false
    end
  end
end
