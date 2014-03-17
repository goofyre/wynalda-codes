#include<string.au3>
#include<Array.au3>
#include<File.au3>
#include "wynaldaFunc.au3"



if $CmdLine[0] <> "" then
	$wynaldaFile = $CmdLine[1] ; If file dragged onto app, use that as code file.
else
	$wynaldaFile = FileOpenDialog("Wynalda Code File","\\kciapp2\data\lists\wynalda\","All (*.*)|CSV or TXT (*.csv;*.txt)") ; prompt user for code file to use
EndIf

$jobnumber = promptForValue("Please enter the Job Number:", "123456", "\\kcimail2\inkjet", "Job Number already exists, please try again", "jobNumberExistsIn", 0) ; Prompt user for total number of codes to place into the 1UP file.

$outfilepath = "\\kcimail2\inkjet\" & StringRight($jobnumber,5) & ".1UP"

$spoilfilepath = "\\kcimail2\inkjet\" & StringRight($jobnumber,5) & "SP.1UP"

dim $listOfCodes[2]
_FileReadToArray($wynaldaFile,$listOfCodes) ; reads entire file, breaks the file into an array with each element broken by a CRLF
$totalCodes = $listOfCodes[0] ; the first element of the array returned from _FileReadToArray is the number of elements in the array

$toPrint = promptForValue("How many of the " & $totalcodes & " would you like to put in the file?", $totalcodes - 2500, $totalcodes - 2500, "Invalid entry, please try again.") ; Prompt user for total number of codes to place into the 1UP file.
$toPrint = int($toPrint) ; convert toPrint from String to Integer.

$toSpoil = promptForValue("How many of the " & ($totalcodes - $toPrint) & " would you like to put in the file?", "2500", ($totalcodes - $toPrint), "Invalid entry, please try again.")
$toSpoil = int($toSpoil) ; convert toSpoil from String to Integer.

$breakcount = promptForValue("How often should breaks appear in the file?", "8000", "", "Invalid entry, please try again.")
$breakcount = int($breakcount) ; convert toPrint from String to Integer.

writeCodesToInkjetFile($wynaldaFile, $outfilepath, 1, $toPrint, $breakcount)
writeCodesToInkjetFile($wynaldaFile, $spoilfilepath, $toPrint + 1, $toSpoil, $breakcount)

FileMove($wynaldafile,"\\kciapp1\DATA\LISTS\Wynalda\USED_CODES\" & getFileNameWithExtension($wynaldaFile))

$printout = FileOpen("c:\temp.txt",10)
FileWriteLine($printout,$jobnumber & " - Wynalda Codes Inkjet File Info")
FileWriteLine($printout,"Original Code File: " & getFileNameWithExtension($wynaldaFile))
FileWriteLine($printout,"Original Number of Codes: "& $totalCodes)
FileWriteLine($printout,"")
FileWriteLine($printout,"Two line files with breaks every " & $breakcount & " codes:")
FileWriteLine($printout,"")
FileWriteLine($printout,"Inkjet File: "& StringRight($jobnumber,5) & ".1UP")
FileWriteLine($printout,"Contains: "& $toPrint & " codes")
FileWriteLine($printout,"")
FileWriteLine($printout,"Spoilage File: "& StringRight($jobnumber,5) & "SP.1UP")
FileWriteLine($printout,"Contains: "& $toSpoil & " Spoilage codes")
FileWriteLine($printout,"")
FileClose($Printout)

Run("notepad.exe c:\temp.txt")