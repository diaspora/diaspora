from py_dsl import *

@Given("^I ask python to calculate fibonacci up to (\d+)$")
def calc_fib_upto(n):
    print("CALCULATING FIB")
    #self.fib_result = fib.fib(n.to_i)
    
@Given("^it should give me (\[.*\])$")
def fib_should_be(n):
    print("COMPARING FIB")
    #self.fib_result = fib.fib(n.to_i)