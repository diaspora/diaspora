# frozen_string_literal: true

describe "sidekiq_scheduled initializer" do
  describe "#valid_config?" do
    let(:schedule_file) { Tempfile.new(%w[schedule .yml]) }

    after { schedule_file.close! }

    it "accepts a freshly generated config" do
      regenerate_config(schedule_file.path)

      expect(valid_config?(schedule_file.path)).to be_truthy
    end

    it "rejects a config with outdated worker class names" do
      outdated_config = default_job_config.to_h {|name, job|
        [name, job.merge(class: "Workers::#{job[:class].delete_suffix('Worker')}")]
      }
      File.write(schedule_file.path, outdated_config.to_yaml)

      expect(valid_config?(schedule_file.path)).to be_falsey
    end
  end
end
