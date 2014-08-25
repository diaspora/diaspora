require 'spec_helper'

describe TagsController do
  describe 'will_paginate people on the tag page' do
    let(:people) { (1..2).map { FactoryGirl.create(:person) } }
    let(:tag)    { "diaspora" }

    before do
      Stream::Tag.any_instance.stub(people_per_page: 1)
      expect(Person).to receive(:profile_tagged_with).with(/#{tag}/).twice.and_return(people)
    end

    it 'paginates the people set' do
      get "/tags/#{tag}"

      expect(response.status).to eq(200)
      expect(response.body).to match(/div class="pagination"/)
      expect(response.body).to match(/href="\/tags\/#{tag}\?page=2"/)
    end

    it 'fetches the second page' do
      get "/tags/#{tag}", page: 2

      expect(response.status).to eq(200)
      expect(response.body).to match(/<em class="current">2<\/em>/)
    end
  end
end
