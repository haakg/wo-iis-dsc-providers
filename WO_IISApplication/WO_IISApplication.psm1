Function Get-TargetResource
{
    # TODO: Add parameters here
    # Make sure to use the same parameters for
    # Get-TargetResource, Set-TargetResource, and Test-TargetResource
    param 
    (       
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PhysicalPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Site,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationPool,

        [string[]]$EnabledProtocols
    )
}

Function Set-TargetResource
{
   param 
    (       
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PhysicalPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Site,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationPool,

        [string[]]$EnabledProtocols
    )

    Try
    {
        $webApp = Get-WebApplication -Name $Name    
    }
    Catch
    {
        Write-Verbose "$($_.exception.message)"
    }
    if($Ensure -eq "Present")
    {
        if($webApp -eq $null)
        {
            Write-Verbose "Web application does not exist, creating..."
            Try
            {
                New-WebApplication -Site $Site -ApplicationPool $ApplicationPool -PhysicalPath $PhysicalPath -Name $Name
                if ($PSBoundParameters.ContainsKey('EnabledProtocols'))
                {
                    Set-ItemProperty IIS:\Sites\$Site\$Name -Name enabledProtocols -value $($EnabledProtocols -join ",")
                }
            }
            Catch
            {
                Write-Verbose "$($_.exception.message)"
            }
        }
        else
        {
            Write-Verbose "Exists!"
            if($PSBoundParameters.ContainsKey('ApplicationPool') -and $ApplicationPool -ne $webApp.applicationPool)
            {
                Set-ItemProperty IIS:\Sites\$Site\$Name -Name applicationPool -value $ApplicationPool
            }   
            if($PSBoundParameters.ContainsKey('PhysicalPath') -and $PhysicalPath -ne $webApp.physicalPath)
            {
                Set-ItemProperty IIS:\Sites\$Site\$Name -Name physicalPath -value $PhysicalPath
            }
            if($PSBoundParameters.ContainsKey('EnabledProtocols') -and $EnabledProtocols -ne $webApp.enabledProtocols)
            {
                Set-ItemProperty IIS:\Sites\$Site\$Name -Name enabledProtocols -value $($EnabledProtocols -join ",")
            }

        }

        
            

    }
    else
    {
        if($webApp -ne $null)
        {
            Remove-WebApplication -Name $Name -Site $Site
        }
    }
        

}

Function Test-TargetResource
{
    param 
    (       
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PhysicalPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Site,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationPool,

        [string[]]$EnabledProtocols
    )

    Try 
    {
        $webApp = Get-WebApplication -Name $Name    
    }
    Catch
    {
        Write-Verbose "$($_.exception.message)"
    }

    if($webApp -eq $null)
    {
        Write-Verbose "A web application with the provided name does not exist."
        if($Ensure -ieq "Absent")
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    Write-Verbose "A web application with the provided name exists. Validate separate properties."
    if($Ensure -ieq "Absent")
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('Name') -and $Name -ne $webApp.name)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('PhysicalPath') -and $PhysicalPath -ne $webApp.physicalPath)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('Site') -and $Site -ne $webApp.state)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('ApplicationPool') -and $ApplicationPool -ne $webApp.applicationPool)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('EnabledProtocols') -and $($EnabledProtocols -join ",") -ne $webApp.enabledProtocols)
    {
        return $false
    }

    Write-Verbose "All properties match."
    return $true

}