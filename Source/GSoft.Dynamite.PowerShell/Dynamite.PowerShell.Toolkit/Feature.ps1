#
# Module 'Dynamite.PowerShell.Toolkit'
# Generated by: GSoft, Team Dynamite.
# Generated on: 10/24/2013
# > GSoft & Dynamite : http://www.gsoft.com
# > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
# > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
#

<#
	.SYNOPSIS
		Toggle the features on a Farm level. 

	.DESCRIPTION
		Toggle the features on a Farm level. 

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
	.PARAMETER  xmlinput
		The path of a XML file (schema defines in NOTES)

	.PARAMETER  state
		$true = enable feature (if already enabled, feature will be disabled then re-enabled)
		$false = disable feature, if need be

	.EXAMPLE
		PS C:\> Initialize-DSPFarmFeatures "c:\features.xml" $true

	.INPUTS
		System.String,System.Boolean

	.NOTES
		Here is the XML schema
    
<Configuration>
	<Farm>
		<Feature GUID="12345678-350a-421b-bd8a-0b688956f183" Name="Farm level feature"/>
		<WebApplications>
			<WebApplication Url="http://myServer">
				<Feature GUID="12345678-350a-421b-bd8a-0b688956f183" Name="Web Application level feature"/>
				<Sites>
					<Site Url="http://myServer/mySiteCollection">
						<Feature GUID="12345678-350a-421b-bd8a-0b688956f183" Name="My first feature"/>
						<Feature GUID="12345678-a710-473a-af3c-08d49ad2e0b4" Name="My second feature"/>
						<Webs>
							<AllWebs>
								<Feature GUID="12345678-566b-4233-ad7b-722518a94170" Name="My third feature"/>
							</AllWebs>
						</Webs>
					</Site>
				</Sites>
			<WebApplication>
		</WebApplications>
	</Farm>
</Configuration>
    
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
function Initialize-DSPFarmFeatures()
{
	Param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[xml]$xmlinput,
		
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		$state
	)

	Write "Process farm features..."
	Initialize-DSPFeatures $xmlinput.Configuration.Farm "" $state
}

<#
	.SYNOPSIS
		Toggle the features on a web application level. 

	.DESCRIPTION
		Toggle the features on a web application level. 

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
	.PARAMETER  xmlinput
		The path of a XML file (schema defines in NOTES)

	.PARAMETER  state
		$true = enable feature (if already enabled, feature will be disabled then re-enabled)
		$false = disable feature, if need be

	.EXAMPLE
		PS C:\> Initialize-DSPSiteCollectionsFeatures "c:\features.xml" $true

	.INPUTS
		System.String,System.Boolean

	.NOTES
		Here is the XML schema
    
<Configuration>
  <Sites>
    <Site Url="http://myServer/mySiteCollection">
      <Feature GUID="12345678-350a-421b-bd8a-0b688956f183" Name="My first feature"/>
      <Feature GUID="12345678-a710-473a-af3c-08d49ad2e0b4" Name="My second feature"/>
      <Webs>
        <AllWebs>
          <Feature GUID="12345678-566b-4233-ad7b-722518a94170" Name="My third feature"/>
        </AllWebs>
      </Webs>
    </Site>
  </Sites>
</Configuration>
    
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
function Initialize-DSPWebApplicationFeatures()
{
	Param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[xml]$xmlinput,
		
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		$state
	)

	Write "Process web application features..."
	foreach ($webApp in $xmlinput.SelectNodes("//WebApplication"))
	{
		$webAppUrl = $webApp.Url
		$spWebApp = Get-SPWebApplication -Identity $webApp.Url
		if($spWebApp -ne $null)
		{
			Initialize-DSPFeatures $webApp $webAppUrl $state
		}
		else
		{
		  Write-Warning "Web application $webAppUrl doesn't exist" 
		}
	}
}

<#
	.SYNOPSIS
		Toggle the features on a Site Collection level. 

	.DESCRIPTION
		Toggle the features on a Site Collection level. 

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
	.PARAMETER  xmlinput
		The path of a XML file (schema defines in NOTES)

	.PARAMETER  state
		$true = enable feature (if already enabled, feature will be disabled then re-enabled)
		$false = disable feature, if need be

	.EXAMPLE
		PS C:\> Initialize-DSPSiteCollectionsFeatures "c:\features.xml" $true

	.INPUTS
		System.String,System.Boolean

	.NOTES
		Here is the XML schema
    
<Configuration>
  <Sites>
    <Site Url="http://myServer/mySiteCollection">
      <Feature GUID="12345678-350a-421b-bd8a-0b688956f183" Name="My first feature"/>
      <Feature GUID="12345678-a710-473a-af3c-08d49ad2e0b4" Name="My second feature"/>
      <Webs>
        <AllWebs>
          <Feature GUID="12345678-566b-4233-ad7b-722518a94170" Name="My third feature"/>
        </AllWebs>
      </Webs>
    </Site>
  </Sites>
</Configuration>
    
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
function Initialize-DSPSiteCollectionsFeatures()
{
	Param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[xml]$xmlinput,
		
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		$state
	)

	Write "Process site collection features..."
	foreach ($Site in $xmlinput.SelectNodes("//Site"))
	{
		$SiteUrl = $Site.Url
		$spSite = Get-SPSite -Identity $Site.Url
		if($spSite -ne $null)
		{
			Initialize-DSPFeatures $Site $SiteUrl $state
		}
		else
		{
		  Write-Warning "Site collection $SiteUrl doesn't exist" 
		}
	}
}

<#
	.SYNOPSIS
		Toggle the features on a AllWebs (of a Site Collection) level. 

	.DESCRIPTION
		Toggle the features on a AllWebs (of a Site Collection) level. 

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
	.PARAMETER  xmlinput
		The path of a XML file (schema defines in NOTES)

	.PARAMETER  state
		$true = enable feature (if already enabled, feature will be disabled then re-enabled)
		$false = disable feature, if need be

	.EXAMPLE
		PS C:\> Initialize-DSPSiteAllWebsFeatures "c:\features.xml" $true

	.INPUTS
		System.String,System.Boolean

	.NOTES
		Here is the XML schema
    
<Configuration>
  <Sites>
    <Site Url="http://myServer/mySiteCollection">
      <Feature GUID="12345678-350a-421b-bd8a-0b688956f183" Name="My first feature"/>
      <Feature GUID="12345678-a710-473a-af3c-08d49ad2e0b4" Name="My second feature"/>
      <Webs>
        <AllWebs>
          <Feature GUID="12345678-566b-4233-ad7b-722518a94170" Name="My third feature"/>
        </AllWebs>
      </Webs>
    </Site>
  </Sites>
</Configuration>
    
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
Function Initialize-DSPSiteAllWebsFeatures()
{
	Param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[xml]$xmlinput,
		
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		$state
	)

 	Write "Process webs features..." 
	
	foreach ($Site in $xmlinput.SelectNodes("//Site"))
	{
		$SiteUrl = $Site.Url
		$spSite = Get-SPSite -Identity $Site.Url
		if($spSite -ne $null)
		{
		  # AllWebs
			foreach ($Feature in .Feature)
			{
				if(!($Feature.GUID -eq $null))
				{
					$FeatureName = $Feature.Name
					$WebUrl = $Web.Url
				
					foreach($Web in $spSite.AllWebs)
					{
					  Initialize-DSPFeatures $Site.Webs.AllWebs $Web.Url $state
					}
				}
			}     
		}
		else
		{
		  Write-Warning "Site collection $SiteUrl doesn't exist"
		}
	} 	
}

<#
	.SYNOPSIS
		Toggle the features on specific webs (of a Site Collection) level. 

	.DESCRIPTION
		Toggle the features on specific webs (of a Site Collection) level. 

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
	.PARAMETER  xmlinput
		The path of a XML file (schema defines in NOTES)

	.PARAMETER  state
		$true = enable feature (if already enabled, feature will be disabled then re-enabled)
		$false = disable feature, if need be

	.EXAMPLE
		PS C:\> Initialize-DSPSiteAllWebsFeatures "c:\features.xml" $true

	.INPUTS
		System.String,System.Boolean

	.NOTES
		Here is the XML schema
    
<Configuration>
  <Sites>
    <Site Url="http://myServer/mySiteCollection">
      <Feature GUID="12345678-350a-421b-bd8a-0b688956f183" Name="My first feature"/>
      <Feature GUID="12345678-a710-473a-af3c-08d49ad2e0b4" Name="My second feature"/>
      <Webs>
        <AllWebs>
          <Feature GUID="12345678-566b-4233-ad7b-722518a94170" Name="My third feature"/>
        </AllWebs>
      </Webs>
    </Site>
  </Sites>
</Configuration>
    
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
Function Initialize-DSPWebFeatures()
{

	Param(
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[xml]$xmlinput,
		
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		$state
	)
	
	Write "Process specific webs features..." 
	foreach ($Site in $xmlinput.SelectNodes("//Site"))
	{
		$SiteUrl = $Site.Url
		$spSite = Get-SPSite -Identity $Site.Url
		if($spSite -ne $null)
		{
		  foreach ($web in $Site.Webs.Web)
		  {
			$spWeb = Get-SPWeb $web.Url -ErrorAction SilentlyContinue
			$exists = ($spWeb) -ne $null
			
			if($exists -eq $true)
			{
			  Initialize-DSPFeatures $web $web.Url $state
			}
		  }     
		}
		else
		{
		  Write-Warning "Site collection $SiteUrl doesn't exist"
		}
	}
}

<#
	.SYNOPSIS
		Toggle the features on at a particular URL. 

	.DESCRIPTION
		Toggle the features on at a particular URL. The features's scope must be valid
		for the specified URL

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
	.PARAMETER  Xmlinput
		The path of a XML file (schema defines in NOTES)
		
	.PARAMETER  Url
		The url of the web/site collection/web application where to initialize the features.
		Empty string or missing parameter means Farm scope features.

	.PARAMETER  State
		$true = enable feature (if already enabled, feature will be disabled then re-enabled)
		$false = disable feature, if need be

	.EXAMPLE
		PS C:\> Initialize-DSPFeatures "c:\features.xml" "http://test.com"

	.INPUTS
		System.String,System.Boolean

	.NOTES
		Here is the XML schema
    
      <Feature GUID="12345678-350a-421b-bd8a-0b688956f183" Name="My first feature"/>
      <Feature GUID="12345678-a710-473a-af3c-08d49ad2e0b4" Name="My second feature"/>
    
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
function Initialize-DSPFeatures()
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=0)]
		[System.Xml.XmlElement]$Features,

		[Parameter(Mandatory=$false, Position=1)]
		$Url="",
		
		[Parameter(Mandatory=$false, Position=2)]
		$State=$true
	)
	
	foreach($Feature in $Features.Feature)
	{
		if(!($Feature.GUID -eq $null))
		{
			$FeatureName = $Feature.Name
			$Id = $Feature.GUID
			
			Initialize-DSPFeature $Id $Url $State $FeatureName
		}
   }
}

<#
	.SYNOPSIS
		Toggle the feature on at a particular URL. 

	.DESCRIPTION
		Toggle the feature on at a particular URL. The features's scope must be valid
		for the specified URL.
		If already enabled, a feature will be first disabled then re-enabled.

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
    
	.PARAMETER  Url
		Url of the web/site/web application on which to (re)enable the feature. Emtpy string
		or missing parameter means Farm scope feature.

	.PARAMETER  state
		$true = enable feature (if already enabled, feature will be disabled then re-enabled)
		$false = disable feature, if need be

	.EXAMPLE
		PS C:\> Initialize-DSPFeature "My.Package.NAmespace_My Feature Title" "http://test.com"

	.INPUTS
		System.String,System.Boolean
    
  .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
function Initialize-DSPFeature()
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=0)]
		$Id,

		[Parameter(Mandatory=$false, Position=1)]
		$Url="",
		
		[Parameter(Mandatory=$false, Position=2)]
		$State=$true,

		[Parameter(Mandatory=$false, Position=3)]
		$FeatureDisplayName
	)

	if ($FeatureDisplayName -eq $null)
	{
		$FeatureDisplayName = $Id
	}

	$isExistingWebFeature = (Get-SPFeature -Identity $Id -ErrorAction SilentlyContinue -Web $Url) -ne $null
	$isExistingSiteFeature = (Get-SPFeature -Identity $Id -ErrorAction SilentlyContinue -Site $Url) -ne $null
	$isExistingWebAppFeature = (Get-SPFeature -Identity $Id -ErrorAction SilentlyContinue -WebApplication $Url) -ne $null
	$isExistingFarmFeature = (Get-SPFeature -Identity $Id -ErrorAction SilentlyContinue -Farm) -ne $null

	$hasDisabled = $false;

	Write-Host "Enabling '$FeatureDisplayName' on '$Url'... " -NoNewLine
	$time = [Diagnostics.Stopwatch]::StartNew()
	
	# 1) Disable any already-enabled feature
	if($isExistingWebFeature -or $isExistingSiteFeature -or $isExistingWebAppFeature -or $isExistingFarmFeature)
	{
		Write-Host ""
		Write-Host "This feature is already activated, Disabling it..." -NoNewLine
		Disable-SPFeature -Identity $Id -URL $Url -Confirm:$false
		Write-Host "Done." -f Green  

		$hasDisabled = $true;
	} 			

	# 2) (Re)enable the feature
	if($State -eq $true)
	{
		$activationVerb = "Activating"
		if ($hasDisabled -eq $true)
		{
			$activationVerb = "Re-activating"
		}

		if (![string]::IsNullOrEmpty($Url))
		{
			Enable-SPFeature -Identity $Id -URL $Url
		}
		else
		{
			Enable-SPFeature -Identity $Id
		}

		# Finish the timer
		$time.Stop()
		$seconds = [math]::Ceiling([decimal]$time.Elapsed.TotalSeconds)	
		Write-Host "Done $activationVerb in $seconds sec." -f Green
	}
}