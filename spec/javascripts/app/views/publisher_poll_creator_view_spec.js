describe('app.views.PublisherPollCreator', function(){
  beforeEach(function(){
    this.view = new app.views.PublisherPollCreator();
    this.view.render();
    this.input_selector = '.poll-answer input';
  });
  describe('rendering', function(){
    it('should have question input', function(){
      expect(this.view.$('input[name=poll_question]')).toExist();
    });
    it('should have answerinput', function(){
      expect(this.view.$(this.input_selector)).toExist();
    });
  });
  describe('#addAnswerInput', function(){
    it('should add new answer input', function(){
      expect(this.view.$(this.input_selector).length).toBe(2);
      this.view.addAnswerInput();
      expect(this.view.$(this.input_selector).length).toBe(3);
    });
    it('should change input count', function(){
      this.view.addAnswerInput();
      expect(this.view.inputCount).toBe(3);
    });
  });
  describe('#removeAnswerInput', function(){
    it('remove answer input', function(){
      var input = this.view.$(this.input_selector).first();
      expect(this.view.$(this.input_selector).length).toBe(2);
      this.view.removeAnswerInput(input);
      expect(this.view.$(this.input_selector).length).toBe(1);
    });
  });
  describe('#clearInputs', function(){
    it('clear input', function(){
      this.view.$('input').val('Hello word');
      this.view.clearInputs();
      expect(this.view.$(this.input_selector).val()).toBe('');
    });
  });
  describe('#toggleRemoveAnswer', function(){
    var remove_btn = '.poll-answer .remove-answer';
    it('show remove button when answer input is greater 1', function(){
      this.view.addAnswerInput();
      expect(this.view.$(remove_btn).hasClass('active')).toBeFalsy;
    });
    it('hide remove button when is only one answer input', function(){
      var input = this.view.$(this.input_selector);

      this.view.addAnswerInput();
      this.view.removeAnswerInput(input);

      expect(this.view.$(remove_btn).hasClass('active')).toBeFalsy;
    });
  });
  describe('#validateInput', function(){
    it('should invalid blank value', function(){
      var input = this.view.$('input');
      input.val('  ');
      expect(this.view.validateInput(input)).toBeFalsy;
    });
  });
});
