//The path is relative to the folder which contains the features folder
World(['lib/fibonacci.js']);

function assertEqual(expected, actual){
  if(expected != actual){
    throw 'Expected <' + expected + "> but got <" + actual + ">";
  }
}

function assertMatches(expected, actual){
  if(actual.indexOf(expected) == -1){
    throw 'Expected <' + expected + "> to contain <" + actual + "> but it did not";
  }
}