require 'spec_helper'

describe Jobs::SocketWebfinger do
  before do
    @user = alice
    @account = "tom@tom.joindiaspora.com"
  end
  it 'Makes a Webfinger object' do
    Webfinger.should_receive(:new).with(@account)
    Jobs::SocketWebfinger.perform(@user.id, @account)
  end
  it 'Queries the target account' do
    finger = mock()
    Webfinger.stub(:new).and_return(finger)

    finger.should_receive(:fetch).and_return(Factory.create(:person))
    Jobs::SocketWebfinger.perform(@user.id, @account)
  end
  it 'Sockets the resulting person on success' do
    finger = mock()
    Webfinger.stub(:new).and_return(finger)
    person = Factory.create(:person)
    finger.stub(:fetch).and_return(person)

    Diaspora::Websocket.should_receive(:to).with(@user.id).and_return(stub.as_null_object)
    Jobs::SocketWebfinger.perform(@user.id, @account)
  end
  it 'Passes opts through on success' do
    finger = mock()
    Webfinger.stub(:new).and_return(finger)
    person = Factory.create(:person)
    finger.stub(:fetch).and_return(person)

    opts = {:symbol => true}

    Diaspora::Websocket.should_receive(:to).with(@user.id).and_return(stub.as_null_object)
    Jobs::SocketWebfinger.perform(@user.id, @account, opts)
  end
  it 'sockets failure message on failure' do
    finger = mock()
    Webfinger.stub(:new).and_return(finger)
    finger.stub(:fetch).and_raise(Webfinger::WebfingerFailedError)

    opts = {:class => 'people', :status => 'fail', :query => @account, :response => I18n.t('people.webfinger.fail', :handle => @account )}.to_json
    Diaspora::Websocket.should_receive(:to).with(@user.id).and_return(stub.as_null_object)

    Jobs::SocketWebfinger.perform(@user.id, @account)

  end
end
