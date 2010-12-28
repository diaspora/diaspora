var elements = new Array('header','footer','article','nav','section');

for(var element in elements) { document.createElement(elements[element]); }