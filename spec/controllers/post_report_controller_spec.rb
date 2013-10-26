require 'spec_helper'

describe PostReportController do
  before do
    sign_in alice
    @message = alice.post(:status_message, :text => "hey", :to => alice.aspects.first.id)
  end

  describe '#index' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :index
        response.should redirect_to stream_path
      end
    end
    
    context 'admin signed in' do
      before do
        Role.add_admin(alice.person)
      end
      it 'succeeds and renders index' do
        get :index
        response.should render_template('index')
      end
    end
  end

  describe '#create' do
    context 'report offensive content' do
      it 'succeeds' do
        put :create, :post_id => @message.id, :text => 'offensive content'
        response.status.should == 200
        PostReport.exists?(:post_id => @message.id).should be_true
      end
    end
  end

  describe '#update' do
    context 'mark report as user' do
      it 'is behind redirect_unless_admin' do
        put :update, :id => @message.id
        response.should redirect_to stream_path
        PostReport.where(:reviewed => false, :post_id => @message.id).should be_true
      end
    end

    context 'mark report as admin' do
      before do
        Role.add_admin(alice.person)
      end
      it 'succeeds' do
        put :update, :id => @message.id
        response.status.should == 302
        PostReport.where(:reviewed => true, :post_id => @message.id).should be_true
      end
    end
  end

  describe '#destroy' do
    context 'destroy post as user' do
      it 'is behind redirect_unless_admin' do
        delete :destroy, :id => @message.id
        response.should redirect_to stream_path
        PostReport.where(:reviewed => false, :post_id => @message.id).should be_true
      end
    end

    context 'destroy post as admin' do
      before do
        Role.add_admin(alice.person)
      end
      it 'succeeds' do
        delete :destroy, :id => @message.id
        response.status.should == 302
        PostReport.where(:reviewed => true, :post_id => @message.id).should be_true
      end
    end
  end
end
