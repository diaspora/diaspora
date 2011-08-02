module ActionMailer
  module TestHelper
    extend ActiveSupport::Concern

    # Asserts that the number of emails sent matches the given number.
    #
    #   def test_emails
    #     assert_emails 0
    #     ContactMailer.deliver_contact
    #     assert_emails 1
    #     ContactMailer.deliver_contact
    #     assert_emails 2
    #   end
    #
    # If a block is passed, that block should cause the specified number of emails to be sent.
    #
    #   def test_emails_again
    #     assert_emails 1 do
    #       ContactMailer.deliver_contact
    #     end
    #
    #     assert_emails 2 do
    #       ContactMailer.deliver_contact
    #       ContactMailer.deliver_contact
    #     end
    #   end
    def assert_emails(number)
      if block_given?
        original_count = ActionMailer::Base.deliveries.size
        yield
        new_count = ActionMailer::Base.deliveries.size
        assert_equal original_count + number, new_count, "#{number} emails expected, but #{new_count - original_count} were sent"
      else
        assert_equal number, ActionMailer::Base.deliveries.size
      end
    end

    # Assert that no emails have been sent.
    #
    #   def test_emails
    #     assert_no_emails
    #     ContactMailer.deliver_contact
    #     assert_emails 1
    #   end
    #
    # If a block is passed, that block should not cause any emails to be sent.
    #
    #   def test_emails_again
    #     assert_no_emails do
    #       # No emails should be sent from this block
    #     end
    #   end
    #
    # Note: This assertion is simply a shortcut for:
    #
    #   assert_emails 0
    def assert_no_emails(&block)
      assert_emails 0, &block
    end
  end
end
