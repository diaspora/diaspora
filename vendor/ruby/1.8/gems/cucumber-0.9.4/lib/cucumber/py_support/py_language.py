import py_dsl

step_defs = {}

def register_step_def(regexp, f):
  print "Got a step def: ", regexp
  step_defs[regexp] = f
  
def step_matches(step_name, name_to_report):
  print "WTF: " + step_name