describe("app.views.Stream", function(){
  beforeEach(function(){
    // should be jasmine helper
    window.current_user = app.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

    this.collection = new app.collections.Stream(posts);

    this.view = new app.views.Stream({collection : this.collection});

    // do this manually because we've moved loadMore into render??
    this.view.render();
    _.each(this.view.collection.models, function(post){
      this.view.addPost(post);
    }, this);
  })

  describe("initialize", function(){

    it("binds an infinite scroll listener", function(){
    })
  })

  describe("#render", function(){
    beforeEach(function(){
      this.statusMessage = this.collection.models[0];
      this.reshare = this.collection.models[1];
      this.statusElement = $(this.view.$("#" + this.statusMessage.get("guid")));
      this.reshareElement = $(this.view.$("#" + this.reshare.get("guid")));
    })

    context("when rendering a Status Mesasage", function(){
      it("shows the status message in the content area", function(){
        expect(this.statusElement.find(".post-content p").text()).toContain("you're gonna love this")
      })
    })
  })

  describe("infScroll", function(){
    // NOTE: inf scroll happens at 300px

    beforeEach(function(){
      spyOn(this.view.collection, "fetch")
    })

    context("when the user is at the bottom of the page", function(){
      beforeEach(function(){
        spyOn($.fn, "height").andReturn(0)
        spyOn($.fn, "scrollTop").andReturn(100)
      })

      it("calls fetch", function(){
        spyOn(this.view, "isLoading").andReturn(false)

        this.view.infScroll();
        expect(this.view.collection.fetch).toHaveBeenCalled();
      })

      it("does not call fetch", function(){
        spyOn(this.view, "isLoading").andReturn(true)

        this.view.infScroll();
        expect(this.view.collection.fetch).not.toHaveBeenCalled();
      })
    })

    it("does not fetch new content when the user is not at the bottom of the page", function(){
      spyOn(this.view, "isLoading").andReturn(false)

      spyOn($.fn, "height").andReturn(0);
      spyOn($.fn, "scrollTop").andReturn(-400);

      this.view.infScroll();
      expect(this.view.collection.fetch).not.toHaveBeenCalled();
    })
  })
})
