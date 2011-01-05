# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'spec_helper'
Dir.glob(File.join(Rails.root, 'lib', 'data_conversion', '*.rb')).each { |f| require f }

describe DataConversion::ExportFromMongo do
  before do
    @migrator = DataConversion::ExportFromMongo.new
  end
  describe '#sed_replace' do
    before do
      @test_string = '{ "_id" : { "$oid" : "4d0916c4cc8cb40e93000009" }, "name" : "Work", "created_at" : { "$date" : 1292441284000 }, "updated_at" : { "$date" : 1292546796000 }, "post_ids" : [ { "$oid" : "4d0aa87acc8cb4144b000009" }, { "$oid" : "4d0ab02ccc8cb41628000010" }, { "$oid" : "4d0ab2eccc8cb41628000011" } ], "user_id" : { "$oid" : "4d0916c2cc8cb40e93000006" } }'
    end
    it '#id_sed gets rid of the mongo id type specifier' do
      post_sed = `echo '#{@test_string}' | #{@migrator.id_sed}`
      post_sed.strip.match('"_id" : "4d0916c4cc8cb40e93000009", "name" : "Work",').should be_true
    end
    it '#date_sed gets rid of the mongo date type specifier' do
      post_sed = `echo '#{@test_string}' | #{@migrator.date_sed}`
      post_sed.strip.match('ork", "created_at" : 1292441284000, "updated_at" : 1292546796000, "post_ids" :').should be_true
    end
  end
end
