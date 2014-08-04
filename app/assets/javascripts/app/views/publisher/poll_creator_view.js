app.views.PublisherPollCreator = app.views.Base.extend({
  templateName: "poll_creator",
  
  events: {
    'keypress input:last': 'addAnswer',
    'click .remove-answer': 'removeAnswer',
    'blur input': 'validate',
    'input input': 'validate'
  },

  postRenderTemplate: function(){
    this.$pollAnswers = this.$('.poll-answers');
    this.inputCount = 2;
    this.trigger('change');
    this.bind('publisher:sync', this.render, this);
  },

  addAnswer: function(evt){
    if (!$(evt.target).val()) {
      this.addAnswerInput();
    }
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
    this.trigger('change');
  },

  removeAnswerInput: function(input){
    input.parents('.poll-answer').remove();
    this.toggleRemoveAnswer();
  },

  removeLastAnswer: function (){
    var inputs = this.$pollAnswers.find('input');
    if(inputs.length > 2) {
      this.$el.find('.poll-answer:last').remove();
    }
  },

  toggleRemoveAnswer: function(){
    var inputs = this.$pollAnswers.find('input');
    if(inputs.length < 3){
      this.$('.remove-answer').removeClass('active');
    }
    else {
      this.$('.remove-answer').addClass('active');
    }
  },

  clearInputs: function(){
    this.$('input').val('');
  },

  validate: function(evt){
    var input = $(evt.target);
    this.validateInput(input);
    this.trigger('change');
  },

  validateInput: function(input){
    var wrapper = input.parents('.control-group');
    var isValid = this.isValidInput(input);

    if(isValid){
      wrapper.removeClass('error');
      return true;
    }
    else {
      wrapper.addClass('error');
      return false;
    }
  },

  isValidInput: function(input){
    return $.trim(input.val());
  },

  validatePoll: function() {
    var _this = this;
    _.each(this.$('input:visible'), function(input){
      _this.validateInput($(input));
    });
  },

  isValidPoll: function(){
    var _this = this;

    return _.every(this.$('input:visible'), function(input){
      if(_this.isValidInput($(input)))
        return true;
    });
  }

});
