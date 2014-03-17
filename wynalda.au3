#include "file.au3"

Func getFileNameWithExtension($file)
	dim $drive, $dir, $filename, $ext
	_PathSplit($file,$drive, $dir, $filename, $ext)
	Return $filename & $ext
EndFunc

Func isValidValue($value, $limit)
	if ( $value < 0 OR $value > $limit ) then
		return False
	EndIf
	return true
EndFunc

Func writeCodesToInkjetFile($inputFile, $inkjetFile, $firstCode, $lastCode, $breakPoint)

	For $index = $firstCode to $lastCode Step 1
		FileWriteLine($inkjetFile, FileReadLine($inputFile, $index))
		if (mod( $index, $breakpoint ) = 0 ) then
			FileWriteLine($inkjetFile, "********")
		Else
			FileWriteLine($inkjetFile, "")
		EndIf

	next

EndFunc
