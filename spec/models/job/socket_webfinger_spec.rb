require 'spec_helper'

describe Job::SocketWebfinger do
  before do
    @user = alice
    @account = "tom@tom.joindiaspora.com"
  end
  it 'Makes a Webfinger object' do
    Webfinger.should_receive(:new).with(@account)
    Job::SocketWebfinger.perform(@user.id, @account)
  end
  it 'Queries the target account' do
    finger = mock()
    Webfinger.stub(:new).and_return(finger)

    finger.should_receive(:fetch).and_return(Factory.create(:person))
    Job::SocketWebfinger.perform(@user.id, @account)
  end
  it 'Sockets the resulting person on success' do
    finger = mock()
    Webfinger.stub(:new).and_return(finger)
    person = Factory.create(:person)
    finger.stub(:fetch).and_return(person)

    person.should_receive(:socket_to_user).with(@user.id, {})
    Job::SocketWebfinger.perform(@user.id, @account)
  end
  it 'Passes opts through on success' do
    finger = mock()
    Webfinger.stub(:new).and_return(finger)
    person = Factory.create(:person)
    finger.stub(:fetch).and_return(person)

    opts = {:symbol => true}
    person.should_receive(:socket_to_user).with(@user.id, opts)
    Job::SocketWebfinger.perform(@user.id, @account, opts)
  end
  it 'sockets failure message on failure' do
    finger = mock()
    Webfinger.stub(:new).and_return(finger)
    finger.stub(:fetch).and_raise(Webfinger::WebfingerFailedError)

    opts = {:class => 'people', :status => 'fail', :query => @account, :response => I18n.t('people.webfinger.fail', :handle => @account )}.to_json
    Diaspora::WebSocket.should_receive(:queue_to_user).with(@user.id, opts)
    Job::SocketWebfinger.perform(@user.id, @account)

  end
end
