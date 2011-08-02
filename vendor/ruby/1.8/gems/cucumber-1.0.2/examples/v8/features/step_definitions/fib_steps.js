Before(function(){
  fibResult = 0;
});

Before(['@do-fibonnacci-in-before-hook', '@reviewed'], function(){
  fibResult = fibonacciSeries(3);
});

After(function(){
  //throw 'Sabotage scenario';
});

Transform(/^(\d+)$/, function(n){
  return parseInt(n);
});

When(/^I ask Javascript to calculate fibonacci up to (\d+)$/, function(n){
  assertEqual(fibResult, 0);
  fibResult = fibonacciSeries(n);
});

When(/^I ask Javascript to calculate fibonacci up to (\d+) with formatting$/, function(n){
  assertEqual(0, fibResult)
  fibResult = fibonacciSeriesFormatted(n);
});

Then(/^it should give me (\[.*\])$/, function(expectedResult){
  assertEqual(expectedResult, fibResult)
});

Then(/^it should give me:$/, function(string){
  assertEqual(string, fibResult);
});

Then(/^it should contain:$/, function(table){
  var hashes = table.hashes;
  assertMatches(hashes[0]['cell 1'], fibResult);
  assertMatches(hashes[0]['cell 2'], fibResult);
});

Then(/^it should give me (\[.*\]) via calling another step definition$/, function(expectedResult){
  Given("I ask Javascript to calculate fibonacci up to 2");
  assertEqual(expectedResult, fibResult);
});

Then(/^it should calculate fibonacci up to (\d+) giving me (\[.*\])/, function(n, expectedResult){
  steps("Given I ask Javascript to calculate fibonacci up to "+ n + "\n" +
        "Then it should give me "+ expectedResult);
});