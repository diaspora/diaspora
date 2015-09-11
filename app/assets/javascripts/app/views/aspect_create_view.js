// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.views.AspectCreate = app.views.Base.extend({

  templateName: "aspect_create_modal",

  events: {
    "click .btn.btn-primary": "createAspect",
    "keypress input#aspect_name": "inputKeypress"
  },

  initialize: function(opts) {
    this._personId = _.has(opts, "personId") ? opts.personId : null;
  },

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      addPersonId: this._personId !== null,
      personId : this._personId
    });
  },

  postRenderTemplate: function() {
    this.modal = this.$(".modal");
  },

  _contactsVisible: function() {
    return this.$("#aspect_contacts_visible").is(":checked");
  },

  _name: function() {
    return this.$("#aspect_name").val();
  },

  inputKeypress: function(evt) {
    if(evt.which === 13) {
      evt.preventDefault();
      this.createAspect();
    }
  },

  createAspect: function() {
    var aspect = new app.models.Aspect({
      "person_id": this._personId,
      "name": this._name(),
      "contacts_visible": this._contactsVisible()
    });

    var self = this;
    aspect.on("sync", function(response) {
      var aspectId   = response.get("id"),
          aspectName = response.get("name");

      self.modal.modal("hide");
      app.events.trigger("aspect:create", aspectId);
      app.flashMessages.success(Diaspora.I18n.t("aspects.create.success", {"name": aspectName}));
    });

    aspect.on("error", function() {
      self.modal.modal("hide");
      app.flashMessages.error(Diaspora.I18n.t("aspects.create.failure"));
    });
    return aspect.save();
  }
});
// @license-end
