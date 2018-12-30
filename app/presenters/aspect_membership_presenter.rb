# frozen_string_literal: true

class AspectMembershipPresenter < BasePresenter
  def initialize(membership)
    @membership = membership
  end

  def base_hash
    {
      id:     @membership.id,
      aspect: AspectPresenter.new(@membership.aspect).as_json,
    }
  end
end
