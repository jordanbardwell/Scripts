function Get-DistributionGroupMembersRecursive
{
    [CmdletBinding()]
    Param (
    # Id of Distribution Group
    [Parameter(ValueFromPipeline=$true)]
    [string]
    $PrimarySmtpAddress
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
        Write-Host "Processing $PrimarySmtpAddress" -ForegroundColor Yellow
        # Get All Distribution Group Members
        $DistributionGroupMembers = Get-DistributionGroupMember -Identity $PrimarySmtpAddress -ResultSize Unlimited

        # Add UserMailBox Recipients Members to AllMembers
        $AllMembers = $DistributionGroupMembers | Where-Object{$_.RecipientType -eq 'UserMailBox'}

        # Check for Nested Distribution Groups
        if($DistributionGroupMembers | Where-Object{$_.RecipientType -like '*Group*'})
        {
            $DistributionGroupMembers | Where-Object{$_.RecipientType -like '*Group*'} | ForEach-Object {Get-DistributionGroupMembersRecursive -PrimarySmtpAddress $_.PrimarySmtpAddress}
        }
    }

    # Output Results
    end 
    {
        Return $AllMembers
    }
}
