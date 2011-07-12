/*   Copyright (c) 2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Diaspora", function() {
  describe("widgets", function() {
    describe("post", function() {
      describe("start", function() {
        it("should set up like on initialize", function() {
          spyOn(Diaspora.widgets.post, "setUpLikes");
          Diaspora.widgets.post.start();
          expect(Diaspora.widgets.post.setUpLikes).toHaveBeenCalled();
        });
      });
      describe("setUpLikes", function() {
        it("adds a listener for the click event on a.expand_likes", function() {
          spyOn(window, "$").andCallThrough();
          Diaspora.widgets.post.start();
          expect($).toHaveBeenCalledWith(Diaspora.widgets.post.likes.expanders);
          $.reset();
        });

        it("adds a listener for ajax:success and ajax:failure", function() {
          spyOn(window, "$").andCallThrough();
          Diaspora.widgets.post.start();
          expect($).toHaveBeenCalledWith(Diaspora.widgets.post.likes.actions);
          $.reset();
        });
      });

    });
  });
});

