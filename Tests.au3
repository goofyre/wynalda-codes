#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;License:
;	This script is distributed under the MIT License
;
;Author:
;	oscar.tejera
;
;Description:
;File test suite
#include "lib/micro.au3"
#include "wynaldaFunc.au3"

;Run suite
testSuite()

;Setup test suite
Func setUp()
	Global $file = @TempDir & "\myfile.txt"
	FileOpen($file,8)
	Global $inputFile = @TempDir & "\testCodeFile.txt"
	Global $inkjetFile = @TempDir & "\testInkjetFile.1UP"
	_FileCreate(@TempDir & "\12345.1up")
EndFunc

;Teardown test suite
Func tearDown()
	FileDelete($file)
	FileDelete($inkjetFile)
	FileDelete(@TempDir & "\12345.1up")
EndFunc

;TestSuite
Func testSuite()
	setUp()
		Local $testSuite = _testSuite_("TestResults","html")


		Local $test = _test_("extract filename and extension from full path")

		$test.step("simple file", $test.assertEquals(getFileNameWithExtension($file),"myfile.txt"))

		$test.addToSuite($testSuite)
		$test = 0


		Local $test = _test_("Is value valid")

		$test.step("provided value zero", $test.assertTrue(isValidValue(0,100)))
		$test.step("provided value exactly highest possible", $test.assertTrue(isValidValue(100,100)))
		$test.step("provided value valid value", $test.assertTrue(isValidValue(50,100)))
		$test.step("provided value negative", $test.assertFalse(isValidValue(-5,100)))
		$test.step("provided value too big", $test.assertFalse(isValidValue(200,100)))

		$test.addToSuite($testSuite)
		$test = 0


		Local $test = _test_("Two line 1UP file is valid")
		$firstCode = 1
		$lastCode = 100
		$breakPoint = 10
		writeCodesToInkjetFile($inputFile, $inkjetFile, $firstCode, $lastCode, $breakPoint)

		$test.step("First line of input file and inkjet file match", $test.assertEquals(fileReadLine($inputFile,1), fileReadLine($inkjetFile,1)))
		$test.step("Second line of inkjet is blank", $test.assertEquals("", fileReadLine($inkjetFile,2)))
		$test.step("Third line of inkjet is Equal to the second line of input file", $test.assertEquals(fileReadLine($inputFile,2), fileReadLine($inkjetFile,3)))
		$test.step("Break appears on line 20 [for $breakpoint = 10]", $test.assertEquals("********", fileReadLine($inkjetFile,20)))
		$test.step("Break appears every 20 lines [for $breakpoint = 10]", $test.assertEquals("********", fileReadLine($inkjetFile,40)))
		$test.step("Inkjet File only has the correct number of codes", $test.assertEquals(100 * 2, _FileCountLines($inkjetFile)))

		$test.addToSuite($testSuite)
		$test = 0


		Local $test = _test_("Job number check")

		$test.step("inkjet file of job number does not exist", $test.assertfalse(jobNumberExistsIn("12346",@TempDir)))
		$test.step("inkjet file of job number does exist", $test.asserttrue(jobNumberExistsIn("12345",@TempDir)))
		$test.step("when job number longer than 5 characters, inkjet file of right 5 characters only", $test.asserttrue(jobNumberExistsIn("012345",@TempDir)))
		$test.step("when job number longer than 5 characters, inkjet file of right 5 characters only", $test.assertfalse(jobNumberExistsIn("123456",@TempDir)))

		$test.addToSuite($testSuite)
		$test = 0


		$testSuite.stop()
	tearDown()
EndFunc






