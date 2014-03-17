wynalda-codes
=============

Originally written as a procedural AutoIt script to properly format code file as 1UP inkjet files. We are currently rewritting the entire thing with TDD.

Testing Framework
-----------------

We are using the Micro AutoIt testing framework. 

Synatx example:

  $Local $testSuite = _testSuite_("TestResults","html")

  $Local $test = _test_("extract filename and extension from full path")

	$$test.step("simple file", $test.assertEquals(getFileNameWithExtension($file),"myfile.txt"))

	$$test.addToSuite($testSuite)
	$$test = 0
