module ContactsHelper
  def contact_aspect_dropdown(contact)
    render :partial => 'people/relationship_action',
            :locals => { :person => contact.person,
                         :contact => contact,
                         :current_user => current_user }
  end

  def start_a_conversation_link(aspect, contacts_size)
    conv_opts = { class: "conversation_button contacts_button"}

    content_tag :span, conv_opts do
      content_tag(:i, nil, :class => 'entypo mail contacts-header-icon', :title => t('contacts.index.start_a_conversation'), 'data-toggle' => 'modal', 'data-target' => '#conversationModal')
    end
  end
end
