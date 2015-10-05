// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.SinglePostContent = app.views.Base.extend({
  events: {
    "click .near-from": "toggleMap"
  },

  templateName: "single-post-viewer/single-post-content",
  tooltipSelector: "time, .post_scope",

  subviews : {
    "#single-post-actions" : "singlePostActionsView",
    "#single-post-moderation": "singlePostModerationView",
    "#real-post-content" : "postContentView",
    ".oembed" : "oEmbedView",
    ".opengraph" : "openGraphView",
    ".poll": "pollView",
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
    if (this.$(".mapContainer").length < 1){ return; }

    // find and set height of mapContainer to max size of the container
    // which is necessary to have all necessary tiles prerendered
    var mapContainer = this.$(".mapContainer");
    mapContainer.css("height", "200px");

    // get location data and render map
    var location = this.model.get("location");

    // If map function is enabled the maptiles from the Heidelberg University are used by default.

    var map = L.map(mapContainer[0]).setView([location.lat, location.lng], 14);

    var tiles = L.tileLayer("http://korona.geog.uni-heidelberg.de/tiles/roads/x={x}&y={y}&z={z}", {
      attribution: "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                    "rendering <a href='http://giscience.uni-hd.de/'>" +
                    "GIScience Research Group @ Heidelberg University</a>",
      maxZoom: 18,
    });

    // If the mapbox option is enabled in the diaspora.yml, the mapbox tiles with the podmin's credentials are used.
    if (gon.appConfig.map.mapbox.enabled) {

      tiles = L.tileLayer("https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}", {
        id: gon.appConfig.map.mapbox.id,
        /* jshint camelcase: false */
        accessToken: gon.appConfig.map.mapbox.access_token,
        /* jshint camelcase: true */
        attribution: "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                     "<a href='http://creativecommons.org/licenses/by-sa/2.0/''>CC-BY-SA</a>, " +
                     "Imagery © <a href='https://www.mapbox.com'>Mapbox</a>",
        maxZoom: 18,
      });
    }

    tiles.addTo(map);

    // set mapContainer size to a smaller preview size
    mapContainer.css("height", "75px");
    map.invalidateSize();

    // put marker on map
    L.marker(location).addTo(map);
    return map;
  },

  toggleMap: function () {
    $(".mapContainer").height($(".small-map")[0] ? 200 : 50);
    $(".leaflet-control-zoom").css("display", $(".small-map")[0] ? "block" : "none");
    $(".mapContainer").toggleClass("small-map");
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
