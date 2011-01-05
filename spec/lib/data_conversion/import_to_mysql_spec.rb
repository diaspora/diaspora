# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'spec_helper'
Dir.glob(File.join(Rails.root, 'lib', 'data_conversion', '*.rb')).each { |f| require f }

describe DataConversion::ImportToMysql do
  def copy_fixture_for(table_name)
    FileUtils.cp("#{Rails.root}/spec/fixtures/data_conversion/#{table_name}.csv",
                 "#{@migrator.full_path}/#{table_name}.csv")
  end

  before do
    @migrator = DataConversion::ImportToMysql.new
    @migrator.full_path = "/tmp/data_conversion"
    system("rm -rf #{@migrator.full_path}")
    FileUtils.mkdir_p(@migrator.full_path)
  end

  describe "#import_raw" do
    describe "users" do
      before do
        copy_fixture_for("users")
      end
      it "imports data into the mongo_users table" do
        Mongo::User.count.should == 0
        @migrator.import_raw
        Mongo::User.count.should == 1
      end
      it "imports all the columns" do
        @migrator.import_raw
        beckett = Mongo::User.first
        beckett.mongo_id.should == "4d1513542367bc2525000002"
        beckett.username.should == "beckett"
        beckett.serialized_private_key.should_not be_nil
        beckett.encrypted_password.should_not be_nil
        beckett.invites.should == 5
        beckett.invitation_token.should == ""
        beckett.invitation_sent_at.should be_nil
        beckett.getting_started.should be_false
        beckett.disable_mail.should be_false
        beckett.language.should == 'en'
        beckett.last_sign_in_ip.should == '127.0.0.1'
        beckett.last_sign_in_at.should_not be_nil
        beckett.reset_password_token.should == ""
        beckett.password_salt.should_not be_nil
      end
    end
  end
end
