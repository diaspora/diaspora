// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.pages.Contacts = Backbone.View.extend({

  el: "#contacts_container",

  events: {
    "click #contacts_visibility_toggle" : "toggleContactVisibility",
    "click #chat_privilege_toggle" : "toggleChatPrivilege",
    "click #change_aspect_name" : "showAspectNameForm",
    "click .conversation_button": "showMessageModal",
    "click #invitations-button": "showInvitationsModal"
  },

  initialize: function(opts) {
    this.visibilityToggle = $("#contacts_visibility_toggle i");
    this.chatToggle = $("#chat_privilege_toggle i");
    this.stream = opts.stream;
    this.stream.render();
    $("#people-stream.contacts .header i").tooltip({"placement": "bottom"});
    $(document).on("ajax:success", "form.edit_aspect", this.updateAspectName);
    app.events.on("aspect:create", function(){ window.location.reload() });
    app.events.on("aspect_membership:create", this.addAspectMembership, this);
    app.events.on("aspect_membership:destroy", this.removeAspectMembership, this);

    this.aspectCreateView = new app.views.AspectCreate({ el: $("#newAspectContainer") });
    this.aspectCreateView.render();

    this.setupAspectSorting();
  },

  toggleChatPrivilege: function() {
    if (this.chatToggle.hasClass("enabled")) {
      this.chatToggle.tooltip("destroy")
                      .removeClass("enabled")
                      .removeAttr("data-original-title")
                      .attr("title", Diaspora.I18n.t("contacts.aspect_chat_is_not_enabled"))
                      .tooltip({"placement": "bottom"});
    } else {
      this.chatToggle.tooltip("destroy")
                      .addClass("enabled")
                      .removeAttr("data-original-title")
                      .attr("title", Diaspora.I18n.t("contacts.aspect_chat_is_enabled"))
                      .tooltip({"placement": "bottom"});
    }
  },

  toggleContactVisibility: function() {
    if (this.visibilityToggle.hasClass("entypo-lock-open")) {
      this.visibilityToggle.removeClass("entypo-lock-open")
                            .addClass("entypo-lock")
                            .tooltip("destroy")
                            .removeAttr("data-original-title")
                            .attr("title", Diaspora.I18n.t("contacts.aspect_list_is_not_visible"))
                            .tooltip({"placement": "bottom"});
    }
    else {
      this.visibilityToggle.removeClass("entypo-lock")
                            .addClass("entypo-lock-open")
                            .tooltip("destroy")
                            .removeAttr("data-original-title")
                            .attr("title", Diaspora.I18n.t("contacts.aspect_list_is_visible"))
                            .tooltip({"placement": "bottom"});
    }
  },

  showAspectNameForm: function() {
    $(".header > h3").hide();
    var aspectName = $.trim($(".header h3 #aspect_name").text());
    $("#aspect_name_form #aspect_name").val(aspectName);
    $(".header > #aspect_name_form").show();
  },

  updateAspectName: function(evt,data){
    $(".header #aspect_name").text(data['name']);
    $("#aspect_nav [data-aspect-id='"+data['id']+"'] .name").text(data['name']);
    $(".header > #aspect_name_form").hide();
    $(".header > h3").show();
  },

  showMessageModal: function(){
    $("#conversationModal").on("modal:loaded", function() {
      var people = _.pluck(app.contacts.filter(function(contact) {
        return contact.inAspect(app.aspect.get("id"));
      }), "person");
      new app.views.ConversationsForm({prefill: people});
    });
    app.helpers.showModal("#conversationModal");
  },

  showInvitationsModal: function() {
    app.helpers.showModal("#invitationsModal");
  },

  setupAspectSorting: function() {
    $("#aspect_nav .list-group").sortable({
      items: "a.aspect[data-aspect-id]",
      update: function() {
        $("#aspect_nav .ui-sortable").addClass("syncing");
        var data = JSON.stringify({ ordered_aspect_ids: $(this).sortable("toArray", { attribute: "data-aspect-id" }) });
        $.ajax(Routes.orderAspects(),
          { type: "put", dataType: "text", contentType: "application/json", data: data })
          .done(function() { $("#aspect_nav .ui-sortable").removeClass("syncing"); });
      },
      revert: true,
      helper: "clone"
    });
  },

  updateBadgeCount: function(selector, change) {
    var count = parseInt($("#aspect_nav " + selector + " .badge").text(), 10);
    $("#aspect_nav " + selector + " .badge").text(count + change);
  },

  addAspectMembership: function(data) {
    if(data.startSharing) {
      this.updateBadgeCount(".all_aspects", 1);

      var contact = this.stream.collection.find(function(c) {
        return c.get("person").id === data.membership.personId;
      });

      if(contact && contact.person.get("relationship") === "sharing") {
        contact.person.set({relationship: "mutual"});
        this.updateBadgeCount(".only_sharing", -1);
      }
      else if(contact && contact.person.get("relationship") === "not_sharing") {
        contact.person.set({relationship: "receiving"});
        this.updateBadgeCount(".all_contacts", 1);
      }
    }
    this.updateBadgeCount("[data-aspect-id='" + data.membership.aspectId + "']", 1);
  },

  removeAspectMembership: function(data) {
    if(data.stopSharing) {
      this.updateBadgeCount(".all_aspects", -1);

      var contact = this.stream.collection.find(function(c) {
        return c.get("person").id === data.membership.personId;
      });

      if(contact && contact.person.get("relationship") === "mutual") {
        contact.person.set({relationship: "sharing"});
        this.updateBadgeCount(".only_sharing", 1);
      }
      else if(contact && contact.person.get("relationship") === "receiving") {
        contact.person.set({relationship: "not_sharing"});
        this.updateBadgeCount(".all_contacts", -1);
      }
    }
    this.updateBadgeCount("[data-aspect-id='" + data.membership.aspectId + "']", -1);
  }
});
// @license-end
