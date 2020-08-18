$ZoneName = "dns.zone.here"
$NumberOfDaysBack = 15
$DateInThePast = (Get-Date).AddDays(-$NumberOfDaysBack)
# Provide record types separated by comma, variable can be left empty
$RecordTypes = "A,CNAME"
$RecordTypes = $RecordTypes.Split(',')
 
if([string]::IsNullOrEmpty($RecordTypes))
{
    $i = 0
    $RecordsArray = (Get-DnsServerResourceRecord -ZoneName $ZoneName |Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)})[0]
    $RecordsArray | Export-Csv -Path .\$(Get-Date -Format dd_MM_yyyy)_$ZoneName'_AllRecords'.csv -NoTypeInformation
    $RecordsCounter = $RecordsArray.Count
    $Acceptance = Read-Host -Prompt "Do you want to remove $RecordsCounter records from $ZoneName zone? (Y/N)"
    if(($Acceptance -eq 'y') -or ($Acceptance -eq 'yes'))
    {
        foreach($Record in $RecordsArray)
        {
            $i++
            Write-Progress -Activity "Removing stale records from $ZoneName zone" -Status "Percent complete" -PercentComplete (($i/$RecordsCounter)*100)
            Try
            {
                Remove-DnsServerResourceRecord -InputObject $Record -ZoneName $ZoneName -Force
            }
            Catch
            {
                $_.Exception.Message
            }
        }
    }
    else
    {
        Write-Host Removing of stale records from $ZoneName zone has been skipped by user 
    }
}
else
{
    foreach($RecordType in $RecordTypes)
    {
        $i = 0
        $RecordsArray = Get-DnsServerResourceRecord -ZoneName $ZoneName -RRType $RecordType |Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)}
        $RecordsArray | Export-Csv -Path .\$(Get-Date -Format dd_MM_yyyy)_$ZoneName'_RecordType_'$RecordType.csv -NoTypeInformation
        $RecordsCounter = $RecordsArray.Count
        $Acceptance = Read-Host -Prompt "Do you want to remove $RecordsCounter $RecordType records from $ZoneName zone? (Y/N)"
        if(($Acceptance -eq 'y') -or ($Acceptance -eq 'yes'))
        {
            foreach($Record in $RecordsArray)
            {
                $i++
                Write-Progress -Activity "Removing stale $RecordType records from $ZoneName zone" -Status "Percent complete" -PercentComplete (($i/$RecordsCounter)*100)
                Try
                {
                    Remove-DnsServerResourceRecord -InputObject $Record -ZoneName $ZoneName -Force
                }
                Catch
                {
                    $_.Exception.Message
                }
            }
        }
        else
        {
            Write-Host Removing of stale $RecordType records from $ZoneName zone has been skipped by user 
        }
         
    }
}
 
Write-Host Script has been completed
Write-Host All remove records have been exported to CSV files under path $env:TEMP