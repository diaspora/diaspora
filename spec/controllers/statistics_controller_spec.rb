require 'spec_helper'

describe StatisticsController do
  render_views

  before do
    sign_in :user, alice
  end

  before do
    @stat = Statistic.new
    5.times do |n|
      bob.post(:status_message, :message => 'hi', :to => bob.aspects.first)
    end
    (0..10).each do |n|
      @stat.data_points << DataPoint.users_with_posts_on_day(Time.now, n)
    end
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

  describe '#graph' do
    it 'generates a graph' do
      get :graph, :id => @stat.id
      response.should be_success
    end
  end

end
