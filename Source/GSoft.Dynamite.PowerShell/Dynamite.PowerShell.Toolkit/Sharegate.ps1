
function Test-SharegateModule {

	# Check if Sharegate is installed
	if ((Get-Module | where { $_.Name -eq "Sharegate" }).Count -ne 1) {
		return $false
	}
	else
	{
		return $true
	}
}

<#
    .SYNOPSIS
		Import data into a site and subsites hierarchy using Sharegate.
	
    .DESCRIPTION
		Recursively import data from a folder hierarchy into a mirror site and subsites hierarchy. 
		The folder structure can be generated by using the feature "Export from SharePoint" from Sharegate

    --------------------------------------------------------------------------------------
    Module 'Dynamite.PowerShell.Toolkit'
    by: GSoft, Team Dynamite.
    > GSoft & Dynamite : http://www.gsoft.com
    > Dynamite Github : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    > Documentation : https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    --------------------------------------------------------------------------------------
		
    .PARAMETER FromFolder
	    [REQUIRED] The root folder path that contains data

    .PARAMETER ToUrl
	    [REQUIRED] The root folder URL to import to. Must be a mirror strucutre as the folder one

	.PARAMETER MappingSettings
	    [OPTIONAL] Specifies custom Sharegate property mappings like columns act as composite key and associations between source and destination.
		Note: applies on all lists and libraries found in the source folder.
		(See. http://help.share-gate.com/article/508-set-property-mapping-property-mapping-powershell for more information).

	.PARAMETER PropertyTemplate
	    [OPTIONAL] Specifies custom Sharegate property template like items status after copy (Published, Approved, etc.)
		Note: applies on all lists and libraries found in the source folder.
		(See. http://help.share-gate.com/article/501-new-property-template-copying-content-powershell for more information).

	.PARAMETER CopySettings
	    [OPTIONAL] Specifies custom Sharegate copy settings like items exist behavior, etc.)
		Note: applies on all lists and libraries found in the source folder.
	    (See. http://help.share-gate.com/article/479-new-copy-settings-general-powershell for more information).

	.PARAMETER LogFolder
		[REQUIRED] The log folder where create export reports

    .EXAMPLE
		    PS C:\> Import-Data -FromFolder "C:\Sharegate" -ToUrl "http://webapp/sites/test"

			PS C:\> Import-Data -FromFolder "C:\Sharegate" -ToUrl "http://webapp/sites/test" -Keys "ID","ContentType","MyCustomColumn"

			PS C:\> Import-Data -FromFolder "C:\Sharegate" -ToUrl "http://webapp/sites/test" -PropertyTemplate (New-PropertyTemplate -CheckInAs Publish) -CopySettings (New-CopySettings -OnContentItemExists Overwrite)

    .LINK
    GSoft, Team Dynamite on Github
    > https://github.com/GSoft-SharePoint
    
    Dynamite PowerShell Toolkit on Github
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit
    
    Documentation
    > https://github.com/GSoft-SharePoint/Dynamite-PowerShell-Toolkit/wiki
    
#>
function Import-DSPData {

	[CmdletBinding()]
	Param
	(
		[ValidateScript({Test-Path $_ -PathType 'Container'})] 
		[Parameter(Mandatory=$true)]
		[string]$FromFolder,

		[ValidateScript({(Get-SPWeb $_) -ne $null})]
		[Parameter(Mandatory=$true)]
		[string]$ToUrl,  

		[Parameter(Mandatory=$false)]
		$MappingSettings = (New-MappingSettings),

		[Parameter(Mandatory=$false)]
		$PropertyTemplate = (New-PropertyTemplate -CheckInAs Publish -ContentApproval Approved -VersionHistory -VersionLimit 5 -WebParts -NoLinkCorrection),

		[Parameter(Mandatory=$false)]
		$CopySettings = (New-CopySettings -OnContentItemExists Overwrite),

		[Parameter(Mandatory=$false)]
		[int]$ThreadNumber = 20,

        [Parameter(Mandatory=$true)]
		[string]$LogFolder
	)

    function Process-WebFolder {

        Param
	    (
            [Parameter(Mandatory=$true)]
		    [string]$WebUrl,

		    [Parameter(Mandatory=$true)]
		    [string]$WebFolder
	    )

        $Lists = New-Object System.Collections.ArrayList

        # Add a new entry for the web
        $Webs.Add($WebUrl, $null)

        $SubFolders = Get-ChildItem $WebFolder -Directory  

		$SubFolders | ForEach-Object {

            $CurrentFolder = $_
            $Title = $CurrentFolder.Name
		
            # Getting only subsites under the current web (first without name trimming)
            $AssociatedSubSites = Get-Subsite -Site (Connect-Site $WebUrl) -Name $Title

			if ($AssociatedSubSites -eq $null -and ($CurrentFolder.Name -match "[\s]*[\d]$"))
			{
				# If the current folder appears to be a duplicate incremented automatically by Sharegate
				$Title = $CurrentFolder.Name -replace "[\s]*[\d]$"
				
				# Getting only subsites under the current web (with name trimming)
				$AssociatedSubSites = Get-Subsite -Site (Connect-Site $WebUrl) -Name $Title
			}
           
            if ($AssociatedSubSites)
            {
                # Get the first web which is not already in the web collection. Theoretically, it should be the same order as Sharegate export
                $AssociatedWeb = $AssociatedSubSites | Where-Object { $Webs.Get_Item($_.Address.AbsoluteUri) -eq $null } | Select-Object -First 1

                $FolderUrl = $CurrentFolder.FullName
                $WebFullUrl = $AssociatedWeb.Address

				Write-Host "Match " -NoNewline 
                Write-Host "'$Title' " -NoNewline -ForegroundColor Green
				Write-Host "with web " -NoNewline
				Write-Host "'$WebFullUrl'" -ForegroundColor Yellow
  
                Process-WebFolder -WebUrl $WebFullUrl -WebFolder $CurrentFolder.FullName 
            }
            else
            {
                $Lists.Add($_) | Out-Null
            }  
        }

        # Add lists for this web
        $Webs.Set_Item($WebUrl, $Lists) 
    }

	Try
	{	
		# Default log file for thread activities
		$ThreadLogFile = Join-Path $LogFolder -ChildPath "MigrationProcessingReport.log"

	    # Create log folder if doesn't exist
        if((Test-Path $LogFolder -PathType 'Container') -eq $false)
        {
            Write-Warning "Log folder $LogFolder doesn't exist. Creating..."            
            New-Item -Path $LogFolder -ItemType Directory -Force
        }  

        Start-SPAssignment -Global

        $Webs = @{} 

        Process-WebFolder -WebUrl $ToUrl -WebFolder $FromFolder

		# Process all webs 
        $Webs.Keys | Invoke-Parallel -ImportVariables -ImportModules -Throttle $ThreadNumber -LogFile $ThreadLogFile -ScriptBlock {
        
            $CurrentWeb = $_

            Write-Host "Processing " -NoNewline 
			Write-Host "'$CurrentWeb'" -ForegroundColor Green -NoNewline
			Write-Host "..." 

			# Process all lists
            $Webs.Item($_) | Invoke-Parallel -ImportVariables -ImportModules -Throttle $ThreadNumber -LogFile $ThreadLogFile -ScriptBlock {
            
                $ListName = $_.Name
                $SourceFolder = $_.FullName  
                      
				$ExcelFile = Get-ChildItem $SourceFolder -Include *.xlsx,*.xls -Recurse

                $Site = Connect-Site -Url $CurrentWeb
                $DestList = Get-List -Site $Site -Name $ListName
				
				Write-Host "`tProcessing list folder " -NoNewline 
				Write-Host "'$ListName'" -ForegroundColor Yellow -NoNewline
				Write-Host "..." 
				
                if ($DestList)
                {
					# Log file
                    $FileName = (($CurrentWeb.ToLower().Replace($ToUrl.ToLower(),[string]::Empty) -Replace "^.","") -Replace ".$","").Replace("/","_") + "_"+ $ListName
					if ($FileName.StartsWith("_"))
					{
						$FileName = $FileName.TrimStart("_")
					}

                    $ExportFilePath = Join-Path -Path $LogFolder -ChildPath  $FileName

                    $SessionId = ((Get-Date -Format "yyMMdd") + "-1")
      
                    if ($DestList.BaseType -eq "Document Library")
                    {
                        Write-Host "`t`tList '$ListName' found in web '$CurrentWeb'! Importing documents..."

						Import-Document -ExcelFilePath $ExcelFile.FullName -DestinationList $DestList -MappingSettings $MappingSettings -Template $PropertyTemplate -CopySettings $CopySettings | Export-Report -Path $ExportFilePath -Overwrite 						
                    }
                    else
                    {                       
                        # Get a fake list (not needed in the Copy-Content cmdlet because we use an Excel file but necessary for the cmdlet)
                        # To ensure Sharegate will not connect to this list, we have to get one where attachments are disabled (Sharegate hack)
                        # We get a list in the central admin root web to avoid the case where the current web does not contain any list.
                        $webApp = Get-SPWebApplication -IncludeCentralAdministration | Where-Object { $_.IsAdministrationWebApplication -eq $true }
			            $SrcList = Connect-Site -Url $webApp.Url  | Get-List | Where-Object {$_.BaseType -eq "List" -and $_.EnableAttachments -eq $false} | Select -First 1

                        Write-Host "`t`tList '$ListName' found! Importing list items..."

						Copy-Content -SourceList $SrcList -DestinationList $DestList -ExcelFilePath $ExcelFile.FullName -MappingSettings $MappingSettings -Template $PropertyTemplate -CopySettings $CopySettings | Export-Report -Path $ExportFilePath -Overwrite 
                    }
                }
				else
				{					
					    Write-Warning "`t`tList '$ListName' not found in web '$CurrentWeb'! Skipping..."
				}         
            }  
        }

        Stop-SPAssignment -Global
	}
	Catch
	{
		$ErrorMessage = $_.Exception.Message
        Throw $ErrorMessage
	}
}