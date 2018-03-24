# frozen_string_literal: true

describe Workers::ExportPhotos do
  before do
    allow(User).to receive(:find).with(alice.id).and_return(alice)
  end

  it 'calls export_photos! on user with given id' do
    expect(alice).to receive(:perform_export_photos!)
    Workers::ExportPhotos.new.perform(alice.id)
  end

  it 'sends a success message when the export photos is successful' do
    allow(alice).to receive(:exported_photos_file).and_return(OpenStruct.new)
    expect(ExportMailer).to receive(:export_photos_complete_for).with(alice).and_call_original
    Workers::ExportPhotos.new.perform(alice.id)
  end

  it 'sends a failure message when the export photos fails' do
    allow(alice).to receive(:exported_photos_file).and_return(nil)
    expect(alice).to receive(:perform_export_photos!).and_return(false)
    expect(ExportMailer).to receive(:export_photos_failure_for).with(alice).and_call_original
    Workers::ExportPhotos.new.perform(alice.id)
  end
end
