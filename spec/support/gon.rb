# frozen_string_literal: true

shared_context :gon do
  let(:gon) { RequestStore.store[:gon].gon }
end

module HelperMethods
  def expect_aspects
    expect(gon["user"].aspects).not_to be_nil
    expect(gon["user"].aspects.length).not_to be_nil
  end

  def expect_memberships(memberships)
    expect(memberships).not_to be_nil
    expect(memberships.length).not_to be_nil
  end

  def expect_contact(preload_key)
    expect(gon["preloads"][preload_key][:contact]).not_to be_falsy
    expect_memberships(gon["preloads"][preload_key][:contact][:aspect_memberships])
  end

  def expect_gon_preloads_for_aspect_membership_dropdown(preload_key, sharing)
    expect(gon["preloads"][preload_key]).not_to be_nil
    if sharing
      expect_contact(preload_key)
    else
      expect(gon["preloads"][preload_key][:contact]).to be_falsy
    end
    expect_aspects
  end
end
