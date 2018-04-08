// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Stream = app.views.InfScroll.extend({

  initialize: function() {
    this.stream = this.model;
    this.collection = this.stream.items;

    this.postViews = [];

    this.setupNSFW();
    this.setupInfiniteScroll();
    this.markNavSelected();
    this.initInvitationModal();
  },

  postClass : app.views.StreamPost,

  setupNSFW : function(){
    function reRenderPostViews() {
      _.map(this.postViews, function(view){ view.render() });
    }
    app.currentUser.bind("nsfwChanged", reRenderPostViews, this);
  },

  markNavSelected : function() {
    var activeStream = Backbone.history.fragment;
    var streamSelection = $("#stream-selection");
    streamSelection.find("[data-stream]").removeClass("selected");
    streamSelection.find("[data-stream='" + activeStream + "']").addClass("selected");

    var activityContainer = streamSelection.find(".my-activity");
    activityContainer.removeClass("activity-stream-selected");
    if (activeStream === "activity" || activeStream === "liked" || activeStream === "commented") {
      activityContainer.addClass("activity-stream-selected");
    }
  },

  initInvitationModal : function() {
    $(".invitations-link").click(function() {
      app.helpers.showModal("#invitationsModal");
    });
  }
});
// @license-end
