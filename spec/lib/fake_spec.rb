require 'spec_helper'
describe PostsFake do
  before do
    @posts = []
    @people = []
    4.times do
      post = Factory(:status_message)
      @people << post.person
      4.times do
        comment = Factory(:comment, :post => post)
        @people << comment.person
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
    before do
      @post = mock()
      @fakes = mock()
      @fake = PostsFake::Fake.new(@post, @fakes)
    end
    it 'refers to the parent collection for a person' do
      @post.should_receive(:person_id)
      @fakes.should_receive(:people_hash).and_return({})
      @fake.person
    end
    it 'refers to its comments array for comments' do
      @fake.comments = [mock()]
      @fake.comments
    end
    it 'refers to its post for any other field' do
      @post.should_receive(:text)
      @fake.text
    end
  end
end

