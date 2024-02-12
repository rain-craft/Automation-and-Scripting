$ipAddr = Read-Host -Prompt "What IP address would you like to connect to?" #gets the IP address
$uName = Read-Host -Prompt "What is the username?" #gets the username

New-SSHSession -ComputerName $ipAddr -Credential (Get-Credential $uName) #logs into the shh server 
