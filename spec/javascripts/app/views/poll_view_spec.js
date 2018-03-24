describe("app.views.Poll", function(){
  beforeEach(function() {
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
    this.view = new app.views.Poll({ model: factory.postWithPoll()});
    spec.content().html(this.view.render().el);
  });

  describe("setProgressBar", function(){
    it("sets the progress bar according to the voting result", function(){
      var percentage = (this.view.poll.poll_answers[0].vote_count / this.view.poll.participation_count)*100;
      expect(this.view.$(".progress-bar:first").css("width")).toBe(percentage + "%");
      expect(this.view.$(".percentage:first").text()).toBe(percentage + "%");
    });
  });

  describe("toggleResult", function(){
    it("toggles the progress bar and result", function(){
      expect($(".progress:first")).toBeHidden();
      this.view.toggleResult();
      expect($(".progress:first")).toBeVisible();
    });
  });

  describe("vote", function(){
    it("checks the ajax call for voting", function(){
      var answer = this.view.poll.poll_answers[0];
      var poll = this.view.poll;

      this.view.vote(answer.id);

      var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
      expect(obj.poll_id).toBe(poll.poll_id);
      expect(obj.poll_answer_id).toBe(answer.id);
    });
  });

  describe("render", function() {
    it("escapes the poll question", function() {
      var question = "<script>alert(0);</script>";
      this.view.poll.question = question;
      this.view.render();
      expect(this.view.$(".poll-head strong").text()).toBe(question);
    });
  });

  describe("reshared post", function(){
    beforeEach(function(){
      this.view.model.attributes.post_type = "Reshare";
      this.view.model.attributes.root = {id: 1};
      this.view.render();
    });

    it("hides the vote form", function(){
      expect(this.view.$('form').length).toBe(0);
    });

    it("shows a.root_post_link", function(){
      var id = this.view.model.get('root').id;
      expect(this.view.$('a.root_post_link').attr('href')).toBe('/posts/'+id);
    });
  });

  describe("vote form", function(){
    it("shows vote form when user is logged in and not voted before", function(){
      expect(this.view.$('form').length).toBe(1);
    });
    it("hides vote form when user voted before", function(){
      this.view.model.set("poll_participation_answer_id", this.view.poll.poll_answers[0].id);
      this.view.render();
      expect(this.view.$('form').length).toBe(0);
    });
    it("hides vote form when user not logged in", function(){
      logout();
      this.view.render();
      expect(this.view.$('form').length).toBe(0);
    });
  });

  describe("answer given", function() {
    it("adds 'users-vote' class to progress bar for the option the user voted for", function() {
      var answer = this.view.poll.poll_answers[0];
      this.view.model.set("poll_participation_answer_id", answer.id);
      expect(this.view.$(".progress-bar.users-vote").length).toBe(1);
    });

    it("doesn't add 'users-vote' class to progress bar of the options the user didn't vote for", function() {
      var answer1 = this.view.poll.poll_answers[0];
      var answer2 = this.view.poll.poll_answers[1];
      this.view.model.set("poll_participation_answer_id", answer1.id);
      expect(this.view.$(".progress-bar[data-answerid='" + answer2.id + "']").hasClass("users-vote")).toBe(false);
    });

    it("adds label next to the answer the user voted for", function() {
      var answer = this.view.poll.poll_answers[0];
      this.view.model.set("poll_participation_answer_id", answer.id);
      expect(this.view.$(".label.label-primary").length).toBe(1);
    });
  });
});
