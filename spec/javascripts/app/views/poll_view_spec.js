describe("app.views.Poll", function(){
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
    this.view = new app.views.Poll({ "model" : factory.postWithPoll()});
    this.view.render();
  });

  describe("setProgressBar", function(){
    it("sets the progress bar according to the voting result", function(){
      var percentage = (this.view.poll.poll_answers[0].vote_count / this.view.poll.participation_count)*100;
      expect(this.view.$('.poll_progress_bar:first').css('width')).toBe(this.view.progressBarFactor * percentage+"px");
      expect(this.view.$(".percentage:first").text()).toBe(" - " + percentage + "%");
    })
  });

  describe("toggleResult", function(){
    it("toggles the progress bar and result", function(){
      expect(this.view.$('.poll_progress_bar_wrapper:first').css('display')).toBe("none");
      this.view.toggleResult(null);
      expect(this.view.$('.poll_progress_bar_wrapper:first').css('display')).toBe("block");
    })
  });

  describe("updateCounter", function(){
    it("updates the counter after a vote", function(){
      var pc = this.view.poll.participation_count;
      var answerCount = this.view.poll.poll_answers[0].vote_count;
      this.view.updateCounter(1);
      expect(this.view.poll.participation_count).toBe(pc+1);
      expect(this.view.poll.poll_answers[0].vote_count).toBe(answerCount+1);
    })
  });

  describe("vote", function(){
    it("checks the ajax call for voting", function(){
      spyOn($, "ajax");
      var radio = this.view.$('input[name="vote"]:first');
      radio.attr('checked', true);
      this.view.vote({'target' : radio});
      var obj = JSON.parse($.ajax.mostRecentCall.args[0].data);
      expect(obj.poll_id).toBe(this.view.poll.poll_id);
      expect(obj.poll_answer_id).toBe(this.view.poll.poll_answers[0].id);
    })
  })
});
