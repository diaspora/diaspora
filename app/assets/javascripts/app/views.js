app.views.Base = Backbone.View.extend({

  initialize : function(options) {
    this.setupRenderEvents();
  },

  presenter : function(){
    return this.defaultPresenter()
  },

  setupRenderEvents : function(){
    if(this.model) {
      //this should be in streamobjects view
      this.model.bind('remove', this.remove, this);
    }

    // this line is too generic.  we usually only want to re-render on
    // feedback changes as the post content, author, and time do not change.
    //
    // this.model.bind('change', this.render, this);
  },

  defaultPresenter : function(){
    var modelJson = this.model && this.model.attributes ? _.clone(this.model.attributes) : {}

    return _.extend(modelJson, {
      current_user : app.currentUser.attributes,
      loggedIn : app.currentUser.authenticated()
    });
  },

  render : function() {
    this.renderTemplate()
    this.renderSubviews()
    this.renderPluginWidgets()
    this.removeTooltips()

    return this
  },

  renderTemplate : function(){
    var presenter = _.isFunction(this.presenter) ? this.presenter() : this.presenter
    this.template = JST[this.templateName]
    if(!this.template) {
      console.log(this.templateName ? ("no template for " + this.templateName) : "no templateName specified")
    }

    this.$el
      .html(this.template(presenter))
      .attr("data-template", _.last(this.templateName.split("/")));
    this.postRenderTemplate();
  },

  postRenderTemplate : $.noop, //hella callbax yo

  renderSubviews : function(){
    var self = this;
    _.each(this.subviews, function(property, selector){
      var view = _.isFunction(self[property]) ? self[property]() : self[property]
      if(view) {
        self.$(selector).html(view.render().el)
        view.delegateEvents();
      }
    })
  },

  renderPluginWidgets : function() {
    this.$(this.tooltipSelector).tooltip();
    this.$("time").timeago();
  },

  removeTooltips : function() {
    $(".tooltip").remove();
  },

  setFormAttrs : function(){
    this.model.set(_.inject(this.formAttrs, _.bind(setValueFromField, this), {}))

    function setValueFromField(memo, attribute, selector){
      if(attribute.slice("-2") === "[]") {
        memo[attribute.slice(0, attribute.length - 2)] = _.pluck(this.$el.find(selector).serializeArray(), "value")
      } else {
        memo[attribute] = this.$el.find(selector).val() || this.$el.find(selector).text();
      }
      return memo
    }
  },

  destroyModel: function(evt) {
    evt && evt.preventDefault();
    if (confirm(Diaspora.I18n.t("confirm_dialog"))) {
      this.model.destroy();
      this.remove();
    }
  }
});

// Mixin to render a collection that fetches more via infinite scroll, for a view that has no template.
//  Requires:
//    a stream model, assigned to this.stream
//    a stream's posts, assigned to this.collection
//    a postClass to be declared
//    a #paginate div in the layout
//    a call to setupInfiniteScroll

app.views.InfScroll = app.views.Base.extend({
  setupInfiniteScroll : function() {
    this.postViews = this.postViews || []

    this.bind("loadMore", this.fetchAndshowLoader, this)
    this.stream.bind("fetched", this.hideLoader, this)
    this.stream.bind("allItemsLoaded", this.unbindInfScroll, this)

    this.collection.bind("add", this.addPostView, this);

    var throttledScroll = _.throttle(_.bind(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);
  },

  postRenderTemplate : function() {
    if(this.stream.isFetching()) { this.showLoader() }
  },

  createPostView : function(post){
    var postView = new this.postClass({ model: post, stream: this.stream });
    this.postViews.push(postView)
    return postView
  },

  addPostView : function(post) {
    var placeInStream = (this.collection.at(0).id == post.id) ? "prepend" : "append";
    this.$el[placeInStream](this.createPostView(post).render().el);
  },

  unbindInfScroll : function() {
    $(window).unbind("scroll");
  },

  renderTemplate : function(){
    this.renderInitialPosts()
  },

  renderInitialPosts : function(){
    this.$el.empty()
    this.stream.items.each(_.bind(function(post){
      this.$el.append(this.createPostView(post).render().el);
    }, this))
  },

  fetchAndshowLoader : function(){
    if(this.stream.isFetching()) { return false }
    this.stream.fetch()
    this.showLoader()
  },

  showLoader: function(){
    $("#paginate .loader").removeClass("hidden")
  },

  hideLoader: function() {
      $("#paginate .loader").addClass("hidden")
  },

  infScroll : function() {
    var $window = $(window)
      , distFromTop = $window.height() + $window.scrollTop()
      , distFromBottom = $(document).height() - distFromTop
      , bufferPx = 500;

    if(distFromBottom < bufferPx) {
      this.trigger("loadMore")
    }
  }
});

