describe("app.views.PreviewPost", function() {
  beforeEach(function() {
    this.model = new app.models.Post(factory.postAttrs());
    this.view = new app.views.PreviewPost({model: this.model});
  });

  describe("initialize", function() {
    it("sets preview property in model", function() {
      this.view.initialize();
      expect(this.view.model.get("preview")).toBe(true);
    });

    it("calls app.views.OEmbed.initialize", function() {
      spyOn(app.views.OEmbed.prototype, "initialize");
      this.view.initialize();
      expect(app.views.OEmbed.prototype.initialize).toHaveBeenCalledWith({model: this.model});
    });

    it("calls app.views.OpenGraph.initialize", function() {
      spyOn(app.views.OpenGraph.prototype, "initialize");
      this.view.initialize();
      expect(app.views.OpenGraph.prototype.initialize).toHaveBeenCalledWith({model: this.model});
    });

    it("calls app.views.Poll.initialize", function() {
      spyOn(app.views.Poll.prototype, "initialize");
      this.view.initialize();
      expect(app.views.Poll.prototype.initialize).toHaveBeenCalledWith({model: this.model});
    });

    it("calls app.views.Poll.initialize", function() {
      spyOn(app.views.Poll.prototype, "initialize");
      this.view.initialize();
      expect(app.views.Poll.prototype.initialize).toHaveBeenCalledWith({model: this.model});
    });
  });

  describe("render", function() {
    it("calls postContentView", function() {
      spyOn(app.views.PreviewPost.prototype, "postContentView");
      this.view.render();
      expect(app.views.PreviewPost.prototype.postContentView).toHaveBeenCalled();
    });

    it("calls postLocationStreamView", function() {
      spyOn(app.views.PreviewPost.prototype, "postLocationStreamView");
      this.view.render();
      expect(app.views.PreviewPost.prototype.postLocationStreamView).toHaveBeenCalled();
    });
  });

  describe("postContentView", function() {
    it("calls app.views.Feedback.initialise", function() {
      spyOn(app.views.StatusMessage.prototype, "initialize");
      this.view.postContentView();
      expect(app.views.StatusMessage.prototype.initialize).toHaveBeenCalledWith({model: this.model});
    });
  });

  describe("postLocationStreamView", function() {
    it("calls app.views.Feedback.initialise", function() {
      spyOn(app.views.LocationStream.prototype, "initialize");
      this.view.postLocationStreamView();
      expect(app.views.LocationStream.prototype.initialize).toHaveBeenCalledWith({model: this.model});
    });
  });
});
