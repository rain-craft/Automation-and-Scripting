#do while loop that continues until user quits  
  do{ 
    $logChoice = Read-Host -Prompt "Would you like to view [A]ll/[R]unning/[S]topped services or [Q]uit?" #check what services the user wants to view
    $logChoice=$logChoice.ToUpper() #capitalizes user input

    $inputs = @("A","S","R","Q") #array with all possible valid inputs
    if($inputs -match $logChoice){
        if($logChoice -match "^[Q]$") { 
        break #end the program #quits the program 
        }

        if($logChoice -match "^[A]$") {
            $all #show all logs
        }

        if($logChoice -match "^[S]$") {
            $stopped #show stopped logs
        }

        if($logChoice -match "^[R]$") {
            $running #show running logs
        }
    }
    else { #if the user did not enter a valid input, prompts them to
    Write-Host "Please enter a valid input"
    }
}while($logChoice -notmatch "^[qQ]$")
