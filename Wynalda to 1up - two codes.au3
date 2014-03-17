#include<string.au3>
#include<Array.au3>
#include<File.au3>


dim $path_drive1,$path_folder1,$path_file1,$path_ext1
dim $path_drive2,$path_folder2,$path_file2,$path_ext2

dim $listOfCodes1[10000000]
dim $listOfCodes2[10000000]


$wynaldaFile1 = FileOpenDialog("Wynalda Code - TOP","g:\lists\wynalda\","CSV or TXT (*.csv;*.txt)|All (*.*)") ; prompt user for code file to use
$wynaldaFile2 = FileOpenDialog("Wynalda Code - BOTTOM","g:\lists\wynalda\","CSV or TXT (*.csv;*.txt)|All (*.*)") ; prompt user for code file to use

$continue = false
$jobnumber = ""
$prompt = ""
while Not $continue
	$jobnumber = InputBox("Job Number",$prompt & "Please enter the Job Number:",$jobnumber) ; Prompt user for total number of codes to place into the 1UP file.
	if Not FileExists("\\kcimail2\inkjet\" & StringRight($jobnumber,5) & ".1UP") then
		$continue = True
	else
		$prompt = "The Job Number entered already exists. " & @CRLF
	EndIf
WEnd

$outfilepath = "\\kcimail2\inkjet\" & StringRight($jobnumber,5) & ".1UP"
$outfile = FileOpen($outfilepath,2) ; open the 1up file for writing, and create the file if it doesn't exist.

$spoilfilepath = "\\kcimail2\inkjet\" & StringRight($jobnumber,5) & "SP.1UP"
$spoilfile = FileOpen($spoilfilepath,2) ; open the 1up file for writing, and create the file if it doesn't exist.

_FileReadToArray($wynaldaFile1,$listOfCodes1) ; reads entire file, breaks the file into an array with each element broken by a CRLF
$totalCodes1 = $listOfCodes1[0] ; the first element of the array returned from _FileReadToArray is the number of elements in the array
_ArrayDelete($listOfCodes1,0) ; I remove that from the array so that the entire array is consistent.

_FileReadToArray($wynaldaFile2,$listOfCodes2) ; reads entire file, breaks the file into an array with each element broken by a CRLF
$totalCodes2 = $listOfCodes2[0] ; the first element of the array returned from _FileReadToArray is the number of elements in the array
_ArrayDelete($listOfCodes2,0) ; I remove that from the array so that the entire array is consistent.

ConsoleWrite("File 1 : " & $totalcodes1 & @CRLF & "File 2 : " & $totalcodes2 & @CRLF)

$prompt = ""
$continue = false
While Not $continue
	$toPrint = InputBox("How Many to print?",$prompt & "How many of the " & $totalcodes1 & " would you like to put in the file?",$totalcodes1 - 2500) ; Prompt user for total number of codes to place into the 1UP file.
	$toPrint = int($toPrint) ; convert toPrint from String to Integer.
	if $toPrint > $totalcodes1 Then
		$continue = False
		$prompt = "To many codes requested, please try again." & @CRLF
	elseif $toPrint <= 0 Then
		$continue = False
		$prompt = "No codes requested, please try again." & @CRLF
	Else
		$continue = true
	EndIf
wend

$prompt = ""
$continue = false
While Not $continue
	$toSpoil = InputBox("How Many for Spoilage?",$prompt & "How many of the " & ($totalcodes1 - $toPrint) & " remaining codes, would you like to put in the spoilage file?",2500) ; Prompt user for total number of codes to place into the 1UP file.
	$toSpoil = int($toSpoil) ; convert toSpoil from String to Integer.
	if ($toSpoil + $toPrint) > $totalcodes1 Then
		$continue = False
		$prompt = "To many codes requested, please select a number less than or equal to " & ($totalcodes1 - $toPrint) & "." & @CRLF
	elseif $toSpoil < 0 Then
		$continue = False
		$prompt = "Negative spoilage requested, please try again." & @CRLF
	Else
		$continue = true
	EndIf
wend

$prompt = ""
$continue = false
While Not $continue
	$breakcount = InputBox("When to Break?","How many lines betweeen breaks?",8000) ; Prompt user to define the number at which to write the break
	$breakcount = int($breakcount) ; convert toPrint from String to Integer.
	if $breakcount <= 0 Then
		$continue = False
		$prompt = "Breaks at zero or less doesn't make sense, please try again." & @CRLF
	Else
		$continue = true
	EndIf
wend
$breakstring = "****************" ; define the break string

ProgressOn("Writing file","total lines to write : " & $toPrint) ; initialize a progress bar for the user

for $i = 0 to ($toPrint - 1) Step 1 ; for ... in ... next loop, for each $code in the array $listOfCodes do the following:
	$code1 = $listOfCodes1[$i]
	$code2 = $listOfCodes2[$i]
	FileWriteLine($outfile,$code1) ; write the current $code to the 1UP file
	FileWriteLine($outfile,$code2) ; write the current $code to the 1UP file

	$Otherline = "" ; define the second line variable to an empty string

	if mod($i,$breakcount) = $breakcount-1 Then ;if the counter is a multiple of $breakcount then $otherline=$breakstring
		$otherline = $breakstring
	EndIf

	FileWriteLine($outfile,$Otherline) ; write the $otherline to the 1UP file
	if (Mod($i, 1000) = 0 ) then ProgressSet(($i/$toPrint) * 100,$i & " codes written") ; update the progress bar every 1000 codes, by dividing the $counter ( the number of codes looped through), by the total number of codes in the array, and multiply by 100
Next ; proceed to the next iteration

for $i = $toPrint to ($toPrint + $toSpoil)-1 Step 1 ; for ... in ... next loop, for each $code in the array $listOfCodes do the following:
	$code1 = $listOfCodes1[$i]
	$code2 = $listOfCodes2[$i]
	FileWriteLine($spoilfile,$code1) ; write the current $code to the 1UP file
	FileWriteLine($spoilfile,$code2)
	$Otherline = "" ; define the second line variable to an empty string

	if mod($i,$breakcount) = $breakcount-1 Then ;if the counter is a multiple of $breakcount then $otherline=$breakstring
		$otherline = $breakstring
	EndIf

	FileWriteLine($spoilfile,$Otherline) ; write the $otherline to the 1UP file
	if (Mod($i, 100) = 0 ) then ProgressSet((($i-$toPrint)/$toSpoil) * 100,$i & " Spoilage codes written") ; update the progress bar every 1000 codes, by dividing the $counter ( the number of codes looped through), by the total number of codes in the array, and multiply by 100
Next ; proceed to the next iteration

_PathSplit($wynaldafile1,$path_drive1,$path_folder1,$path_file1,$path_ext1)
FileMove($wynaldafile1,"\\kciapp1\DATA\LISTS\Wynalda\USED_CODES\" & $path_file1 & $path_ext1)
_PathSplit($wynaldafile2,$path_drive2,$path_folder2,$path_file2,$path_ext2)
FileMove($wynaldafile2,"\\kciapp1\DATA\LISTS\Wynalda\USED_CODES\" & $path_file2 & $path_ext2)

$printout = FileOpen("c:\temp.txt",10)
FileWriteLine($printout,$jobnumber & " - Wynalda Codes Inkjet File Info")
FileWriteLine($printout,"Original TOP Code File: "& $path_file1 & $path_ext1)
FileWriteLine($printout,"Original Number of Codes: "& $totalCodes1)
FileWriteLine($printout,"")
FileWriteLine($printout,"Original BOTTOM Code File: "& $path_file2 & $path_ext2)
FileWriteLine($printout,"Original Number of Codes: "& $totalCodes2)
FileWriteLine($printout,"")
FileWriteLine($printout,"Three line files with breaks every " & $breakcount & " codes:")
FileWriteLine($printout,"TOP code on line 1")
FileWriteLine($printout,"BOTTOM code on line 2")
FileWriteLine($printout,"Breaks on line 3")
FileWriteLine($printout,"")
FileWriteLine($printout,"Inkjet File: "& StringRight($jobnumber,5) & ".1UP")
FileWriteLine($printout,"Contains: "& $toPrint & " codes x2")
FileWriteLine($printout,"")
FileWriteLine($printout,"Spoilage File: "& StringRight($jobnumber,5) & "SP.1UP")
FileWriteLine($printout,"Contains: "& $toSpoil & " Spoilage codes")
FileWriteLine($printout,"")
FileClose($Printout)

ProgressOff() ; destroy the progressbar

fileclose($outfile) ; close the on 1up file
fileclose($spoilfile) ; close the on 1up file

Run("notepad.exe c:\temp.txt")