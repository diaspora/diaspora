# frozen_string_literal: true

# Memory usage methods are from: https://gist.github.com/pvdb/6240788

# returns detailed information about the process memory usage (as recorded in the "/proc/$$/statm" proc fs file)
def Process.statm
  Hash[%i[size resident shared trs lrs drs dt].zip(open("/proc/#{Process.pid}/statm").read.split)]
end

# the real memory (resident set) size of the process (in 1_024 byte units, assuming a 4kB memory page size)
def Process.rss
  Process.statm[:resident].to_i * 4
end

describe Diaspora::Exporter do
  context "on big profiles", :performance do
    before :all do
      if Post.count < 1000
        # Force fixture rebuild
        FileUtils.rm_f(Rails.root.join("tmp", "fixture_builder.yml"))
      end

      FixtureBuilder.configure do |fbuilder|
        # rebuild fixtures automatically when these files change:
        fbuilder.files_to_check += Dir[
          "app/models/*.rb", "lib/**/*.rb", "spec/factories/*.rb", "spec/support/fixture_builder.rb"
        ] - ["lib/diaspora/exporter.rb"]

        # now declare objects
        fbuilder.factory do
          create_basic_users

          1000.times {
            FactoryGirl.create(:signed_comment, post: bob.person.posts.first)
            FactoryGirl.create(:status_message, author: bob.person)
            FactoryGirl.create(:comment, author: bob.person)
            FactoryGirl.create(:contact, user: bob)
            FactoryGirl.create(:participation, author: bob.person)
          }
        end
      end
    end

    it "doesn't exceed sensible memory usage limit" do
      json = Diaspora::Exporter.new(bob).execute
      expect(json).not_to be_empty
      expect(Process.rss).to be < 500 * 1024
      puts "Process resident set size: #{Process.rss}"
    end
  end
end
