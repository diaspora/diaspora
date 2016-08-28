shared_examples_for "user deletion works fine" do
  it "deletes user1 and verifies it's unaccessible from user2" do
    user1_diaspora_id = @user1.api_client.diaspora_id
    @user1.api_client.delete_account("bluepin7")

    # check that the deleted user can't login anymore
    expect(User.new(1).api_client.login("alice", "bluepin7")).to be_falsy

    # wait pod1 to process the account deletion job. This must be done in a more robust way
    sleep 3

    # check user1 was deleted from user2's contacts
    expect(@user2.api_client.get_contacts.map {|cnt| cnt["handle"] }).not_to include(@user1.api_client.diaspora_id)

    # verify that user2 can't find user1 by search
    # (actually this is true only for json queries, WEB UI shows the deleted user in search results anyway)
    expect(@user2.remote_person(user1_diaspora_id)).to be_nil

    # try to add user1 to aspects
    @user2.add_to_first_aspect(@user1) # this is allowed to pass in some cases still, but not generally a good thing

    contacts = @user2.api_client.get_contacts
    expect(contacts).not_to be_nil

    # make sure user1 wasn't added to aspects
    expect(contacts.map {|cnt| cnt["handle"] }).not_to include(@user1.api_client.diaspora_id)
  end
end
