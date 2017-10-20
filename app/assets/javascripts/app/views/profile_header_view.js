// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ProfileHeader = app.views.Base.extend({
  templateName: 'profile_header',

  subviews: {
    ".aspect-membership-dropdown": "aspectMembershipView"
  },

  events: {
    "click #mention_button": "showMentionModal",
    "click #message_button": "showMessageModal"
  },

  initialize: function(opts) {
    this.photos = _.has(opts, 'photos') ? opts.photos : null;
    this.contacts = _.has(opts, 'contacts') ? opts.contacts : null;
    this.model.on("change", this.render, this);
    $("#mentionModal").on("modal:loaded", this.mentionModalLoaded.bind(this));
    $("#mentionModal").on("hidden.bs.modal", this.mentionModalHidden);
  },

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      show_profile_btns: this._shouldShowProfileBtns(),
      show_photos: this._shouldShowPhotos(),
      show_contacts: this._shouldShowContacts(),
      is_blocked: this.model.isBlocked(),
      is_sharing: this.model.isSharing(),
      is_receiving: this.model.isReceiving(),
      is_mutual: this.model.isMutual(),
      has_tags: this._hasTags(),
      contacts: this.contacts,
      photos: this.photos
    });
  },

  aspectMembershipView: function() {
    return new app.views.AspectMembership({person: this.model, dropdownMayCreateNewAspect: true});
  },

  _hasTags: function() {
    return (this.model.get('profile')['tags'].length > 0);
  },

  _shouldShowProfileBtns: function() {
    return (app.currentUser.authenticated() && !this.model.get('is_own_profile'));
  },

  _shouldShowPhotos: function() {
    return (this.photos && this.photos > 0);
  },

  _shouldShowContacts: function() {
    return (this.contacts && this.contacts > 0);
  },

  showMentionModal: function() {
    app.helpers.showModal("#mentionModal");
  },

  mentionModalLoaded: function() {
    app.publisher = new app.views.Publisher({
      standalone: true,
      prefillMention: _.extend({handle: this.model.get("diaspora_id")}, this.model.attributes)
    });
    app.publisher.open();
    $("#publisher").bind("ajax:success", function() {
      $("#mentionModal").modal("hide");
      app.publisher.clear();
      app.publisher.remove();
      app.flashMessages.success(Diaspora.I18n.t("publisher.mention_success", {names: this.model.get("name")}));
    }.bind(this));
  },

  mentionModalHidden: function() {
    app.publisher.clear();
    app.publisher.remove();
    $("#mentionModal .modal-body").empty();
  },

  showMessageModal: function(){
    $("#conversationModal").on("modal:loaded", function() {
      new app.views.ConversationsForm({prefill: [this.model]});
    }.bind(this));
    app.helpers.showModal("#conversationModal");
  }
});
// @license-end

