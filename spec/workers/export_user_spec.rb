# frozen_string_literal: true

describe Workers::ExportUser do
  before do
    allow(User).to receive(:find).with(alice.id).and_return(alice)
  end

  it 'calls export! on user with given id' do
    expect(alice).to receive(:perform_export!)
    Workers::ExportUser.new.perform(alice.id)
  end

  it 'sends a success message when the export is successful' do
    allow(alice).to receive(:export).and_return(OpenStruct.new)
    expect(ExportMailer).to receive(:export_complete_for).with(alice).and_call_original
    Workers::ExportUser.new.perform(alice.id)
  end

  it 'sends a failure message when the export fails' do
    allow(alice).to receive(:export).and_return(nil)
    expect(alice).to receive(:perform_export!).and_return(false)
    expect(ExportMailer).to receive(:export_failure_for).with(alice).and_call_original
    Workers::ExportUser.new.perform(alice.id)
  end

  context "concurrency" do
    before do
      AppConfig.environment.single_process_mode = false
      AppConfig.settings.export_concurrency = 1
    end

    after :all do
      AppConfig.environment.single_process_mode = true
    end

    let(:pid) { "#{Socket.gethostname}:#{Process.pid}:#{SecureRandom.hex(6)}" }

    it "schedules a job for later when already another parallel export job is running" do
      expect(Sidekiq::Workers).to receive(:new).and_return(
        [[pid, SecureRandom.hex(4), {"payload" => {"class" => "Workers::ExportUser"}}]]
      )

      expect(Workers::ExportUser).to receive(:perform_in).with(kind_of(Integer), alice.id)
      expect(alice).not_to receive(:perform_export!)

      Workers::ExportUser.new.perform(alice.id)
    end

    it "runs the export when the own running job" do
      expect(Sidekiq::Workers).to receive(:new).and_return(
        [[pid, Thread.current.object_id.to_s(36), {"payload" => {"class" => "Workers::ExportUser"}}]]
      )

      expect(Workers::ExportUser).not_to receive(:perform_in).with(kind_of(Integer), alice.id)
      expect(alice).to receive(:perform_export!)

      Workers::ExportUser.new.perform(alice.id)
    end

    it "runs the export when no other job is running" do
      expect(Sidekiq::Workers).to receive(:new).and_return([])

      expect(Workers::ExportUser).not_to receive(:perform_in).with(kind_of(Integer), alice.id)
      expect(alice).to receive(:perform_export!)

      Workers::ExportUser.new.perform(alice.id)
    end

    it "runs the export when some other job is running" do
      expect(Sidekiq::Workers).to receive(:new).and_return(
        [[pid, SecureRandom.hex(4), {"payload" => {"class" => "Workers::OtherJob"}}]]
      )

      expect(Workers::ExportUser).not_to receive(:perform_in).with(kind_of(Integer), alice.id)
      expect(alice).to receive(:perform_export!)

      Workers::ExportUser.new.perform(alice.id)
    end

    it "runs the export when diaspora is in single process mode" do
      AppConfig.environment.single_process_mode = true
      expect(Sidekiq::Workers).not_to receive(:new)
      expect(Workers::ExportUser).not_to receive(:perform_in).with(kind_of(Integer), alice.id)
      expect(alice).to receive(:perform_export!)

      Workers::ExportUser.new.perform(alice.id)
    end
  end
end
