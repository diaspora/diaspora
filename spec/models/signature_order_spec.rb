# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe SignatureOrder, type: :model do
  context "validation" do
    it "requires an order" do
      order = SignatureOrder.new
      expect(order).not_to be_valid

      order.order = "author guid"
      expect(order).to be_valid
    end

    it "doesn't allow the same order twice" do
      first = SignatureOrder.create!(order: "author guid")
      expect(first).to be_valid

      second = SignatureOrder.new(order: first.order)
      expect(second).not_to be_valid
    end
  end
end
