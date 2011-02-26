require 'spec_helper'

describe StatisticsController do
  render_views

  before do
    AppConfig[:admins] = ['alice']
    sign_in :user, alice
  end

  before do
    faker_stat = Statistic.generate
    @stat = Statistic.new
    5.times do |n|
      bob.post(:status_message, :message => 'hi', :to => bob.aspects.first)
    end
    (0..10).each do |n|
      @stat.data_points << DataPoint.users_with_posts_on_day(Time.now, n)
    end
    @stat.time = faker_stat.time
    @stat.save
  end

  describe '#index' do
    it 'returns all statistics' do
      get :index
      assigns[:statistics].should include @stat
    end
  end

  describe '#show' do
    it 'succeeds' do
      get :show, :id => @stat.id
      response.should be_success
    end
  end

  describe ' sets a before filter to use #redirect_unless_admin' do
    it 'redirects for non admins' do
      AppConfig[:admins] = ['bob']
      get :index
      response.should be_redirect
    end

    it 'succeeds' do
      get :index
      response.should be_success
    end
  end
end
