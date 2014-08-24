describe("app.views.Poll", function(){
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
    this.view = new app.views.Poll({ model: factory.postWithPoll()});
    this.view.render();
  });

  describe("setProgressBar", function(){
    it("sets the progress bar according to the voting result", function(){
      var percentage = (this.view.poll.poll_answers[0].vote_count / this.view.poll.participation_count)*100;
      expect(this.view.$('.poll_progress_bar:first').css('width')).toBe(percentage+"%");
      expect(this.view.$(".percentage:first").text()).toBe(percentage + "%");
    })
  });

  describe("toggleResult", function(){
    it("toggles the progress bar and result", function(){
      expect(this.view.$('.poll_progress_bar_wrapper:first').css('display')).toBe("none");
      this.view.toggleResult(null);
      expect(this.view.$('.poll_progress_bar_wrapper:first').css('display')).toBe("block");
    })
  });

  describe("vote", function(){
    it("checks the ajax call for voting", function(){
      jasmine.Ajax.install();
      var answer = this.view.poll.poll_answers[0];
      var poll = this.view.poll;

      this.view.vote(answer.id);

      var obj = jasmine.Ajax.requests.mostRecent().params);
      expect(obj.poll_id).toBe(poll.poll_id);
      expect(obj.poll_answer_id).toBe(answer.id);
    })
  });

  describe("vote form", function(){
    it('show vote form when user is logged in and not voted before', function(){
      expect(this.view.$('form').length).toBe(1);
    });
    it('hide vote form when user voted before', function(){
      this.view.model.attributes.already_participated_in_poll = true;
      this.view.render();
      expect(this.view.$('form').length).toBe(0);
    });
    it("hide vote form when user not logged in", function(){
      logout();
      this.view.render();
      expect(this.view.$('form').length).toBe(0);
    });
  });
});
