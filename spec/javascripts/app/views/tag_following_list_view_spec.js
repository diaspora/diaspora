describe("app.views.TagFollowingList", function(){
  beforeEach(function () {
    this.tagsUnsorted = [
      {name: "ab"},
      {name: "cd"},
      {name: "bc"}
    ];

    this.tagsSorted = [
      {name: "ab"},
      {name: "bc"},
      {name: "cd"}
    ];

    app.tagFollowings = new app.collections.TagFollowings(this.tagsUnsorted);
    this.view = new app.views.TagFollowingList({collection: app.tagFollowings});
  });

  describe("render", function(){
    it("lists the tags alphabetically ascending", function(){
      var html = this.view.render();
      for(var i=0;i<this.tagsSorted.length;i++) {
        expect(html.el.children[i].id).toMatch("tag-following-" + this.tagsSorted[i].name);
      }
    });
  });

  describe("adding tags", function(){
    it("inserts a new tag at top if it comes before all others alphabetically", function(){
      app.tagFollowings.create({name: "aa"});

      var html = this.view.render();
      expect(html.el.children[0].id).toMatch("tag-following-aa");
      expect(html.el.children[1].id).toMatch("tag-following-ab");
    });

    it("inserts a new tag at the bottom if it comes after all others alphabetically", function(){
      app.tagFollowings.create({name: "zz"});

      var html = this.view.render();
      var lastItemIndex = html.el.childElementCount -2; // last element is the input box
      expect(html.el.children[lastItemIndex].id).toMatch("tag-following-zz");
    });

    it("inserts a new tag at second place if it comes after the first alphabetically", function(){
      app.tagFollowings.create({name: "ac"});

      var html = this.view.render();
      expect(html.el.children[1].id).toMatch("tag-following-ac");
    });

    it("inserts a new tag second to last if it comes before last tag alphabetically", function(){
      app.tagFollowings.create({name: "ca"});

      var html = this.view.render();
      var lastItemIndex = html.el.childElementCount -3; // last element is the input box. And one up, please.
      expect(html.el.children[lastItemIndex].id).toMatch("tag-following-ca");
    });
  });
});
