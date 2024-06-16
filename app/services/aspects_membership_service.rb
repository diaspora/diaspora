# frozen_string_literal: true

class AspectsMembershipService
  def initialize(user=nil)
    @user = user
  end

  def create(aspect_id, person_id)
    person = Person.find(person_id)
    aspect = @user.aspects.where(id: aspect_id).first
    raise ActiveRecord::RecordNotFound unless person.present? && aspect.present?

    contact = @user.share_with(person, aspect)
    raise I18n.t("aspects.add_to_aspect.failure") if contact.blank?

    AspectMembership.where(contact_id: contact.id, aspect_id: aspect.id).first
  end

  def destroy_by_ids(aspect_id, contact_id)
    aspect = @user.aspects.where(id: aspect_id).first
    contact = @user.contacts.where(person_id: contact_id).first
    destroy(aspect, contact)
  end

  def destroy_by_membership_id(membership_id)
    aspect = @user.aspects.joins(:aspect_memberships).where(aspect_memberships: {id: membership_id}).first
    contact = @user.contacts.joins(:aspect_memberships).where(aspect_memberships: {id: membership_id}).first
    destroy(aspect, contact)
  end

  def contacts_in_aspect(aspect_id)
    order = [Arel.sql("contact_id IS NOT NULL DESC"), "profiles.first_name ASC", "profiles.last_name ASC",
             "profiles.diaspora_handle ASC"]
    @user.aspects.find(aspect_id) # to provide better error code if aspect isn't correct
    contacts = @user.contacts.arel_table
    aspect_memberships = AspectMembership.arel_table
    @user.contacts.joins(
      contacts.join(aspect_memberships).on(
        aspect_memberships[:aspect_id].eq(aspect_id).and(
          aspect_memberships[:contact_id].eq(contacts[:id])
        )
      ).join_sources
    ).includes(person: :profile).order(order)
  end

  def all_contacts
    order = ["profiles.first_name ASC", "profiles.last_name ASC",
             "profiles.diaspora_handle ASC"]
    @user.contacts.includes(person: :profile).order(order)
  end

  private

  def destroy(aspect, contact)
    raise ActiveRecord::RecordNotFound unless aspect.present? && contact.present?

    raise Diaspora::NotMine unless @user.mine?(aspect) && @user.mine?(contact)

    membership = contact.aspect_memberships.where(aspect_id: aspect.id).first
    raise ActiveRecord::RecordNotFound if membership.blank?

    success = membership.destroy

    {success: success, membership: membership}
  end
end
