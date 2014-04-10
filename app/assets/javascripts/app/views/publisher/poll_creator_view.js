app.views.PublisherPollCreator = app.views.Base.extend({
  templateName: "poll_creator",
  
  events: {
    'click .add-answer .button': 'clickAddAnswer',
    'click .remove-answer': 'removeAnswer',
  },

  postRenderTemplate: function(){
    this.$pollAnswers = this.$('.poll-answers');
    this.inputCount = 1;
  },
  
  clickAddAnswer: function(evt){
    evt.preventDefault();

    this.addAnswerInput();
  },
  
  addAnswerInput: function(){
    this.inputCount++;
    var input_wrapper = this.$('.poll-answer:first').clone();
    var input = input_wrapper.find('input');

    var text = Diaspora.I18n.t('publisher.option', {
      nr: this.inputCount
    });

    input.attr('placeholder', text);
    input.val('');
    this.$pollAnswers.append(input_wrapper);
    this.toggleRemoveAnswer();
  },

  removeAnswer: function(evt){
    evt.stopPropagation();
    this.removeAnswerInput(this.$(evt.target));
  },

  removeAnswerInput: function(input){
    input.parents('.poll-answer').remove();
    this.toggleRemoveAnswer();
  },

  toggleRemoveAnswer: function(){
    var inputs = this.$pollAnswers.find('input');
    if(inputs.length < 2){
      this.$('.remove-answer').removeClass('active');
    }
    else {
      this.$('.remove-answer').addClass('active');
    }
  },

  clearInputs: function(){
    this.$('input').val('');
  }

});
