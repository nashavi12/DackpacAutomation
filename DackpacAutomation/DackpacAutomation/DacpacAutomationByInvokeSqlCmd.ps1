#
# DacpacAutomationByInvokeSqlCmd.ps1
#


#[Cmdletbinding()]
Function Execute-DeployDacpacPackage{
    param(
    [Parameter(Mandatory=$true)]
    [String]$ServerInstance,
    [Parameter(Mandatory=$true)]
    [String]$Database,    
    [Parameter(Mandatory=$true)]
    [String]$SqlFolder,
    [Parameter(Mandatory=$true)]
    [String]$WhereTheUnpackedVersionIs,
    [Parameter(Mandatory=$true)]
    [String]$whereToPutIt
)
    Process{
        $SqlFolder = ""
        $WhereTheUnpackedVersionIs= ""
        $whereToPutIt
        add-type -path "$env:programfiles (x86)\Microsoft SQL Server\140\DAC\bin\Microsoft.SqlServer.Dac.dll"

        $DacPackage = [Microsoft.SqlServer.Dac.DacPackage]::Load($whereToPutIt) 
        $DacPackage.unpack("$WhereTheUnpackedVersionIs")

        $scriptFile = Get-Item $PSCommandPath;
        Write-Output "$($scriptFile.Name) - Start"
        Try {
            Write-Output "Importing DevOps SQL module"
            Write-Output "Applying scripts to server instance '$ServerInstance' on database '$Database'"
            $sqlFiles = Get-ChildItem $SqlFolder -Filter *.sql | Sort-Object
            $totalSqlFilesFound = ($sqlFiles | Measure-Object).Count
            If ($totalSqlFilesFound -eq 0) {
                Write-Output "##vso[task.LogIssue type=warning;]Warning: no sql files found."
            }
            else {
                Write-Output "$($MyInvocation.MyCommand) - Start 1"
            $totalSqlFiles = ($SqlFiles | Measure-Object).Count
            Write-Output "Total sql files: $totalSqlFiles"
            $SqlFiles | Foreach-Object {
                $sqlFile = $_.FullName
                Write-Output "Processing file: $sqlFile"
                Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -InputFile $sqlFile
                Write-Output "Completed file:  $sqlFile"
            }
            Write-Output "$($MyInvocation.MyCommand) - End 1"
        }
    }
        Catch {
            Write-Output "##vso[task.LogIssue type=error;] $($scriptFile.Name)"
            Write-Output "##vso[task.LogIssue type=error;] Script Path: $($scriptFile.FullName)"
            Write-Output "##vso[task.LogIssue type=error;] $_"
            Write-Output "##vso[task.LogIssue type=error;] $($_.ScriptStackTrace)"
            Exit 1
        }
        Write-Output "$($scriptFile.Name) - End"
    }
} 