Param(
  [Parameter(Mandatory=$true)]
  [string]$serviceInstance,  
  [Parameter(Mandatory=$true)]
  [string]$database
)

#create database
Write-Host "Creating database..."

$srv = new-Object Microsoft.SqlServer.Management.Smo.Server($serviceInstance)
$db = New-Object Microsoft.SqlServer.Management.Smo.Database($srv, $database)
$db.Create()
Write-Host $db.CreateDate

# Execute sql initial script
pushd ..\lib\Test-databases
Invoke-sqlcmd -inputfile ".\roadkill-sqlserver.sql" -serverinstance $serviceInstance -database $database # the parameter -database can be omitted based on what your sql script does.
Write-Host "Database populated..."
popd

#Fill connectionString template and populates
pushd ..\lib\Configs

$newValue = '"Server=' + $serviceInstance + ';Integrated Security=true;Connect Timeout=5;database=' + $database + '"'
write-host $newValue

Copy-item '.\connectionStrings.config' '..\..\src\Roadkill.Web\connectionStrings.config'


(Get-Content '..\..\src\Roadkill.Web\connectionStrings.config') | Foreach-Object {$_ -replace '""', $newValue } | Set-Content '..\..\src\Roadkill.Web\connectionStrings.config'
Write-Host "Connectionstring created..."
popd