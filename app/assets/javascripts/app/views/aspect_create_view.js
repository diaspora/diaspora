// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.views.AspectCreate = app.views.Base.extend({

  templateName: "aspect_create_modal",

  events: {
    "click .btn.btn-primary": "createAspect",
    "keypress input#aspect_name": "inputKeypress"
  },

  initialize: function(opts) {
    if (opts && opts.person) {
      this.person = opts.person;
      this._personId = opts.person.id;
    }
  },

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      personId : this._personId
    });
  },

  _name: function() {
    return this.$("#aspect_name").val();
  },

  inputKeypress: function(evt) {
    if(evt.which === Keycodes.ENTER) {
      evt.preventDefault();
      this.createAspect();
    }
  },

  postRenderTemplate: function() {
    this.$(".modal").on("hidden.bs.modal", null, this, function(e) {
      e.data.ensureEventsOrder();
    });
  },

  createAspect: function() {
    this._eventsCounter = 0;

    this.$(".modal").modal("hide");

    this.listenToOnce(app.aspects, "sync", function(response) {
      var aspectName = response.get("name"),
          membership = response.get("aspect_membership");

      this._newAspectId = response.get("id");

      if (membership) {
        if (!this.person.contact) {
          this.person.contact = new app.models.Contact();
        }
        this.person.contact.aspectMemberships.add([membership]);
      }

      this.ensureEventsOrder();
      app.flashMessages.success(Diaspora.I18n.t("aspects.create.success", {"name": aspectName}));
    });

    this.listenToOnce(app.aspects, "error", function() {
      app.flashMessages.error(Diaspora.I18n.t("aspects.create.failure"));
      this.stopListening(app.aspects, "sync");
    });

    app.aspects.create({
      "person_id": this._personId || null,
      "name": this._name()
    });
  },

  // ensure that we trigger the aspect:create event only after both hidden.bs.modal and and aspects sync happens
  ensureEventsOrder: function() {
    this._eventsCounter++;
    if (this._eventsCounter > 1) {
      app.events.trigger("aspect:create", this._newAspectId);
    }
  }
});
// @license-end
