// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ContactStream = Backbone.View.extend({
  initialize: function(opts) {
    this.page = 1;
    var throttledScroll = _.throttle(_.bind(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);
    this.on("fetchContacts", this.fetchContacts, this);
    this.urlParams = opts.urlParams;
  },

  render: function() {
    this.fetchContacts();
  },

  fetchContacts: function() {
    this.$el.addClass("loading");
    $("#paginate .loader").removeClass("hidden");
    $.ajax(this._fetchUrl(), {
      context: this
    }).done(function(response) {
      if (response.length === 0) {
        this.onEmptyResponse();
      } else {
        this.appendContactViews(response);
        this.page++;
      }
    });
  },

  _fetchUrl: function() {
    var url = Routes.contacts({format: "json", page: this.page});
    if (this.urlParams) {
      url += "&" + this.urlParams;
    }
    return url;
  },

  onEmptyResponse: function() {
    if (this.collection.length === 0) {
      var content = document.createDocumentFragment();
      content = "<div id='no_contacts' class='well'>" +
                "  <h4>" +
                     Diaspora.I18n.t("contacts.search_no_results") +
                "  </h4>" +
                "</div>";
      this.$el.html(content);
    }
    this.off("fetchContacts");
    this.$el.removeClass("loading");
    $("#paginate .loader").addClass("hidden");
  },

  appendContactViews: function(contacts) {
    var content = document.createDocumentFragment();
    contacts.forEach(function(contactData) {
      var contact = new app.models.Contact(contactData);
      this.collection.add(contact);
      var view = new app.views.Contact({model: contact});
      content.appendChild(view.render().el);
    }.bind(this));
    this.$el.append(content);
    this.$el.removeClass("loading");
    $("#paginate .loader").addClass("hidden");
  },

  infScroll: function() {
    if (this.$el.hasClass("loading")) {
      return;
    }

    var distanceTop = $(window).height() + $(window).scrollTop(),
        distanceBottom = $(document).height() - distanceTop;
    if (distanceBottom < 300) {
      this.trigger("fetchContacts");
    }
  }
});
// @license-end
