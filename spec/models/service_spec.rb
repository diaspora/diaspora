# frozen_string_literal: true

describe Service, :type => :model do
  before do
    @post = alice.post(:status_message, :text => "hello", :to => alice.aspects.first.id)
    @service = Services::Facebook.new(:access_token => "yeah", :uid => 1)
    alice.services << @service
  end

  it 'is unique to a user by service type and uid' do
    @service.save

    second_service = Services::Facebook.new(:access_token => "yeah", :uid => 1)

    alice.services << second_service
    alice.services.last.save
    expect(alice.services.last).to be_invalid
  end

  it 'by default has no profile photo url' do
    expect( described_class.new.profile_photo_url ).to be_nil
  end

  describe '.titles' do
    it "converts passed service titles into service constants" do
      expect( described_class.titles( ['twitter'] ) ).to eql ['Services::Twitter']
    end
  end

  describe '.first_from_omniauth' do
    let(:omniauth) { { 'provider' => 'facebook', 'uid' => '1', 'credentials' => {}, 'info' => {} } }
    it 'first service by provider and uid' do
      expect( described_class.first_from_omniauth( omniauth ) ).to eql @service
    end
  end

  describe '.initialize_from_omniauth' do
    let(:omniauth) do
      { 'provider' => 'facebook',
        'uid'      => '2',
        'info'   => { 'nickname' => 'grimmin' },
        'credentials' => { 'token' => 'tokin', 'secret' =>"not_so_much" }
      }
    end
    let(:subject) { described_class.initialize_from_omniauth( omniauth ) }

    it 'new service obj of type Services::Facebook' do
      expect( subject.type ).to eql "Services::Facebook"
    end

    it 'new service obj with oauth options populated' do
      expect( subject.uid ).to eql "2"
      expect( subject.nickname ).to eql "grimmin"
      expect( subject.access_token ).to eql "tokin"
      expect( subject.access_secret ).to eql "not_so_much"
    end
  end
end
