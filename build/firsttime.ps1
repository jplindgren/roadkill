Param(
  [Parameter(Mandatory=$true)]
  [string]$serviceInstance,  
  [Parameter(Mandatory=$true)]
  [string]$database
)

# Loading Assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

#Vars
$error.clear()

function Successful-Step {
  process { Write-Host $_ -ForegroundColor green -BackgroundColor black }
}
function Error-Step {
  process { Write-Host $_ -ForegroundColor white -BackgroundColor red }
}

$iconSuccess = "[!]"
$iconError ="`a/!\ "


# Database Creation
try {
	Write-Host "`r`n> Creating database...`r`n"

	$srv = new-Object Microsoft.SqlServer.Management.Smo.Server($serviceInstance)
	$db = New-Object Microsoft.SqlServer.Management.Smo.Database($srv, $database)
	$db.Create()
	Write-Host $db.CreateDate
}

# DB creation Error
catch { "$iconError An error occured in $database database creation.`r`n" | Error-Step };

# DB creation Success
if (!$error) {
"$iconSuccess $database database created`r`n" | Successful-Step

	# Execute sql initial script
	try {
		pushd ..\lib\Test-databases
		Invoke-sqlcmd -inputfile ".\roadkill-sqlserver.sql" -serverinstance $serviceInstance -database $database # the parameter -database can be omitted based on what your sql script does.
		popd
		
	}
	
	# SQL initial script Fails
	catch {"$iconError Isn't possible to populate $database`r`n" | Error-Step };
	
	# SQL initial script Success
	if (!$error) {
		"$iconSuccess Database populated`r`n" | Successful-Step
		
		#Fill connectionString template and populates
		try {
			
			pushd ..\lib\Configs

			$newValue = '"Server=' + $serviceInstance + ';Integrated Security=true;Connect Timeout=5;database=' + $database + '"'
			write-host $newValue `r`n | Successful-Step

			Copy-item '.\connectionStrings.config' '..\..\src\Roadkill.Web\connectionStrings.config'


			(Get-Content '..\..\src\Roadkill.Web\connectionStrings.config') | Foreach-Object {$_ -replace '""', $newValue } | Set-Content '..\..\src\Roadkill.Web\connectionStrings.config'
			Write-Host "$iconSuccess connectionString created... `r`n" | Successful-Step
			popd
			
		}
		
		#Fill connectionString templatecreation error
		catch {"$iconError Isn't possible to create connectionString`r`n" | Error-Step };
			
		if (!$error) {
			"$iconSuccess connectionString created `n Open .sln now.`r`n" | Successful-Step | start ..\Roadkill.sln
		}
	}
}
#ii install.log