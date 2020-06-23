<#
Description: Create a powershell script to deploy sql dacpac using sqlpackage.exe
#>

Function Execute-DeployDacpacPackage{
    param(
    [Parameter(Mandatory=$true)]
    [String]$SqlPackagePath,
    [Parameter(Mandatory=$true)]
    [String]$ConnectionString,
    [Parameter(Mandatory=$true)]
    [String]$DacpacFilePath
)
  Process{
        Try {

            $SqlPackagePath = Get-SqlPackagePath;
            IF (-not ($env:Path).Contains( $SqlPackagePath))
                { 
                    $env:path = $env:path + ";+$SqlPackagePath+;"
                }
                if([string]::IsNullOrEmpty(($ConnectionString)))
                    {
                        Write-Host "[ERROR]: No valid connection string provided in the input param." -BackgroundColor Red -ForegroundColor White
                        throw;
                    }
                Write-Host "[INFORMATION]: Starting deploying the dacpac file : $($DacpacFilePath) @ $($(Get-Date).ToUniversalTime()) UTC.";

                #deploy it to server
                & $SqlPackagePath /Action:Publish `
                                      /SourceFile:$DacpacFilePath `
                                      /TargetConnectionString:$ConnectionString `
            
                 Write-Host "[INFORMATION]: Successfully deploying the dacpac file : $($DacpacFilePath) @ $($(Get-Date).ToUniversalTime()) UTC.";

          }
        Catch {
            Write-Error $_.Exception.Message
        }
    }
} 