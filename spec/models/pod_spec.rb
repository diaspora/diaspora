require 'spec_helper'

describe Pod, :type => :model do
  describe '.find_or_create_by' do
    it 'takes a url, and makes one by host' do
      pod = Pod.find_or_create_by(url: 'https://joindiaspora.com/maxwell')
      expect(pod.host).to eq('joindiaspora.com')
    end

    it 'sets ssl boolean(side-effect)' do
      pod = Pod.find_or_create_by(url: 'https://joindiaspora.com/maxwell')
      expect(pod.ssl).to be true
    end
  end
end
