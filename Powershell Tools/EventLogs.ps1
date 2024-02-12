#path to save logs to
$myDir = "C:\Users\Username\EventLogs"

#list available logs to read
Get-EventLog -list

#ask the user which log they want to view
$readlog = Read-Host -Prompt "Please select a log to review from the list above"

#ask the user what string they want to search for in the log
$readmessage = Read-Host -Prompt "Please enter the keyword you would like to search"

#search in the specifed log for the string and save the results to a csv
Get-EventLog -LogName $readlog -Newest 100 | where {$_.Message -ilike "*$readmessage*" } | export-csv -NoTypeInfo -Path "$myDir\securitylogs.csv"
