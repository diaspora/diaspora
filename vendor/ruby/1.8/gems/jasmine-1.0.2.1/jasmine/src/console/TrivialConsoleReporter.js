jasmine.TrivialConsoleReporter = function(print, doneCallback) {
  //inspired by mhevery's jasmine-node reporter
  //https://github.com/mhevery/jasmine-node
  
  doneCallback = doneCallback || function(){};
  
  var defaultColumnsPerLine = 50,
      ansi = { green: '\033[32m', red: '\033[31m', yellow: '\033[33m', none: '\033[0m' },
      language = { spec:"spec", expectation:"expectation", failure:"failure" };
  
  function coloredStr(color, str) { return ansi[color] + str + ansi.none; }
  
  function greenStr(str)  { return coloredStr("green", str); }
  function redStr(str)    { return coloredStr("red", str); }
  function yellowStr(str) { return coloredStr("yellow", str); }
  
  function newline()         { print("\n"); }
  function started()         { print("Started"); 
                               newline(); }

  function greenDot()        { print(greenStr(".")); }
  function redF()            { print(redStr("F")); }
  function yellowStar()      { print(yellowStr("*")); }
  
  function plural(str, count) { return count == 1 ? str : str + "s"; }
  
  function repeat(thing, times) { var arr = [];
                                  for(var i=0; i<times; i++) arr.push(thing);
                                  return arr;
                                }
  
  function indent(str, spaces) { var lines = str.split("\n");
                                 var newArr = [];
                                 for(var i=0; i<lines.length; i++) {
                                   newArr.push(repeat(" ", spaces).join("") + lines[i]);
                                 }
                                 return newArr.join("\n");
                               }
  
  function specFailureDetails(suiteDescription, specDescription, stackTraces)  { 
                               newline(); 
                               print(suiteDescription + " " + specDescription); 
                               newline();
                               for(var i=0; i<stackTraces.length; i++) {
                                 print(indent(stackTraces[i], 2));
                                 newline();
                               }
                             }
  function finished(elapsed)  { newline(); 
                                print("Finished in " + elapsed/1000 + " seconds"); }
  function summary(colorF, specs, expectations, failed)  { newline();
                                                         print(colorF(specs + " " + plural(language.spec, specs) + ", " +
                                                                      expectations + " " + plural(language.expectation, expectations) + ", " +
                                                                      failed + " " + plural(language.failure, failed))); 
                                                         newline();
                                                         newline(); }
  function greenSummary(specs, expectations, failed){ summary(greenStr, specs, expectations, failed); }
  function redSummary(specs, expectations, failed){ summary(redStr, specs, expectations, failed); }
  
  
  
  
  function lineEnder(columnsPerLine) {
    var columnsSoFar = 0;
    return function() {
      columnsSoFar += 1;
      if (columnsSoFar == columnsPerLine) {
        newline();
        columnsSoFar = 0;
      }
    };
  }

  function fullSuiteDescription(suite) {
    var fullDescription = suite.description;
    if (suite.parentSuite) fullDescription = fullSuiteDescription(suite.parentSuite) + " " + fullDescription ;
    return fullDescription;
  }
  
  var startNewLineIfNecessary = lineEnder(defaultColumnsPerLine);
  
  this.now = function() { return new Date().getTime(); };
  
  this.reportRunnerStarting = function() {
    this.runnerStartTime = this.now();
    started();
  };
  
  this.reportSpecStarting = function() { /* do nothing */ };
  
  this.reportSpecResults = function(spec) {
    var results = spec.results();
    if (results.skipped) {
      yellowStar();
    } else if (results.passed()) {
      greenDot();
    } else {
      redF();
    } 
    startNewLineIfNecessary();   
  };
  
  this.suiteResults = [];
  
  this.reportSuiteResults = function(suite) {
    var suiteResult = {
      description: fullSuiteDescription(suite),
      failedSpecResults: []
    };
    
    suite.results().items_.forEach(function(spec){
      if (spec.failedCount > 0 && spec.description) suiteResult.failedSpecResults.push(spec);
    });
    
    this.suiteResults.push(suiteResult);
  };
  
  function eachSpecFailure(suiteResults, callback) {
    for(var i=0; i<suiteResults.length; i++) {
      var suiteResult = suiteResults[i];
      for(var j=0; j<suiteResult.failedSpecResults.length; j++) {
        var failedSpecResult = suiteResult.failedSpecResults[j];
        var stackTraces = [];
        for(var k=0; k<failedSpecResult.items_.length; k++) stackTraces.push(failedSpecResult.items_[k].trace.stack);
        callback(suiteResult.description, failedSpecResult.description, stackTraces);
      }
    }
  }
  
  this.reportRunnerResults = function(runner) {
    newline();
    
    eachSpecFailure(this.suiteResults, function(suiteDescription, specDescription, stackTraces) {
      specFailureDetails(suiteDescription, specDescription, stackTraces);
    });
    
    finished(this.now() - this.runnerStartTime);
    
    var results = runner.results();
    var summaryFunction = results.failedCount === 0 ? greenSummary : redSummary;
    summaryFunction(results.items_.length, results.totalCount, results.failedCount);
    doneCallback(runner);
  };
};