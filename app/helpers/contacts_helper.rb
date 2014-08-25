module ContactsHelper
  def contact_aspect_dropdown(contact)
    membership = contact.aspect_memberships.where(:aspect_id => @aspect.id).first unless @aspect.nil?

    if membership
      link_to(content_tag(:i, nil, :class => 'entypo circled-cross'),
        { :controller => "aspect_memberships",
          :action => 'destroy',
          :id => membership.id
        },
        :title => t('contacts.index.remove_person_from_aspect', :person_name => contact.person_first_name, :aspect_name => @aspect.name),
        :class => 'contact_remove-from-aspect',
        :method => 'delete',
        'data-membership_id' => membership.id
      )

    elsif @aspect.nil?
      render :partial => 'people/relationship_action',
              :locals => { :person => contact.person,
                           :contact => contact,
                           :current_user => current_user }
    else
      link_to(content_tag(:i, nil, :class => 'entypo circled-plus'),
        { :controller => "aspect_memberships",
          :action => 'create',
          :person_id => contact.person_id,
          :aspect_id => @aspect.id
        },
        :title => t('people.person.add_contact'),
        :class => 'contact_add-to-aspect',
        :method => 'create',
        'data-aspect_id' => @aspect.id,
        'data-person_id' => contact.person_id
      )
    end
  end

  def start_a_conversation_link(aspect, contacts_size)
    suggested_limit = 16
    conv_opts = { class: "conversation_button", rel: "facebox"}
    conv_opts[:title] = t('.many_people_are_you_sure', suggested_limit: suggested_limit) if contacts_size > suggested_limit
    
    link_to new_conversation_path(aspect_id: aspect.id, name: aspect.name), conv_opts do
      content_tag(:i, nil, :class => 'entypo mail contacts-header-icon', :title => t('contacts.index.start_a_conversation'))
    end
  end
end
