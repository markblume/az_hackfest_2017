
# $tenantName = (Get-Content -Path "tenantName.txt").Trim()
$tenantName = "christ"
$resourceGroupName="intershop1"

$useGermany = $false

if ($useGermany) {
	$location="Germany Central"
	$cloudStorageDomain = "core.cloudapi.de"
} else {
	$location="West Europe"
	$cloudStorageDomain = "core.windows.net"
}

# concat(parameters('tenantName'), variables('publicIPs').webportal)

$authorizedKeyFilename = "C:\Users\chgeuer\Java\keys\dcos.openssh.public"
$githubUser = "chgeuer"
$githubProject = "az_hackfest_2017"

$_ignore = & git commit -am "." -q
$branch =  & git rev-parse HEAD
$repositoryUrl = "https://raw.githubusercontent.com/$($githubUser)/$($githubProject)/$($branch)/"

Write-Host "Pusing to '$($repositoryUrl)'"
$_ignore = & git push origin master -q


$commonSettings = @{
	tenantName=$tenantName
	deploymentSku="small"
	adminUsername=$env:USERNAME.ToLower()
	adminSecureShellKey=$(Get-Content -Path $authorizedKeyFilename).Trim()
#	repositoryUrl=$repositoryUrl
}

New-AzureRmResourceGroup `
 	-Name $resourceGroupName `
 	-Location $location `
	-Force

$deploymentResult = New-AzureRmResourceGroupDeployment `
	-ResourceGroupName $resourceGroupName `
	-TemplateUri "$($repositoryUrl)/clean.json" `
	-TemplateParameterObject $commonSettings `
	-Mode Incremental `
	-Force `
	-Verbose

Write-Host "Deployment to $($commonSettings['resourceGroupName']) is $($deploymentResult.ProvisioningState)"

# https://nocentdocent.wordpress.com/2015/09/24/deploying-azure-arm-templates-with-powershell/
