# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ExportMailer, :type => :mailer do
  describe '#export_complete_for' do
    it "should deliver successfully" do
      expect { ExportMailer.export_complete_for(alice).deliver_now }.to_not raise_error
    end

    it "should be added to the delivery queue" do
      expect { ExportMailer.export_complete_for(alice).deliver_now }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should include correct recipient" do
      ExportMailer.export_complete_for(alice).deliver_now
      expect(ActionMailer::Base.deliveries[0].to[0]).to include(alice.email)
    end
  end

  describe '#export_failure_for' do
    it "should deliver successfully" do
      expect { ExportMailer.export_failure_for(alice).deliver_now }.to_not raise_error
    end

    it "should be added to the delivery queue" do
      expect { ExportMailer.export_failure_for(alice).deliver_now }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should include correct recipient" do
      ExportMailer.export_failure_for(alice).deliver_now
      expect(ActionMailer::Base.deliveries[0].to[0]).to include(alice.email)
    end
  end

  describe '#export_photos_complete_for' do
    it "should deliver successfully" do
      expect { ExportMailer.export_photos_complete_for(alice).deliver_now }.to_not raise_error
    end

    it "should be added to the delivery queue" do
      expect { ExportMailer.export_photos_complete_for(alice).deliver_now }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should include correct recipient" do
      ExportMailer.export_photos_complete_for(alice).deliver_now
      expect(ActionMailer::Base.deliveries[0].to[0]).to include(alice.email)
    end
  end

  describe '#export_photos_failure_for' do
    it "should deliver successfully" do
      expect { ExportMailer.export_photos_failure_for(alice).deliver_now }.to_not raise_error
    end

    it "should be added to the delivery queue" do
      expect { ExportMailer.export_photos_failure_for(alice).deliver_now }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should include correct recipient" do
      ExportMailer.export_photos_failure_for(alice).deliver_now
      expect(ActionMailer::Base.deliveries[0].to[0]).to include(alice.email)
    end
  end
end
