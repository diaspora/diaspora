# frozen_string_literal: true

describe ConversationsHelper, :type => :helper do
  before do
    @conversation = FactoryGirl.create(:conversation)
  end

  describe '#conversation_class' do
    it 'returns an empty string as default' do
      expect(conversation_class(@conversation, 0, nil)).to eq('')
      expect(conversation_class(@conversation, 0, @conversation.id+1)).to eq('')
    end

    it 'includes unread for unread conversations' do
      expect(conversation_class(@conversation, 1, nil)).to include('unread')
      expect(conversation_class(@conversation, 42, @conversation.id+1)).to include('unread')
      expect(conversation_class(@conversation, 42, @conversation.id)).to include('unread')
    end

    it 'does not include unread for read conversations' do
      expect(conversation_class(@conversation, 0, @conversation.id)).to_not include('unread')
    end

    it 'includes selected for selected conversations' do
      expect(conversation_class(@conversation, 0, @conversation.id)).to include('selected')
      expect(conversation_class(@conversation, 1, @conversation.id)).to include('selected')
    end

    it 'does not include selected for not selected conversations' do
      expect(conversation_class(@conversation, 1, @conversation.id+1)).to_not include('selected')
      expect(conversation_class(@conversation, 1, nil)).to_not include('selected')
    end
  end
end
