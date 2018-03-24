# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe CommentSignature, type: :model do
  it_behaves_like "signature data" do
    let(:relayable_type) { :comment }
  end
end
