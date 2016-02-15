describe("Diaspora.Mobile.Drawer", function(){
  describe("initialize", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_post_with_comments");
      Diaspora.Mobile.Drawer.initialize();
      this.menuBadge = $("#menu-badge");
      this.followedTags = $("#followed_tags");
      this.allAspects = $("#all_aspects");
    });

    it("correctly binds events", function(){
      expect($._data(this.allAspects[0], "events").tap.length).not.toBe(0);
      expect($._data(this.allAspects[0], "events").click.length).not.toBe(0);
      expect($._data(this.followedTags[0], "events").tap.length).not.toBe(0);
      expect($._data(this.followedTags[0], "events").click.length).not.toBe(0);
      expect($._data(this.menuBadge[0], "events").tap.length).not.toBe(0);
      expect($._data(this.menuBadge[0], "events").click.length).not.toBe(0);
    });

    it("opens and closes the drawer", function(){
      var $app = $("#app");
      expect($app).not.toHaveClass("draw");
      this.menuBadge.click();
      expect($app).toHaveClass("draw");
      this.menuBadge.click();
      expect($app).not.toHaveClass("draw");
    });

    it("shows and hides the aspects", function(){
      var $aspectList = this.allAspects.find("+ li");
      expect($aspectList).toHaveClass("hide");
      this.allAspects.click();
      expect($aspectList).not.toHaveClass("hide");
      this.allAspects.click();
      expect($aspectList).toHaveClass("hide");
    });

    it("shows and hides the followed tags", function(){
      var $tagList = this.followedTags.find("+ li");
      expect($tagList).toHaveClass("hide");
      this.followedTags.click();
      expect($tagList).not.toHaveClass("hide");
      this.followedTags.click();
      expect($tagList).toHaveClass("hide");
    });
  });
});
