#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe PollParticipationSignature, type: :model do
  it_behaves_like "signature data" do
    let(:relayable_type) { :poll_participation }
  end
end
