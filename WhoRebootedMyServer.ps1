#Built by Todd Palecek
#To check who rebooted server

#Define current computer name
#Leave as hostname to return current PC or change if want to evaluate different PC
$ServerName = hostname

#Print server being checked
print $ServerName

get-eventlog -logname system -computername $ServerName| where {$_.Source -eq 'USER32'} | select TimeGenerated, UserName
