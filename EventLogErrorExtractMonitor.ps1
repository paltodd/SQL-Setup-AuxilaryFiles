#Built by Todd Palecek 1/8/16
#To Export relevant Event Log entries

$env:computername

$name = -join("\\mk-ds02\MKC_Public\Information Technology\Database Admins\EventLogs\",$env:computername, "ELApplication.csv");

#Export Error and Warning event details
get-eventlog -logname Application -After (Get-Date).AddHours(-1) | where {($_.ENtryType -eq 'Warning' -or $_.ENtryType -eq 'Error')} | export-csv $name


#Get-EventLog Application -After (Get-Date).AddHours(-2)

#strip first line of file as it is gibberish
$file = $name
#$file = "\\mk-ds02\MKC_Public\Information Technology\Database Admins\EventLogs\AOS01ELApplication.csv"
(gc $file | select -Skip 1) | sc $file

