#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class SampleWebratTest < ActionController::IntegrationTest

  def test_widget
    visit "/"
    assert_contain "sign in"
  end
end
