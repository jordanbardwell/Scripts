function Get-DistributionGroupMembersRecursive
{
    [CmdletBinding()]
    Param (
    # Id of Distribution Group
    [Parameter(ValueFromPipeline=$true)]
    [string]
    $Id
    )

    # Validate Exchange Online is Connected
    begin 
    {
        if(Get-PSSession | ?{$_.State -eq 'Opened' -and $_.ConfigurationName -eq 'Microsoft.Exchange'})
        {

        }
        else 
        {
            try
            {
                Connect-ExchangeOnline
            }
            catch
            {
                Write-Host "Unable to connect to Exchange Online" -ForegroundColor Red
                Write-Error $_
            }    
        }
    }

    # Process Distribution Group
    process 
    {
        Write-Host "Processing $Id" -ForegroundColor Yellow
        # Get All Distribution Group Members
        $DistributionGroupMembers = Get-DistributionGroupMember -Identity $Id -ResultSize Unlimited

        # Add UserMailBox Recipients Members to AllMembers
        $AllMembers = $DistributionGroupMembers | Where-Object{$_.RecipientType -eq 'UserMailBox'}

        # Check for Nested Distribution Groups
        if($DistributionGroupMembers | Where-Object{$_.RecipientType -like '*Group*'})
        {
            $DistributionGroupMembers | Where-Object{$_.RecipientType -like '*Group*'} | ForEach-Object {Get-DistributionGroupMembersRecursive -Id $_.Id}
        }
    }

    # Output Results
    end 
    {
        Write-Host 'Processing Complete!' -ForegroundColor Green
        Return $AllMembers
    }
}
