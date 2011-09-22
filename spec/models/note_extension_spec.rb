require 'spec_helper'

describe NoteExtension do
  before do
    @extension = Factory.create :note_extension
  end

  it 'must have a note' do
    @extension.note.should be_a Note
    @extension.note = nil
    assert !@extension.valid?
  end

  it 'gets destroyed when its note does' do
    NoteExtension.all.count.should == 1
    @extension.note.destroy
    NoteExtension.all.count.should == 0
  end
end
