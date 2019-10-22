#Built by Todd Palecek 1/8/16
#To Export relevant Event Log entries

#get-executionpolicy
#set-executionpolicy remotesigned

#set event records to evaluate (is based on total, not only those that qualify)
$RecordCount = 25000
$RecordCountSec = 5000

#create Documents folder if does not exist
$check = Test-Path -PathType Container "C:\Documents"
if($check -eq $false){
write-host "Creating Folder C:\Documents"
    New-Item 'C:\Documents' -type Directory
}


#Export Error and Warning event details
write-host "Processing Event Log Application"
get-eventlog -logname Application -newest $RecordCount | where {($_.ENtryType -eq 'Warning' -or $_.ENtryType -eq 'Error')} | export-csv c:\Documents\ELApplication.csv
write-host "Processing Event Log System"
get-eventlog -logname System -newest $RecordCount | where {($_.ENtryType -eq 'Warning' -or $_.ENtryType -eq 'Error')} | export-csv c:\Documents\ELSystem.csv
write-host "Processing Event Log Security Fail"
get-eventlog -logname Security -newest $RecordCount | where {($_.ENtryType -eq 'FailureAudit' -or $_.ENtryType -eq 'Error')} | export-csv c:\Documents\ELSecurityFail.csv
write-host "Processing Event Log Security"
get-eventlog -logname Security -newest $RecordCountSec | where {($_.ENtryType -eq 'FailureAudit' -or $_.ENtryType -eq 'Error')} | export-csv c:\Documents\ELSecurity.csv

#strip first line of file as it is gibberish
$file = "c:\Documents\ELApplication.csv"
(gc $file | select -Skip 1) | sc $file
$file = "c:\Documents\ELSystem.csv"
(gc $file | select -Skip 1) | sc $file
$file = "c:\Documents\ELSecurity.csv"
(gc $file | select -Skip 1) | sc $file
