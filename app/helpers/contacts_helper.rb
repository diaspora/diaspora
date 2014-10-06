module ContactsHelper
  def contact_aspect_dropdown(contact)
    membership = contact.aspect_memberships.where(:aspect_id => @aspect.id).first unless @aspect.nil?

    if membership
      content_tag(:i, nil, :class => 'entypo circled-cross contact_remove-from-aspect',
                  :title => t('contacts.index.remove_contact'),
                  'data-aspect_id' => @aspect.id,
                  'data-person_id' => contact.person_id,
                  'data-membership_id' => membership.id )

    elsif @aspect.nil?
      render :partial => 'people/relationship_action',
              :locals => { :person => contact.person,
                           :contact => contact,
                           :current_user => current_user }
    else
      content_tag(:i, nil, :class => 'entypo circled-plus contact_add-to-aspect',
                  :title => t('contacts.index.add_contact'),
                  'data-aspect_id' => @aspect.id,
                  'data-person_id' => contact.person_id )
    end
  end

  def start_a_conversation_link(aspect, contacts_size)
    suggested_limit = 16
    conv_opts = { class: "conversation_button contacts_button"}
    conv_opts[:title] = t('.many_people_are_you_sure', suggested_limit: suggested_limit) if contacts_size > suggested_limit

    content_tag :span, conv_opts do
      content_tag(:i, nil, :class => 'entypo mail contacts-header-icon', :title => t('contacts.index.start_a_conversation'), 'data-toggle' => 'modal', 'data-target' => '#conversationModal')
    end
  end
end
