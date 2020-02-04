# frozen_string_literal: true

describe PhotoPresenter do
  before do
    @photo = bob.post(:photo, pending: true, user_file: File.open(photo_fixture_name), to: "all")
  end

  it "presents limited API JSON" do
    photo_json = PhotoPresenter.new(@photo).as_api_json(false)
    expect(photo_json.has_key?(:guid)).to be_falsey
  end

  it "presents full API JSON" do
    photo_json = PhotoPresenter.new(@photo).as_api_json(true)
    expect(photo_json[:guid]).to eq(@photo.guid)
    confirm_photo_format(photo_json, @photo)
  end

  it "defaults to limited API JSON" do
    photo_json_limited = PhotoPresenter.new(@photo).as_api_json(false)
    photo_json_default = PhotoPresenter.new(@photo).as_api_json
    expect(photo_json_limited).to eq(photo_json_default)
  end

  # rubocop:disable Metrics/AbcSize
  def confirm_photo_format(photo, ref_photo)
    if ref_photo.status_message_guid
      expect(photo[:post]).to eq(ref_photo.status_message_guid)
    else
      expect(photo.has_key?(:post)).to be_falsey
    end
    expect(photo[:dimensions].has_key?(:height)).to be_truthy
    expect(photo[:dimensions].has_key?(:width)).to be_truthy
    expect(photo[:sizes][:small]).to be_truthy
    expect(photo[:sizes][:medium]).to be_truthy
    expect(photo[:sizes][:large]).to be_truthy
    expect(photo[:sizes][:raw]).to be_truthy
  end
  # rubocop:enable Metrics/AbcSize
end
