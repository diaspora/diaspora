#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User::Querying do
  before do
    @alices_aspect = alice.aspects.where(:name => "generic").first
    @eves_aspect = eve.aspects.where(:name => "generic").first
    @bobs_aspect = bob.aspects.where(:name => "generic").first
  end

  describe "#visible_shareable_ids" do
    it "contains your public posts" do
      public_post = alice.post(:status_message, :text => "hi", :to => @alices_aspect.id, :public => true)
      alice.visible_shareable_ids(Post).should include(public_post.id)
    end

    it "contains your non-public posts" do
      private_post = alice.post(:status_message, :text => "hi", :to => @alices_aspect.id, :public => false)
      alice.visible_shareable_ids(Post).should include(private_post.id)
    end

    it "contains public posts from people you're following" do
      # Alice follows Eve, but Eve does not follow Alice
      alice.share_with(eve.person, @alices_aspect)

      # Eve posts a public status message
      eves_public_post = eve.post(:status_message, :text => "hello", :to => 'all', :public => true)

      # Alice should see it
      alice.visible_shareable_ids(Post).should include(eves_public_post.id)
    end

    it "does not contain non-public posts from people who are following you" do
      eve.share_with(alice.person, @eves_aspect)
      eves_post = eve.post(:status_message, :text => "hello", :to => @eves_aspect.id)
      alice.visible_shareable_ids(Post).should_not include(eves_post.id)
    end

    it "does not contain non-public posts from aspects you're not in" do
      dogs = bob.aspects.create(:name => "dogs")
      invisible_post = bob.post(:status_message, :text => "foobar", :to => dogs.id)
      alice.visible_shareable_ids(Post).should_not include(invisible_post.id)
    end

    it "does not contain pending posts" do
      pending_post = bob.post(:status_message, :text => "hey", :public => true, :to => @bobs_aspect.id, :pending => true)
      pending_post.should be_pending
      alice.visible_shareable_ids(Post).should_not include pending_post.id
    end

    it "does not contain pending photos" do
      pending_photo = bob.post(:photo, :pending => true, :user_file=> File.open(photo_fixture_name), :to => @bobs_aspect)
      alice.visible_shareable_ids(Photo).should_not include pending_photo.id
    end

    it "respects the :type option" do
      post = bob.post(:status_message, :text => "hey", :public => true, :to => @bobs_aspect.id, :pending => false)
      reshare = bob.post(:reshare, :pending => false, :root_guid => post.guid, :to => @bobs_aspect)
      alice.visible_shareable_ids(Post, :type => "Reshare").should include(reshare.id)
      alice.visible_shareable_ids(Post, :type => 'StatusMessage').should_not include(reshare.id)
    end

    it "does not contain duplicate posts" do
      bobs_other_aspect = bob.aspects.create(:name => "cat people")
      bob.add_contact_to_aspect(bob.contact_for(alice.person), bobs_other_aspect)
      bob.aspects_with_person(alice.person).should =~ [@bobs_aspect, bobs_other_aspect]

      bobs_post = bob.post(:status_message, :text => "hai to all my people", :to => [@bobs_aspect.id, bobs_other_aspect.id])

      alice.visible_shareable_ids(Post).length.should == 1
      alice.visible_shareable_ids(Post).should include(bobs_post.id)
    end

    describe 'hidden posts' do
      before do
        aspect_to_post = bob.aspects.where(:name => "generic").first
        @status = bob.post(:status_message, :text=> "hello", :to => aspect_to_post)
      end

      it "pulls back non hidden posts" do
        alice.visible_shareable_ids(Post).include?(@status.id).should be_true
      end

      it "does not pull back hidden posts" do
        visibility = @status.share_visibilities(Post).where(:contact_id => alice.contact_for(bob.person).id).first
        visibility.update_attributes(:hidden => true)
        alice.visible_shareable_ids(Post).include?(@status.id).should be_false
      end
    end
  end

  describe "#prep_opts" do
    it "defaults the opts" do
      time = Time.now
      Time.stub(:now).and_return(time)
      alice.send(:prep_opts, Post, {}).should == {
        :type => Stream::Base::TYPES_OF_POST_IN_STREAM,
        :order => 'created_at DESC',
        :limit => 15,
        :hidden => false,
        :order_field => :created_at,
        :order_with_table => "posts.created_at DESC",
        :max_time => time + 1
      }
    end
  end

  describe "#visible_shareables" do
    it 'never contains posts from people not in your aspects' do
      FactoryGirl.create(:status_message, :public => true)
      bob.visible_shareables(Post).count.should == 0
    end
    
    context 'with two posts with the same timestamp' do
      before do
        aspect_id = alice.aspects.where(:name => "generic").first.id
        Timecop.freeze Time.now do
          alice.post :status_message, :text => "first", :to => aspect_id
          alice.post :status_message, :text => "second", :to => aspect_id
        end
      end
      
      it "returns them in reverse creation order" do
        bob.visible_shareables(Post).first.text.should == "second"
        bob.visible_shareables(Post).last.text.should == "first"
      end
    end

    context 'with many posts' do
      before do
        time_interval = 1000
        time_past = 1000000
        (1..25).each do |n|
          [alice, bob, eve].each do |u|
            aspect_to_post = u.aspects.where(:name => "generic").first
            post = u.post :status_message, :text => "#{u.username} - #{n}", :to => aspect_to_post.id
            post.created_at = (post.created_at-time_past) - time_interval
            post.updated_at = (post.updated_at-time_past) + time_interval
            post.save
            time_interval += 1000
          end
        end
      end

      it 'works' do # The set up takes a looong time, so to save time we do several tests in one
        bob.visible_shareables(Post).length.should == 15 #it returns 15 by default
        bob.visible_shareables(Post).map(&:id).should == bob.visible_shareables(Post, :by_members_of => bob.aspects.map { |a| a.id }).map(&:id) # it is the same when joining through aspects

        # checks the default sort order
        bob.visible_shareables(Post).sort_by { |p| p.created_at }.map { |p| p.id }.should == bob.visible_shareables(Post).map { |p| p.id }.reverse #it is sorted updated_at desc by default

        # It should respect the order option
        opts = {:order => 'created_at DESC'}
        bob.visible_shareables(Post, opts).first.created_at.should > bob.visible_shareables(Post, opts).last.created_at

        # It should respect the order option
        opts = {:order => 'updated_at DESC'}
        bob.visible_shareables(Post, opts).first.updated_at.should > bob.visible_shareables(Post, opts).last.updated_at

        # It should respect the limit option
        opts = {:limit => 40}
        bob.visible_shareables(Post, opts).length.should == 40
        bob.visible_shareables(Post, opts).map(&:id).should == bob.visible_shareables(Post, opts.merge(:by_members_of => bob.aspects.map { |a| a.id })).map(&:id)
        bob.visible_shareables(Post, opts).sort_by { |p| p.created_at }.map { |p| p.id }.should == bob.visible_shareables(Post, opts).map { |p| p.id }.reverse

        # It should paginate using a datetime timestamp
        last_time_of_last_page = bob.visible_shareables(Post).last.created_at
        opts = {:max_time => last_time_of_last_page}
        bob.visible_shareables(Post, opts).length.should == 15
        bob.visible_shareables(Post, opts).map { |p| p.id }.should == bob.visible_shareables(Post, opts.merge(:by_members_of => bob.aspects.map { |a| a.id })).map { |p| p.id }
        bob.visible_shareables(Post, opts).sort_by { |p| p.created_at}.map { |p| p.id }.should == bob.visible_shareables(Post, opts).map { |p| p.id }.reverse
        bob.visible_shareables(Post, opts).map { |p| p.id }.should == bob.visible_shareables(Post, :limit => 40)[15...30].map { |p| p.id } #pagination should return the right posts

        # It should paginate using an integer timestamp
        opts = {:max_time => last_time_of_last_page.to_i}
        bob.visible_shareables(Post, opts).length.should == 15
        bob.visible_shareables(Post, opts).map { |p| p.id }.should == bob.visible_shareables(Post, opts.merge(:by_members_of => bob.aspects.map { |a| a.id })).map { |p| p.id }
        bob.visible_shareables(Post, opts).sort_by { |p| p.created_at}.map { |p| p.id }.should == bob.visible_shareables(Post, opts).map { |p| p.id }.reverse
        bob.visible_shareables(Post, opts).map { |p| p.id }.should == bob.visible_shareables(Post, :limit => 40)[15...30].map { |p| p.id } #pagination should return the right posts
      end
    end
  end

  describe '#find_visible_shareable_by_id' do
    it "returns a post if you can see it" do
      bobs_post = bob.post(:status_message, :text => "hi", :to => @bobs_aspect.id, :public => false)
      alice.find_visible_shareable_by_id(Post, bobs_post.id).should == bobs_post
    end
    it "returns nil if you can't see that post" do
      dogs = bob.aspects.create(:name => "dogs")
      invisible_post = bob.post(:status_message, :text => "foobar", :to => dogs.id)
      alice.find_visible_shareable_by_id(Post, invisible_post.id).should be_nil
    end
  end

  context 'with two users' do
    describe '#people_in_aspects' do
      it 'returns people objects for a users contact in each aspect' do
        alice.people_in_aspects([@alices_aspect]).should == [bob.person]
      end

      it 'returns local/remote people objects for a users contact in each aspect' do
        local_user1 = FactoryGirl.create(:user)
        local_user2 = FactoryGirl.create(:user)
        remote_user = FactoryGirl.create(:user)

        asp1 = local_user1.aspects.create(:name => "lol")
        asp2 = local_user2.aspects.create(:name => "brb")
        asp3 = remote_user.aspects.create(:name => "ttyl")

        connect_users(alice, @alices_aspect, local_user1, asp1)
        connect_users(alice, @alices_aspect, local_user2, asp2)
        connect_users(alice, @alices_aspect, remote_user, asp3)

        local_person = remote_user.person
        local_person.owner_id = nil
        local_person.save
        local_person.reload

        alice.people_in_aspects([@alices_aspect]).count.should == 4
        alice.people_in_aspects([@alices_aspect], :type => 'remote').count.should == 1
        alice.people_in_aspects([@alices_aspect], :type => 'local').count.should == 3
      end

      it 'does not return people not connected to user on same pod' do
        3.times { FactoryGirl.create(:user) }
        alice.people_in_aspects([@alices_aspect]).count.should == 1
      end

      it "only returns non-pending contacts" do
        alice.people_in_aspects([@alices_aspect]).should == [bob.person]
      end

      it "returns an empty array when passed an aspect the user doesn't own" do
        alice.people_in_aspects([@eves_aspect]).should == []
      end
    end
  end

  context 'contact querying' do
    let(:person_one) { FactoryGirl.create :person }
    let(:person_two) { FactoryGirl.create :person }
    let(:person_three) { FactoryGirl.create :person }
    let(:aspect) { alice.aspects.create(:name => 'heroes') }

    describe '#contact_for_person_id' do
      it 'returns a contact' do
        contact = Contact.create(:user => alice, :person => person_one, :aspects => [aspect])
        alice.contacts << contact
        alice.contact_for_person_id(person_one.id).should be_true
      end

      it 'returns the correct contact' do
        contact = Contact.create(:user => alice, :person => person_one, :aspects => [aspect])
        alice.contacts << contact

        contact2 = Contact.create(:user => alice, :person => person_two, :aspects => [aspect])
        alice.contacts << contact2

        contact3 = Contact.create(:user => alice, :person => person_three, :aspects => [aspect])
        alice.contacts << contact3

        alice.contact_for_person_id(person_two.id).person.should == person_two
      end

      it 'returns nil for a non-contact' do
        alice.contact_for_person_id(person_one.id).should be_nil
      end

      it 'returns nil when someone else has contact with the target' do
        contact = Contact.create(:user => alice, :person => person_one, :aspects => [aspect])
        alice.contacts << contact
        eve.contact_for_person_id(person_one.id).should be_nil
      end
    end

    describe '#contact_for' do
      it 'takes a person_id and returns a contact' do
        alice.should_receive(:contact_for_person_id).with(person_one.id)
        alice.contact_for(person_one)
      end

      it 'returns nil if the input is nil' do
        alice.contact_for(nil).should be_nil
      end
    end

    describe '#aspects_with_person' do
      before do
        @connected_person = bob.person
      end

      it 'should return the aspects with given contact' do
        alice.aspects_with_person(@connected_person).should == [@alices_aspect]
      end

      it 'returns multiple aspects if the person is there' do
        aspect2 = alice.aspects.create(:name => 'second')
        contact = alice.contact_for(@connected_person)

        alice.add_contact_to_aspect(contact, aspect2)
        alice.aspects_with_person(@connected_person).to_set.should == alice.aspects.to_set
      end
    end
  end

  describe '#posts_from' do
    before do
      @user3 = FactoryGirl.create(:user)
      @aspect3 = @user3.aspects.create(:name => "bros")

      @public_message = @user3.post(:status_message, :text => "hey there", :to => 'all', :public => true)
      @private_message = @user3.post(:status_message, :text => "hey there", :to => @aspect3.id)
    end

    it 'displays public posts for a non-contact' do
      alice.posts_from(@user3.person).should include @public_message
    end

    it 'does not display private posts for a non-contact' do
      alice.posts_from(@user3.person).should_not include @private_message
    end

    it 'displays private and public posts for a non-contact after connecting' do
      connect_users(alice, @alices_aspect, @user3, @aspect3)
      new_message = @user3.post(:status_message, :text=> "hey there", :to => @aspect3.id)

      alice.reload

      alice.posts_from(@user3.person).should include @public_message
      alice.posts_from(@user3.person).should include new_message
    end

    it 'displays recent posts first' do
      msg3 = @user3.post(:status_message, :text => "hey there", :to => 'all', :public => true)
      msg4 = @user3.post(:status_message, :text => "hey there", :to => 'all', :public => true)
      msg3.created_at = Time.now+10
      msg3.save!
      msg4.created_at = Time.now+14
      msg4.save!

      alice.posts_from(@user3.person).map { |p| p.id }.should == [msg4, msg3, @public_message].map { |p| p.id }
    end
  end
end
