// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.SinglePostContent = app.views.Base.extend({
  events: {
    "click .near-from": "toggleMap"
  },

  templateName: 'single-post-viewer/single-post-content',
  tooltipSelector: "time, .post_scope",

  subviews : {
    "#single-post-actions" : "singlePostActionsView",
    "#single-post-moderation": "singlePostModerationView",
    "#real-post-content" : "postContentView",
    ".oembed" : "oEmbedView",
    ".opengraph" : "openGraphView",
    '.poll': 'pollView',
  },

  initialize : function() {
    this.singlePostActionsView = new app.views.SinglePostActions({model: this.model});
    this.singlePostModerationView = new app.views.SinglePostModeration({model: this.model});
    this.oEmbedView = new app.views.OEmbed({model : this.model});
    this.openGraphView = new app.views.SPVOpenGraph({model : this.model});
    this.postContentView = new app.views.ExpandedStatusMessage({model: this.model});
    this.pollView = new app.views.Poll({ model: this.model });
  },

  map : function(){
    if (this.$el.find(".mapContainer")&&gon.appConfig.map.enabled){

      // find and set height of mapContainer to max size of the container
      // which is necessary to have all necessary tiles prerendered
      var mapContainer = this.$el.find(".mapContainer");
      mapContainer.css("height", "200px");

      // get location data and render map
      var location = this.model.get("location");
      var tileLayerSource = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}";
      var map = L.map(mapContainer[0]).setView([location.lat, location.lng], 14);
      var attribution = "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                        "<a href='http://creativecommons.org/licenses/by-sa/2.0/''>CC-BY-SA</a>, " +
                        "Imagery © <a href='http://mapbox.com'>Mapbox</a>";

      L.tileLayer(tileLayerSource, {
        attribution:  attribution,
        maxZoom: 18,
        id: gon.appConfig.map.mapbox.id,
        accessToken: gon.appConfig.map.mapbox.accessToken
      }).addTo(map);

      // set mapContainer size to a smaller preview size
      mapContainer.css("height", "75px");
      map.invalidateSize();

      // put marker on map
      var markerOnMap = L.marker(location).addTo(map);
      return map;
      };
  },

  toggleMap: function () {
    if (gon.appConfig.map.enabled){
      if (this.$el.find(".mapContainer").css("height") === "75px") {
        this.$el.find(".mapContainer").css("height", "200px");
        this.$el.find(".leaflet-control-zoom").css("display", "block");
      } else {
          this.$el.find(".mapContainer").css("height", "75px");
          this.$el.find(".leaflet-control-zoom").css("display", "none");
      }
    }
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser :app.currentUser.isAuthorOf(this.model),
      showPost : this.showPost(),
      text : app.helpers.textFormatter(this.model.get("text"), this.model.get("mentioned_people"))
    });
  },

  showPost : function() {
    return (app.currentUser.get("showNsfw")) || !this.model.get("nsfw");
  },

  postRenderTemplate : function(){
    _.defer(_.bind(this.map, this));
  }
});
// @license-end
