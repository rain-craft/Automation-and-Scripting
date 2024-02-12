#array of websites with threat intell
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules', 'https://rules.emergingthreats.net/blockrules/compromised-ips.txt') 

#loop through the URLS 
foreach($u in $drop_urls) {
    $temp = $u.split("/") #extracts filename

    $file_name = $temp[-1] #last element in array is filename

    if(Test-Path $file_name){ 
        continue
    }
    else{
        Invoke-WebRequest -Uri $u -OutFile $file_name #downloads rule list
    }

}

#array with filename
$input_paths = @('.\compromised-ips.txt','.\emerging-botcc.rules')

#extracts IP addresses
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

#appeds IP to temporary IP list
select-string -Path $input_paths -Pattern $regex_drop | `
 ForEach-Object { $_.Matches } | `
 ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
 Out-File -FilePath "ips-bad.tmp"

 #iptables 
 (Get-Content -Path ".\ips-bad.tmp") | % `
 { $_ -replace "^","iptables -A INPUT -s " -replace "$", " -j DROP"} | `
 Out-File -FilePath "iptables.bash"

 #windows firewall
 foreach($ip in Get-Content -Path ".\ips-bad.tmp") {
'netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS -' + $ip +'\" dir=in action=block remoteip=' +$ip | Out-File -FilePath "badips.netsh" -Append
 }
