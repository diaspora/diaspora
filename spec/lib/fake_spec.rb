require 'spec_helper'
describe PostsFake do
  before do
    @posts = []
    @people = []
    4.times do
      post = Factory(:status_message)
      @people << post.author
      4.times do
        comment = Factory(:comment, :post => post)
        comment.author
      end
      @posts << post
    end
  end

  describe '#initialize' do
    before do
      @posts_fake = PostsFake.new(@posts)
    end
    it 'sets @people_hash' do
      @people.each do |person|
        @posts_fake.people_hash[person.reload.id].should == person
      end
      @posts_fake.people_hash.length.should == @people.length
    end

    it 'sets @post_fakes to an array of fakes' do
      @posts_fake.post_fakes.each{|x| x.class.should be PostsFake::Fake}
    end
  end
  describe PostsFake::Fake do
    include Rails.application.routes.url_helpers
    before do
      @post = mock()
      @fakes = mock()
      @fake = PostsFake::Fake.new(@post, @fakes)
    end
    it 'refers to the parent collection for an author' do
      @post.should_receive(:author_id)
      @fakes.should_receive(:people_hash).and_return({})
      @fake.author
    end
    it 'refers to its post for any other field' do
      @post.should_receive(:text)
      @fake.text
    end


    it 'works with url helpers' do
      sm = Factory(:status_message)
      fake = PostsFake::Fake.new(sm, @fakes)

      post_path(fake).should == post_path(sm)
    end
  end
end

