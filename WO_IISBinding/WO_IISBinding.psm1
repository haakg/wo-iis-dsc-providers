Function Get-TargetResource
{
    param 
    (       
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Site,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Protocol,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BindingInfo,

        [string]$Certificate
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
        [string]$Site,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Protocol,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BindingInfo,

        [string]$Certificate
    )
    Write-Verbose "Made it!"
    Try
    {
        $webSite = Get-WebSite -Name $Name    
    }
    Catch
    {
        Write-Verbose "$($_.exception.message)"
    }
    foreach ($binding in $webSite.bindings.collection)
    {
        if ($binding.protocol -eq $Protocol -and $binding.bindingInformation -eq $BindingInfo)
        {
            $bindingMatch = $true   
        }
    }
    if($PSBoundParameters.ContainsKey('Certificate'))
    {
        $IPAddress = $BindingInfo.Split(":")[0]
        if ($IPAddress -eq "*")
        {
            $IPAddress = "0.0.0.0"
        }
        $Port = $BindingInfo.Split(":")[1]

        if(ls IIS:\SslBindings | ? {$_.Thumbprint -eq $Certificate -and $_.Port -eq $Port -and $_.IPAddress -eq $IPAddress})
        {
            $sslMatch = $true
        }
    }

    if($Ensure -eq "Present")
    {
        if($bindingMatch -ne $true)
        {
            New-ItemProperty IIS:\Sites\$site -Name Bindings -Value @{protocol="$Protocol";bindingInformation="$BindingInfo"}

        }
        if($PSBoundParameters.ContainsKey('Certificate'))
        {
            if($sslMatch -ne $true)
            {
                Get-Item Cert:\LocalMachine\My\$Certificate|New-Item "IIS:\SslBindings\$IPAddress!$Port"
            }
        }


    }
    else
    {
        Write-Verbose "Should be absent"
        if($bindingMatch -eq $true)
        {
            Remove-WebBinding -Name $Site -Protocol $Protocol -BindingInformation $BindingInfo
        }
        if($sslMatch -eq $true)
        {
            
            rm "IIS:\SslBindings\$IPAddress!$Port"
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
        [string]$Site,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Protocol,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BindingInfo,

        [string]$Certificate
    )

    Try 
    {
        $webSite = Get-WebSite -Name $Site    
    }
    Catch
    {
        Write-Verbose "$($_.exception.message)"
    }
    foreach ($binding in $webSite.bindings.collection)
    {
        if ($binding.protocol -eq $Protocol -and $binding.bindingInformation -eq $BindingInfo)
        {
            Write-Verbose "Found a matching Binding!"
            $bindingMatch = $true   
        }
        
    }
    if($PSBoundParameters.ContainsKey('Certificate'))
    {
        $IPAddress = $BindingInfo.Split(":")[0]
        if ($IPAddress -eq "*")
        {
            $IPAddress = "0.0.0.0"
        }
        $Port = $BindingInfo.Split(":")[1]

        Write-Verbose "IPAddress = $IPAddress"
        Write-Verbose "Port = $Port"
        Write-Verbose "Cert = $Certificate"
        
        if(ls IIS:\SslBindings | ? {$_.Thumbprint -eq $Certificate -and $_.Port -eq $Port -and $_.IPAddress -eq $IPAddress})
        {
            Write-Verbose "Found a matching SSL Binding!"
            $sslMatch = $true
        }
        
    }
    
    if ($Ensure -ieq "Present")
    {
        if ($bindingMatch -eq $true -and $sslMatch -eq $true)
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    if ($Ensure -ieq "Absent")
    {
        if ($bindingMatch -ne $true -and $sslMatch -ne $true)
        {
            return $true
        }
       
        else
        {
            return $false
        }
    }
    
    
    

}