describe("app.views.SinglePostActions", function() {

	beforeEach(function() {
		loginAs({name: "bob"});

		this.post = factory.post();
		this.post.set({author: {
			id: app.user().id
		}});
	});

	context("author signed in", function() {
		it("displays a delete post button", function(){
			var view = new app.views.SinglePostActions({model: this.post}).render();
			expect(view.$(".delete-post")).toExist();
		});

		it("does not display a hide post button", function() {
			var view = new app.views.SinglePostActions({model: this.post}).render();
			expect(view.$(".hide-post")).not.toExist();
		});

		it("does not display an ignore user button", function() {
			var view = new app.views.SinglePostActions({model: this.post}).render();
			expect(view.$(".ignore-post")).not.toExist();
		});

		it("delete post button calls deletePost in view", function() {
			var view = new app.views.SinglePostActions({model: this.post});

			//Return false on confirm so redirect doesn't cause jasmine error.
			//This should be okay seeing as this is testing for deletePost being
			//called.
			spyOn(window, "confirm").andReturn(false);

			view = view.render();
			view.$(".delete-post").click();

			expect(window.confirm).toHaveBeenCalled();
		});
	});

	context("author not signed in, but still signed in as other user", function() {
		beforeEach(function() {
			logout();
			loginAs({name: "alice"});
		});

		it("does not display a delete post button", function() {
			var view = new app.views.SinglePostActions({model: this.post}).render();

			expect(view.$(".delete-post")).not.toExist();
		});

		it("displays a hide post button", function() {
			var view = new app.views.SinglePostActions({model: this.post}).render();

			expect(view.$(".hide-post")).toExist();
		});

		it("hide post button calls hidePost in view", function() {
			var view = new app.views.SinglePostActions({model: this.post});

			//Return false on confirm so redirect doesn't cause jasmine error.
			//This should be okay seeing as this is testing for hidePost being
			//called.
			spyOn(window, "confirm").andReturn(false);

			view = view.render();
			view.$(".hide-post").click();

			expect(window.confirm).toHaveBeenCalled();
		});

		it("displays ignore user button", function() {
			var view = new app.views.SinglePostActions({model: this.post}).render();

			expect(view.$(".ignore-user")).toExist();
		});

		it("ignore user button calls ignoreUser in view", function() {
			var view = new app.views.SinglePostActions({model: this.post});

			//Return false on confirm so redirect doesn't cause jasmine error.
			//This should be okay seeing as this is testing for ignoreUser being
			//called.
			spyOn(window, "confirm").andReturn(false);

			view = view.render();
			view.$(".ignore-user").click();

			expect(window.confirm).toHaveBeenCalled();
		});
	});

	context("not signed in at all", function() {
		beforeEach(function() {
			logout();
		});

		it("does not display a delete post button", function() {
			var view = new app.views.SinglePostActions({model: this.post}).render();

			expect(view.$(".delete-post")).not.toExist();
		});

		it("does not display a hide post button", function() {
			var view = new app.views.SinglePostActions({model: this.post}).render();

			expect(view.$(".hide-post")).not.toExist();
		});

		it("does not display an ignore user button", function() {
			var view = new app.views.SinglePostActions({model: this.post});

			expect(view.$(".ignore-user")).not.toExist();
		});
	});
});