## 0.2.10
* another speed improvement by only clearing cookies instead of closing browsers after each scenario (dewind)

## 0.2.9
* fixed memory leaks within the java process by clearing proxies (dewind)
* fixed syntax error when sending multiline lambdas (endor, langalex)

## 0.2.8

* removed separate development and continuous integration environments and replaced them with a single one (thilo)
* more webrat like step definitions (lupine)
* improve on stability issues (mattmatt)

## 0.2.7

* fixed RemoteBrowser#confirm called celerity remove_listener with invalid arguments
* extended communication protocol to be able to send procs as arguments and blocks
* default mail delivery method is now 'persistent', ActionMailer::Base.deliveries works again in features


## 0.2.5

* added javascript helper to make 'I wait for the AJAX call to finish' work reliably (langalex)

## Before that

Lots of important contributions from a bunch of people. check the commit logs.
