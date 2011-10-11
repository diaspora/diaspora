require 'spec_helper'

describe Note do
  before do
    @extension = Factory.create :note_extension
    @note = @extension.note
  end

  it 'serves up its extension' do
    @note.formatted_extension.should == ' This is the extension...'
    @note.raw_extension.should == ' This is the extension...'
  end

  it 'serves up the full text' do
    @note.full_text.should == 'This is a note! This is the extension...'
    @note.raw_full_text.should == 'This is a note! This is the extension...'
  end
end
