# frozen_string_literal: true

module ServicesHelper
  def contact_proxy(friend)
    friend.contact || contact_proxy_template.dup.tap {|c| c.person = friend.person }
  end

  private

  def contact_proxy_template
    @@contact_proxy ||= Contact.new(:aspects => [])
  end
end
