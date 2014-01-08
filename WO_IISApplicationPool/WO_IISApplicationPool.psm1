Function Get-TargetResource
{
    param
    (       
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [ValidateSet("Started", "Stopped")]
        [string]$state,

        [ValidateSet("v2.0", "v4.0")]
        [string]$managedRuntimeVersion,

        [bool]$enable32BitAppOnWin64,

        [ValidateSet("Integrated", "Classic")]
        [string]$managedPipelineMode,

        [int]$queueLength,
       
        [bool]$autoStart,

        [ValidateSet("OnDemand", "AlwaysRunning")]
        [string]$startMode,
        
        [ValidateSet("ApplicationPoolIdentity", "NetworkService", "LocalService", "LocalSystem", "SpecificUser")]
        [string]$identityType,

        [int]$idleTimeout,

        [ValidateSet("Terminate", "Suspend")]
        [string]$idleTimeoutAction,

        [bool]$loadUserProfile,

        [bool]$disallowOverlappingRotation,

        [bool]$disallowRotationOnConfigChange,

        [int]$privateMemory,

        [int]$time,

        [int]$requests,

        [int]$memory


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

        [ValidateSet("Started", "Stopped")]
        [string]$state,

        [ValidateSet("v2.0", "v4.0", "NoManagedCode")]
        [string]$managedRuntimeVersion,

        [bool]$enable32BitAppOnWin64,

        [ValidateSet("Integrated", "Classic")]
        [string]$managedPipelineMode,

        [int]$queueLength,
       
        [bool]$autoStart,

        [ValidateSet("OnDemand", "AlwaysRunning")]
        [string]$startMode,
        
        [ValidateSet("ApplicationPoolIdentity", "NetworkService", "LocalService", "LocalSystem", "SpecificUser")]
        [string]$identityType,

        [string]$username,

        [string]$password,

        [int]$idleTimeout,

        [ValidateSet("Terminate", "Suspend")]
        [string]$idleTimeoutAction,

        [bool]$loadUserProfile,

        [bool]$disallowOverlappingRotation,

        [bool]$disallowRotationOnConfigChange,

        [int]$privateMemory,

        [int]$time,

        [int]$requests,

        [int]$memory,

        [string]$schedule
    )
    if (Test-Path IIS:\AppPools\$Name)
    {
        $appPool = Get-ItemProperty IIS:\AppPools\$name
    }
    if($Ensure -eq "Present")
    {
        if($appPool -ne $null)
        {  
            $appPoolExists = $true
        }
        if(-not $appPoolExists)
        {
            $appPool = New-WebAppPool -Name $Name
        }
        if($PSBoundParameters.ContainsKey('managedRuntimeVersion') -and (-not $appPoolExists -or $managedRuntimeVersion -ne $appPool.managedRuntimeVersion))
        {
            if ($managedRuntimeVersion -eq "NoManagedCode") 
            {
                Set-ItemProperty IIS:\AppPools\$Name managedRuntimeVersion ""
            }
            else
            {
                Set-ItemProperty IIS:\AppPools\$Name managedRuntimeVersion $managedRuntimeVersion
            }
        }
        if($PSBoundParameters.ContainsKey('enable32BitAppOnWin64') -and (-not $appPoolExists -or $enable32BitAppOnWin64 -ne $appPool.enable32BitAppOnWin64))
        {
            Set-ItemProperty IIS:\AppPools\$Name enable32BitAppOnWin64 $enable32BitAppOnWin64
        }
        if($PSBoundParameters.ContainsKey('managedPipelineMode') -and (-not $appPoolExists -or $managedPipelineMode -ne $appPool.managedPipelineMode))
        {
            Set-ItemProperty IIS:\AppPools\$Name managedPipelineMode $managedPipelineMode
        }
        if($PSBoundParameters.ContainsKey('queueLength') -and (-not $appPoolExists -or $queueLength -ne $appPool.queueLength))
        {
            Set-ItemProperty IIS:\AppPools\$Name queueLength $queueLength
        }
        if($PSBoundParameters.ContainsKey('autoStart') -and (-not $appPoolExists -or $autoStart -ne $appPool.autoStart))
        {
            Set-ItemProperty IIS:\AppPools\$Name autoStart $autoStart
        }
        if($PSBoundParameters.ContainsKey('startMode') -and (-not $appPoolExists -or $startMode -ne $appPool.startMode))
        {
            Set-ItemProperty IIS:\AppPools\$Name startMode $startMode
        }
        if($PSBoundParameters.ContainsKey('identityType') -and (-not $appPoolExists -or $identityType -ne $appPool.processModel.identityType))
        {
            Set-ItemProperty IIS:\AppPools\$Name processModel.identityType $identityType
        }
        if($PSBoundParameters.ContainsKey('identityType') -and $identityType -eq "SpecificUser")
        {   
            Write-Verbose "identityType is Set to Specific User"
            if($PSBoundParameters.ContainsKey('username') -and $username -ne $appPool.processModel.userName)
            {
                Set-ItemProperty IIS:\AppPools\$Name processModel.userName $username
            }
            if($PSBoundParameters.ContainsKey('password') -and $password -ne $appPool.processModel.password)
            {
                Set-ItemProperty IIS:\AppPools\$Name processModel.password $password
            }
        }
        if($PSBoundParameters.ContainsKey('idleTimeout') -and (-not $appPoolExists -or $idleTimeout -ne $appPool.processModel.idleTimeout))
        {
            $idleTimeoutTS = New-TimeSpan -Minutes $idleTimeout
            Set-ItemProperty IIS:\AppPools\$Name processModel.idleTimeout $idleTimeoutTS
        }
        if($PSBoundParameters.ContainsKey('idleTimeoutAction') -and (-not $appPoolExists -or $idleTimeoutAction -ne $appPool.processModel.idleTimeoutAction))
        {
            Set-ItemProperty IIS:\AppPools\$Name processModel.idleTimeoutAction $idleTimeoutAction
        }
        if($PSBoundParameters.ContainsKey('loadUserProfile') -and (-not $appPoolExists -or $loadUserProfile -ne $appPool.processModel.loadUserProfile))
        {
            Set-ItemProperty IIS:\AppPools\$Name processModel.loadUserProfile $loadUserProfile
        }
        if($PSBoundParameters.ContainsKey('disallowOverlappingRotation') -and (-not $appPoolExists -or $disallowOverlappingRotation -ne $appPool.recycling.disallowOverlappingRotation))
        {
            Set-ItemProperty IIS:\AppPools\$Name recycling.disallowOverlappingRotation $disallowOverlappingRotation
        }
        if($PSBoundParameters.ContainsKey('disallowRotationOnConfigChange') -and (-not $appPoolExists -or $disallowRotationOnConfigChange -ne $appPool.recycling.disallowRotationOnConfigChange))
        {
            Set-ItemProperty IIS:\AppPools\$Name recycling.disallowRotationOnConfigChange $disallowRotationOnConfigChange
        }
        #if($PSBoundParameters.ContainsKey('schedule') -and (-not $appPoolExists -or $schedule.TimeOfDay -ne $appPool.recycling.periodicRestart.schedule.Collection.Value))
        #{
        #    Set-ItemProperty IIS:\AppPools\$Name recycling.periodicRestart.schedule -Value @{value=$($schedule.TimeOfDay)}
        #}
        if($PSBoundParameters.ContainsKey('schedule') -and $schedule -ieq "None")
        {
            Write-Host "Schedule is null"
            if ($appPool.recycling.periodicRestart.schedule.Collection.Value -ne $null)
            {
               Clear-ItemProperty IIS:\AppPools\$Name recycling.periodicRestart.schedule
            }
        }
        if($PSBoundParameters.ContainsKey('schedule') -and $schedule -ine "None")
        {
            
            Write-verbose "Setting Schedule to $schedule"
            $recTime = [datetime]$schedule
            Write-verbose "$schedule"
            Write-verbose "$($schedule.TimeOfDay)"
            if($recTime.TimeOfDay -ne $appPool.recycling.periodicRestart.schedule.Collection.Value)
            {
               Set-ItemProperty IIS:\AppPools\$Name recycling.periodicRestart.schedule -Value @{value=$($recTime.TimeOfDay)}
            }
        }
    }
    else
    {
        if($appPool -ne $null)
        {
            Remove-WebAppPool $Name
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

        [ValidateSet("Started", "Stopped")]
        [string]$state,

        [ValidateSet("v2.0", "v4.0", "NoManagedCode")]
        [string]$managedRuntimeVersion,

        [bool]$enable32BitAppOnWin64,

        [ValidateSet("Integrated", "Classic")]
        [string]$managedPipelineMode,

        [int]$queueLength,
       
        [bool]$autoStart,

        [ValidateSet("OnDemand", "AlwaysRunning")]
        [string]$startMode,
        
        [ValidateSet("ApplicationPoolIdentity", "NetworkService", "LocalService", "LocalSystem", "SpecificUser")]
        [string]$identityType,

        [string]$username,

        [string]$password,

        [int]$idleTimeout,

        [ValidateSet("Terminate", "Suspend")]
        [string]$idleTimeoutAction,

        [bool]$loadUserProfile,

        [bool]$disallowOverlappingRotation,

        [bool]$disallowRotationOnConfigChange,

        [int]$privateMemory,

        [int]$time,

        [int]$requests,

        [int]$memory,

        [string]$schedule
    )
    If (Test-Path IIS:\AppPools\$Name)
    {
        $appPool = Get-ItemProperty IIS:\AppPools\$name
    }
    if($appPool -eq $null)
    {
        if($Ensure -ieq "Absent")
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    if($Ensure -ieq "Absent")
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('Name') -and $Name -ne $appPool.name)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('state') -and $state -ne $appPool.state)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('managedRuntimeVersion'))
    { 
        if ($managedRuntimeVersion -eq "NoManagedCode" -and $appPool.managedRuntimeVersion -ne $null)
        {
            return $false
        }
        else
        {
            if ($managedRuntimeVersion -ne $appPool.managedRuntimeVersion)
            {
                return $false
            }
        }
    }
    if($PSBoundParameters.ContainsKey('enable32BitAppOnWin64') -and $enable32BitAppOnWin64 -ne $appPool.enable32BitAppOnWin64)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('managedPipelineMode') -and $managedPipelineMode -ne $appPool.managedPipelineMode)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('queueLength') -and $queueLength -ne $appPool.queueLength)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('autoStart') -and $autoStart -ne $appPool.autoStart)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('startMode') -and $startMode -ne $appPool.startMode)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('identityType') -and $identityType -ne $appPool.processModel.identityType)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('identityType') -and $identityType -eq "SpecificUser")
    {   
        Write-Verbose "identityType is Set to Specific User"
        if($PSBoundParameters.ContainsKey('username') -and $username -ne $appPool.processModel.userName)
        {
            return $false
        }
        if($PSBoundParameters.ContainsKey('password') -and $password -ne $appPool.processModel.password)
        {
            return $false
            Write-verbose "password doesn't match"
        }
    }
    if($PSBoundParameters.ContainsKey('idleTimeout') -and $idleTimeout -ne $appPool.processModel.idleTimeout)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('idleTimeoutAction') -and $idleTimeoutAction -ne $appPool.processModel.idleTimeoutAction)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('loadUserProfile') -and $loadUserProfile -ne $appPool.processModel.loadUserProfile)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('disallowOverlappingRotation') -and $disallowOverlappingRotation -ne $appPool.recycling.disallowOverlappingRotation)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('disallowRotationOnConfigChange') -and $disallowRotationOnConfigChange -ne $appPool.recycling.disallowRotationOnConfigChange)
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('schedule') -and $schedule -ieq "None")
    {
        
        Write-Verbose "Trying to set to Null because `$schedule is set to $schedule"
        if ($appPool.recycling.periodicRestart.schedule.Collection.Value -ne $null)
        {
            Write-Verbose "The app Pool was not set to Null, must Set"
            return $false
        }
    }
    if($PSBoundParameters.ContainsKey('schedule') -and $schedule -ine "None")
    {
        Write-verbose "Trying to Set a schedule to $schedule"
        $recTime = [datetime]$schedule
        Write-Verbose "$schedule"
        Write-Verbose "wanting to set to $($recTime.TimeOfDay.hours)"
        if($recTime.TimeOfDay -ne $appPool.recycling.periodicRestart.schedule.Collection.Value)
        {
            Write-verbose "have to set schedule"
            return $false
        }
    }
    return $true
}