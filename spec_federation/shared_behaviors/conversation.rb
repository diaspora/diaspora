def wait_block(timeout)
  res = nil
  timeout.times do
    res = yield
    break if res
    sleep(1)
  end
  res
end

def verify(res, data)
  expect(res).to be_truthy
  expect(data).to have_key("guid")
  expect(data).to have_key("id")
  [data["guid"], data["id"]]
end

def post_comment(user, post_id)
  res, data = user.api_client.comment("comment text", post_id)
  verify(res, data)
end

def post_post(user, aspect)
  res, data = user.api_client.post("hello, friend", aspect)
  verify(res, data)
end

def expect_post(user, post_guid)
  res = wait_block(15) do
    user.api_client.get_path("/posts/#{post_guid}")
  end
  verify(res, res)
end

def expect_comment(user, post_guid, comment_guid)
  res = wait_block(15) do
    res = user.api_client.get_path("/posts/#{post_guid}/comments")
    res if res.respond_to?(:count) && res.count > 0
  end
  verify(res, res.last)
  expect(res.last["guid"]).to eq(comment_guid)
end

def expect_no_comments(user, post_guid)
  res = wait_block(15) do
    res = user.api_client.get_path("/posts/#{post_guid}/comments")
    res if res.count == 0
  end
  expect(res).to be_truthy
end

def expect_no_post(user, post_guid)
  res = wait_block(15) do
    user.api_client.get_path("/posts/#{post_guid}").nil?
  end
  expect(res).to be_truthy
end

shared_examples_for "conversation with a post and comments" do
  it "" do
    post_guid, post_id_on_pod1 = post_post(@user1, aspect)

    _, post_id_on_pod2 = expect_post(@user2, post_guid)

    comment_guid, comment_id = post_comment(@user2, post_id_on_pod2)
    expect_comment(@user1, post_id_on_pod1, comment_guid)

    another_comment_guid, another_comment_id = post_comment(@user1, post_id_on_pod1)
    expect_comment(@user2, post_id_on_pod2, another_comment_guid)

    expect(@user1.api_client.retract_entity("comment", another_comment_id)).to be_truthy
    expect(@user2.api_client.retract_entity("comment", comment_id)).to be_truthy
    expect_no_comments(@user1, post_guid)
    expect_no_comments(@user2, post_guid)

    expect(@user1.api_client.retract_entity("post", post_id_on_pod1)).to be_truthy
    expect_no_post(@user2, post_id_on_pod2)
  end
end

shared_examples_for "3 users conversation with a post and comments" do
  before do
    @user2.add_to_first_aspect(@user1)
    @user2.add_to_first_aspect(@user3)
  end

  it "" do
    post_guid, post_id_on_pod2 = post_post(@user2, aspect)
    _, post_id_on_pod1 = expect_post(@user1, post_guid)
    _, post_id_on_pod3 = expect_post(@user3, post_guid)

    comment_guid_1, = post_comment(@user1, post_id_on_pod1)
    expect_comment(@user2, post_id_on_pod2, comment_guid_1)
    expect_comment(@user3, post_id_on_pod3, comment_guid_1)

    comment_guid_3, = post_comment(@user3, post_id_on_pod3)
    expect_comment(@user2, post_id_on_pod2, comment_guid_3)
    expect_comment(@user3, post_id_on_pod3, comment_guid_3)

    comment_guid_2, = post_comment(@user2, post_id_on_pod2)
    expect_comment(@user1, post_id_on_pod1, comment_guid_2)
    expect_comment(@user3, post_id_on_pod3, comment_guid_2)

    @user2.api_client.get_path("/posts/#{post_id_on_pod2}/comments").each do |comment|
      expect(@user2.api_client.retract_entity("comment", comment["id"])).to be_truthy
    end

    expect_no_comments(@user1, post_id_on_pod1)
    expect_no_comments(@user3, post_id_on_pod3)

    expect(@user2.api_client.retract_entity("post", post_id_on_pod2)).to be_truthy
    expect_no_post(@user3, post_id_on_pod3)
    expect_no_post(@user1, post_id_on_pod1)
  end
end

["3 users conversation with a post and comments", "conversation with a post and comments"].each do |test_name|
  shared_examples_for "private and public #{test_name}" do
    context "public" do
      it_behaves_like test_name do
        let(:aspect) { "public" }
      end
    end

    context "private" do
      it_behaves_like test_name
    end
  end
end
