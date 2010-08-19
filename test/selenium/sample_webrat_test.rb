class SampleWebratTest < ActionController::IntegrationTest

  def test_widget
    visit "/"
    assert_contain "sign in"
  end
end
