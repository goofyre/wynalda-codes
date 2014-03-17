#include<string.au3>
#include<Array.au3>
#include<File.au3>

dim $listOfCodes[10000000]

if $CmdLine[0] <> "" then
	$wynaldaFile = $CmdLine[1] ; If file dragged onto app, use that as code file.
else
	$wynaldaFile = FileOpenDialog("Wynalda Code File","\\kciapp2\data\lists\wynalda\","All (*.*)|CSV or TXT (*.csv;*.txt)") ; prompt user for code file to use
EndIf

$jobnumber = InputBox("Job Number",$prompt & "Please enter the Job Number:",$jobnumber) ; Prompt user for total number of codes to place into the 1UP file.

$outfilepath = "\\kcimail2\inkjet\" & StringRight($jobnumber,5) & ".1UP"
$outfile = FileOpen($outfilepath,2) ; open the 1up file for writing, and create the file if it doesn't exist.

$spoilfilepath = "\\kcimail2\inkjet\" & StringRight($jobnumber,5) & "SP.1UP"
$spoilfile = FileOpen($spoilfilepath,2) ; open the 1up file for writing, and create the file if it doesn't exist.

_FileReadToArray($wynaldaFile,$listOfCodes) ; reads entire file, breaks the file into an array with each element broken by a CRLF
$totalCodes = $listOfCodes[0] ; the first element of the array returned from _FileReadToArray is the number of elements in the array
_ArrayDelete($listOfCodes,0) ; I remove that from the array so that the entire array is consistent.

$toPrint = InputBox("How Many to print?",$prompt & "How many of the " & $totalcodes & " would you like to put in the file?",$totalcodes - 2500) ; Prompt user for total number of codes to place into the 1UP file.
$toPrint = int($toPrint) ; convert toPrint from String to Integer.

$toSpoil = InputBox("How Many for Spoilage?",$prompt & "How many of the " & ($totalcodes - $toPrint) & " remaining codes, would you like to put in the spoilage file?",2500) ; Prompt user for total number of codes to place into the 1UP file.
$toSpoil = int($toSpoil) ; convert toSpoil from String to Integer.

$counter = 0 ; initialize a counter

$breakcount = InputBox("When to Break?","How many lines betweeen breaks?",8000) ; Prompt user to define the number at which to write the break
$breakcount = int($breakcount) ; convert toPrint from String to Integer.

$breakstring = "****************" ; define the break string

ProgressOn("Writing file","total lines to write : " & $toPrint) ; initialize a progress bar for the user

for $code in $listOfCodes ; for ... in ... next loop, for each $code in the array $listOfCodes do the following:
	FileWriteLine($outfile,$code) ; write the current $code to the 1UP file

	$Otherline = "" ; define the second line variable to an empty string

	if mod($counter,$breakcount) = $breakcount-1 Then ;if the counter is a multiple of $breakcount then $otherline=$breakstring
		$otherline = $breakstring
	EndIf

	$counter += 1 ; increment the counter

	FileWriteLine($outfile,$Otherline) ; write the $otherline to the 1UP file
	if ($counter = $toPrint) then ExitLoop ; stops the loop when we reach the number entered earlier into $toPrint.
	if (Mod($counter, 1000) = 0 ) then ProgressSet(($counter/$toPrint) * 100,$counter & " codes written") ; update the progress bar every 1000 codes, by dividing the $counter ( the number of codes looped through), by the total number of codes in the array, and multiply by 100
Next ; proceed to the next iteration

for $i = $toPrint to ($toPrint + $toSpoil)-1 Step 1 ; for ... in ... next loop, for each $code in the array $listOfCodes do the following:
	$code = $listOfCodes[$i]
	FileWriteLine($spoilfile,$code) ; write the current $code to the 1UP file

	$Otherline = "" ; define the second line variable to an empty string

	if mod($i,$breakcount) = $breakcount-1 Then ;if the counter is a multiple of $breakcount then $otherline=$breakstring
		$otherline = $breakstring
	EndIf

	FileWriteLine($spoilfile,$Otherline) ; write the $otherline to the 1UP file
	if (Mod($i, 100) = 0 ) then ProgressSet((($i-$toPrint)/$toSpoil) * 100,$counter & " Spoilage codes written") ; update the progress bar every 1000 codes, by dividing the $counter ( the number of codes looped through), by the total number of codes in the array, and multiply by 100
Next ; proceed to the next iteration

_PathSplit($wynaldafile,$path_drive,$path_folder,$path_file,$path_ext)
FileMove($wynaldafile,"\\kciapp1\DATA\LISTS\Wynalda\USED_CODES\" & $path_file & $path_ext)

$printout = FileOpen("c:\temp.txt",10)
FileWriteLine($printout,$jobnumber & " - Wynalda Codes Inkjet File Info")
FileWriteLine($printout,"Original Code File: "& $path_file & $path_ext)
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

ProgressOff() ; destroy the progressbar

fileclose($outfile) ; close the on 1up file
fileclose($spoilfile) ; close the on 1up file

Run("notepad.exe c:\temp.txt")