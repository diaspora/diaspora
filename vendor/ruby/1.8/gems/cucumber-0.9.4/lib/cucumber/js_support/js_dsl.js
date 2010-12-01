var CucumberJsDsl = {
  registerStepDefinition: function(regexp, func) {
    if(func == null) {
      jsLanguage.execute_step_definition(regexp);
    }
    else{
      jsLanguage.add_step_definition(regexp, func);
    }
  },

  registerTransform: function(regexp, func) {
    jsLanguage.register_js_transform(regexp, func);
  },

  beforeHook: function(tag_expressions_or_func, func) {
    CucumberJsDsl.__registerJsHook('before', tag_expressions_or_func, func);
  },

  afterHook: function(tag_expressions_or_func, func) {
    CucumberJsDsl.__registerJsHook('after', tag_expressions_or_func, func);
  },

  steps: function(step_names) {
    jsLanguage.steps(step_names, "UNKNOWN:0");
  },

  Table: function(raw_table) {
    //TODO: Create a ruby table and send it back for use in js world
  },

  world: function(files) {
    jsLanguage.world(files);
  },

  __registerJsHook: function(label, tag_expressions_or_func, func) {
    if(func != null) {
      var hook_func = func;
      var tag_expressions = tag_expressions_or_func;
    } else {
      var hook_func = tag_expressions_or_func;
      var tag_expressions = [];
    }
    jsLanguage.register_js_hook(label, tag_expressions, hook_func);
  }
}

var Given = CucumberJsDsl.registerStepDefinition;
var When = CucumberJsDsl.registerStepDefinition;
var Then = CucumberJsDsl.registerStepDefinition;

var Before = CucumberJsDsl.beforeHook;
var After = CucumberJsDsl.afterHook;
var Transform = CucumberJsDsl.registerTransform;

var World = CucumberJsDsl.world;

var steps = CucumberJsDsl.steps;