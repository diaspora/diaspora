#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'a user receives a post', :type => :request do

  def receive_with_zord(user, person, xml)
    zord = Postzord::Receiver::Private.new(user, :person => person)
    zord.parse_and_receive(xml)
  end

  before do
    @alices_aspect = alice.aspects.where(:name => "generic").first
    @bobs_aspect = bob.aspects.where(:name => "generic").first
    @eves_aspect = eve.aspects.where(:name => "generic").first
  end

  it 'should not create new aspects on message receive' do
    num_aspects = alice.aspects.size

    2.times do |n|
      status_message = bob.post :status_message, :text => "store this #{n}!", :to => @bobs_aspect.id
    end

    expect(alice.aspects.size).to eq(num_aspects)
  end

  it "should show bob's post to alice" do
    inlined_jobs do |queue|
      sm = bob.build_post(:status_message, :text => "hi")
      sm.save!
      bob.aspects.reload
      bob.add_to_streams(sm, [@bobs_aspect])
      queue.drain_all
      bob.dispatch_post(sm, :to => @bobs_aspect)
    end

    expect(alice.visible_shareables(Post).count(:all)).to eq(1)
  end

  describe 'post refs' do
    before do
      @status_message = bob.post(:status_message, :text => "hi", :to => @bobs_aspect.id)
    end

    it "adds a received post to the the user" do
      expect(alice.visible_shareables(Post)).to include(@status_message)
      expect(ShareVisibility.find_by(user_id: alice.id, shareable_id: @status_message.id)).not_to be_nil
    end

    it "does not remove visibility on disconnect" do
      alice.remove_contact(alice.contact_for(bob.person), force: true)
      alice.reload
      expect(ShareVisibility.find_by(user_id: alice.id, shareable_id: @status_message.id)).not_to be_nil
    end
  end

  describe 'comments' do

    context 'remote' do
      before do
        skip # TODO
        inlined_jobs do |queue|
          connect_users(alice, @alices_aspect, eve, @eves_aspect)
          @post = alice.post(:status_message, :text => "hello", :to => @alices_aspect.id)

          xml = Diaspora::Federation.xml(Diaspora::Federation::Entities.status_message(@post)).to_xml

          receive_with_zord(bob, alice.person, xml)
          receive_with_zord(eve, alice.person, xml)

          comment = eve.comment!(@post, 'tada')
          queue.drain_all
          # After Eve creates her comment, it gets sent to Alice, who signs it with her private key
          # before relaying it out to the contacts on the top-level post
          comment.parent_author_signature = comment.sign_with_key(alice.encryption_key)
          @xml = Diaspora::Federation.xml(Diaspora::Federation::Entities.comment(comment)).to_xml
          comment.delete

          comment_with_whitespace = alice.comment!(@post, '   I cannot lift my thumb from the spacebar  ')
          queue.drain_all
          comment_entity = Diaspora::Federation::Entities.comment(comment_with_whitespace)
          @xml_with_whitespace = Diaspora::Federation.xml(comment_entity).to_xml
          @guid_with_whitespace = comment_with_whitespace.guid
          comment_with_whitespace.delete
        end
      end

      it 'should receive a relayed comment with leading whitespace' do
        expect(eve.reload.visible_shareables(Post).size).to eq(1)
        post_in_db = StatusMessage.find(@post.id)
        expect(post_in_db.comments).to eq([])
        receive_with_zord(eve, alice.person, @xml_with_whitespace)

        expect(post_in_db.comments(true).first.guid).to eq(@guid_with_whitespace)
      end

      it 'should correctly marshal a stranger for the downstream user' do
        remote_person = eve.person.dup
        eve.person.delete
        eve.delete
        Person.where(:id => remote_person.id).delete_all
        Profile.where(:person_id => remote_person.id).delete_all
        remote_person.attributes.delete(:id) # leaving a nil id causes it to try to save with id set to NULL in postgres

        remote_person.save(:validate => false)
        remote_person.profile = FactoryGirl.create(:profile, :person => remote_person)
        expect(Person).to receive(:find_or_fetch_by_identifier).twice.with(eve.person.diaspora_handle)
                            .and_return(remote_person)

        expect(bob.reload.visible_shareables(Post).size).to eq(1)
        post_in_db = StatusMessage.find(@post.id)
        expect(post_in_db.comments).to eq([])

        receive_with_zord(bob, alice.person, @xml)

        expect(post_in_db.comments(true).first.author).to eq(remote_person)
      end
    end

    context 'local' do
      before do
        skip # TODO
        @post = alice.post :status_message, :text => "hello", :to => @alices_aspect.id

        xml = Diaspora::Federation.xml(Diaspora::Federation::Entities.status_message(@post)).to_xml

        alice.share_with(eve.person, alice.aspects.first)

        receive_with_zord(bob, alice.person, xml)
        receive_with_zord(eve, alice.person, xml)
      end

      it 'does not raise a `Mysql2::Error: Duplicate entry...` exception on save' do
        inlined_jobs do
          @comment = bob.comment!(@post, 'tada')
          @xml = Diaspora::Federation.xml(Diaspora::Federation::Entities.comment(@comment)).to_xml

          expect {
            receive_with_zord(alice, bob.person, @xml)
          }.to_not raise_exception
        end
      end
    end
  end


  describe 'receiving mulitple versions of the same post from a remote pod' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends

      @post = FactoryGirl.build(
        :status_message,
        text:       "hey",
        guid:       UUID.generate(:compact),
        author:     @remote_raphael,
        created_at: 5.days.ago,
        updated_at: 5.days.ago
      )
    end

    it "allows two people saving the same post" do
      skip # TODO
      xml = Diaspora::Federation.xml(Diaspora::Federation::Entities.status_message(@post)).to_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)
      receive_with_zord(@local_leia, @remote_raphael, xml)
      expect(Post.find_by_guid(@post.guid).updated_at).to be < Time.now.utc + 1
      expect(Post.find_by_guid(@post.guid).created_at.day).to eq(@post.created_at.day)
    end

    it 'does not update the post if a new one is sent with a new created_at' do
      skip # TODO
      old_time = @post.created_at
      xml = Diaspora::Federation.xml(Diaspora::Federation::Entities.status_message(@post)).to_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)

      @post = FactoryGirl.build(
        :status_message,
        text:       "hey",
        guid:       @post.guid,
        author:     @remote_raphael,
        created_at: 2.days.ago
      )
      xml = Diaspora::Federation.xml(Diaspora::Federation::Entities.status_message(@post)).to_xml
      receive_with_zord(@local_luke, @remote_raphael, xml)

      expect(Post.find_by_guid(@post.guid).created_at.day).to eq(old_time.day)
    end
  end


  describe 'salmon' do
    let(:post){alice.post :status_message, :text => "hello", :to => @alices_aspect.id}
    let(:salmon){alice.salmon( post )}

    it 'processes a salmon for a post' do
      salmon_xml = salmon.xml_for(bob.person)

      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => salmon_xml)
      zord.perform!

      expect(bob.visible_shareables(Post).include?(post)).to be true
    end
  end
end
