describe("app.views.Post", function(){
  context("markdown rendering", function() {
    beforeEach(function() {
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
      Diaspora.I18n.loadLocale({stream : {
        reshares : {
          one : "<%= count %> reshare",
          other : "<%= count %> reshares"
        },
        likes : {
          zero : "<%= count %> Likes",
          one : "<%= count %> Like",
          other : "<%= count %> Likes"
        }
      }})

      var posts = $.parseJSON(spec.readFixture("stream_json"))["posts"];

      this.collection = new app.collections.Posts(posts);
      this.statusMessage = this.collection.models[0];
      this.reshare = this.collection.models[1];

      // example from issue #2665
      this.evilUrl  = "http://www.bürgerentscheid-krankenhäuser.de";
      this.asciiUrl = "http://www.xn--brgerentscheid-krankenhuser-xkc78d.de";
    });

    it("correctly handles non-ascii characters in urls", function() {
      this.statusMessage.set({text: "<"+this.evilUrl+">"});
      var view = new app.views.StreamPost({model : this.statusMessage}).render();

      expect($(view.el).html()).toContain(this.asciiUrl);
      expect($(view.el).html()).toContain(this.evilUrl);
    });

    it("doesn't break link texts for non-ascii urls", function() {
      var linkText = "check out this awesome link!";
      this.statusMessage.set({text: "["+linkText+"]("+this.evilUrl+")"});
      var view = new app.views.StreamPost({model: this.statusMessage}).render();

      expect($(view.el).html()).toContain(this.asciiUrl);
      expect($(view.el).html()).toContain(linkText);
    });

    it("doesn't break reference style links for non-ascii urls", function() {
      var postContent = "blabla blab [my special link][1] bla blabla\n\n[1]: "+this.evilUrl+" and an optional title)";
      this.statusMessage.set({text: postContent});
      var view = new app.views.StreamPost({model: this.statusMessage}).render();

      expect($(view.el).html()).not.toContain(this.evilUrl);
      expect($(view.el).html()).toContain(this.asciiUrl);
    });

    it("correctly handles images with non-ascii urls", function() {
      var postContent = "![logo](http://bündnis-für-krankenhäuser.de/wp-content/uploads/2011/11/cropped-logohp.jpg)";
      var niceImg = '"http://xn--bndnis-fr-krankenhuser-i5b27cha.de/wp-content/uploads/2011/11/cropped-logohp.jpg"';
      this.statusMessage.set({text: postContent});
      var view = new app.views.StreamPost({model: this.statusMessage}).render();

      expect($(view.el).html()).toContain(niceImg);
    });

    it("correctly handles even more special links", function() {
      var specialLink = "http://موقع.وزارة-الاتصالات.مصر/"; // example from #3082
      var normalLink = "http://xn--4gbrim.xn----ymcbaaajlc6dj7bxne2c.xn--wgbh1c/";
      this.statusMessage.set({text: specialLink });
      var view = new app.views.StreamPost({model: this.statusMessage}).render();

      expect($(view.el).html()).toContain(specialLink);
      expect($(view.el).html()).toContain(normalLink);
    });
    it("works when three slashes are present in the url", function(){
      var badURL = "http:///scholar.google.com/citations?view_op=top_venues"
      this.statusMessage.set({text : badURL});
      var view = new app.views.StreamPost({model: this.statusMessage}).render();

    })
    
  });
});
