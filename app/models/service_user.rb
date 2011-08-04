class ServiceUser < ActiveRecord::Base

  belongs_to :person
  belongs_to :contact
  belongs_to :service
  belongs_to :invitation

  before_save :attach_local_models
  scope :with_local_people, joins(:person).merge(Person.local)
  scope :with_remote_people, joins(:person).merge(Person.remote)
 

  def already_invited?
    self.invitation_id.present?
  end

  def on_diaspora?
    self.person_id.present?
  end

  def attach_local_models
    service_for_uid = Services::Facebook.where(:type => service.type.to_s, :uid => self.uid).first
    if !service_for_uid.blank? && (service_for_uid.user.person.profile.searchable)
      self.person = service_for_uid.user.person
    else
      self.person = nil
    end

    if self.person
      self.contact = self.service.user.contact_for(self.person)
    end

    self.invitation = Invitation.joins(:recipient).where(:sender_id => self.service.user_id,
                                                            :users => {:invitation_service => self.service.provider,
                                                                       :invitation_identifier => self.uid}).first
  end
end
