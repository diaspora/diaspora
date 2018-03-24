# frozen_string_literal: true

module InvitationCodesHelper
  def invite_hidden_tag(invite)
    if invite.present?
      hidden_field_tag 'invite[token]', invite.token
    end
  end

  def invite_link(invite_code)
    text_field_tag :invite_code, invite_code_url(invite_code), class: "form-control", readonly: true
  end

  def invited_by_message
    inviter = current_user.invited_by
    if inviter.present?
      @person = inviter.person
      render partial: "people/add_contact"
    end
  end
end
