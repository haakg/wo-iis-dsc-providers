Function Get-TargetResource
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
        [string]$ApplicationPool,

        [int]$Id,

        [ValidateSet("Stopped", "Started")]
        [string]$State,
         
        [string[]]$EnabledProtocols,

        [int]$ConnectionTimeout
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
        [string]$ApplicationPool,

        [int]$Id,

        [ValidateSet("Stopped", "Started")]
        [string]$State,
         
        [string[]]$EnabledProtocols,

        [int]$ConnectionTimeout
    )
    Try
    {
        $webSite = Get-WebSite -Name $Name    
    }
    Catch
    {
        Write-Verbose "$($_.exception.message)"
    }
    if($Ensure -eq "Present")
    {
        if($webSite -eq $null)
        {  
            Write-Verbose "WebSite does not exist, creating..."
            Try 
            {
                if($PSBoundParameters.ContainsKey('Id'))
                {
                    New-WebSite -Name $Name -ApplicationPool $ApplicationPool -PhysicalPath $PhysicalPath -Id $Id
                }
                else
                {
                    New-WebSite -Name $Name -ApplicationPool $ApplicationPool -PhysicalPath $PhysicalPath
                }
                if ($PSBoundParameters.ContainsKey('EnabledProtocols'))
                {
                    Set-ItemProperty IIS:\Sites\$Name -Name enabledProtocols -value $($EnabledProtocols -join ",")
                }
                if ($PSBoundParameters.ContainsKey('ConnectionTimeout'))
                {
                    Set-WebConfigurationProperty "/system.applicationHost/sites/site[@name='$Name']/limits[1]" -name connectionTimeout -value (New-TimeSpan -sec $ConnectionTimeout)
                }
                if($PSBoundParameters.ContainsKey('State') -and ($State -ne $webSite.state))
                {
                    if ($state -eq "Started") {Start-Website -Name $Name}
                    if ($state -eq "Stopped") {Stop-Website -Name $Name}
                }  
            } 
            Catch
            {
                Write-Verbose "$($_.exception.message)"
            }
            Write-Verbose "Finished creating the requested WebSite!"
        }
        else 
        {
            Write-Verbose "The WebSite did Exist! Checking individual settings."
            if($PSBoundParameters.ContainsKey('ApplicationPool') -and ($ApplicationPool -ne $webSite.applicationPool))
            {
                Set-ItemProperty IIS:\Sites\$Name -Name applicationPool -value $ApplicationPool
            }
            if($PSBoundParameters.ContainsKey('PhysicalPath') -and ($PhysicalPath -ne $webSite.physicalPath))
            {
                Set-ItemProperty IIS:\Sites\$Name -Name physicalPath -value $PhysicalPath
            }
            if($PSBoundParameters.ContainsKey('Id') -and ($Id -ne $webSite.id))
            {
                if ($webSite.state -eq "Started") {
                    Stop-Website -Name $Name
                    Start-Sleep -Seconds 3
                }
                Set-ItemProperty IIS:\Sites\$Name -Name id -value $Id
                Start-Sleep -Seconds 2
                Write-Verbose "Starting WebSite Changed ID"
                Start-Website -Name $Name
            }
            if($PSBoundParameters.ContainsKey('EnabledProtocols') -and ($EnabledProtocols -ne $webSite.enabledProtocols))
            {
                Set-ItemProperty IIS:\Sites\$Name -Name enabledProtocols -value $($EnabledProtocols -join ",")
            }
            if($PSBoundParameters.ContainsKey('ConnectionTimeout') -and $ConnectionTimeout -ne (Get-webconfigurationproperty "/system.applicationHost/sites/site[@name='$Name']/limits[1]" -Name connectionTimeout.value).TotalSeconds )
            {
                Set-WebConfigurationProperty "/system.applicationHost/sites/site[@name='$Name']/limits[1]" -name connectionTimeout -value (New-TimeSpan -sec $ConnectionTimeout)
            }
            if($PSBoundParameters.ContainsKey('State') -and ($State -ne $webSite.state))
            {
                if ($state -eq "Started") {Start-Website -Name $Name;Write-Verbose "Starting WebSite!"}
                if ($state -eq "Stopped") {Stop-Website -Name $Name;Write-Verbose "Stopping WebSite!"}
            }  
        }
    } #End Ensure Set to Present
    else
    {
        if($webSite -ne $null)
        {
            Remove-Website $name
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
        [string]$ApplicationPool,

        [int]$Id,

        [ValidateSet("Stopped", "Started")]
        [string]$State,
         
        [string[]]$EnabledProtocols,

        [int]$ConnectionTimeout
    )

    Try 
    {
        $webSite = Get-WebSite -Name $Name    
    }
    Catch
    {
        Write-Verbose "$($_.exception.message)"
    }

    if($webSite -eq $null)
    {
        Write-Verbose "A website with the provided name does not exist."
        if($Ensure -ieq "Absent")
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    Write-Verbose "A website with the provided name exists. Validate separate properties."
    if($Ensure -ieq "Absent")
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('Name') -and $Name -ne $webSite.name)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('PhysicalPath') -and $PhysicalPath -ne $webSite.physicalPath)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('Id') -and $Id -ne $webSite.Id)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('ApplicationPool') -and $ApplicationPool -ne $webSite.applicationPool)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('Protocols')  -and $($protocols -join ",") -ne $webSite.enabledProtocols)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('State') -and $State -ne $webSite.state)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('ConnectionTimeout') -and $ConnectionTimeout -ne $webSite.limits.connectionTimeout.TotalSeconds)
    {
        return $false
    }

    Write-Verbose "All properties match."
    return $true
}