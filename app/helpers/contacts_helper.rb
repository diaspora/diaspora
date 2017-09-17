# frozen_string_literal: true

module ContactsHelper
  def start_a_conversation_link(aspect, contacts_size)
    conv_opts = { class: "conversation_button contacts_button"}

    content_tag :span, conv_opts do
      content_tag :i,
                  nil,
                  class: "entypo-mail contacts-header-icon",
                  title: t("contacts.index.start_a_conversation")
    end
  end
end
