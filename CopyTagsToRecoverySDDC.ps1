Function CopyTags {
#Gatering list of Tags from local vCenter
$LocalVC = Read-Host "Please enter the FQDN of your local vCenter"
$RemoteVC = Read-Host "Please enter the FQDN of your Remote vCenter"
$TagCategory = Read-Host "Please enter the DR Tag Category Name"
	 Write-host "Gathering a list of Tags & Categorys from $LocalVC" -ForegroundColor Yellow
	 Write-host "Please note that this can take several minutes" -ForegroundColor Yellow
		$global:mytags = @()
		$global:mytags = @(
		$DRVMs = Get-TagAssignment -Category $TagCategory -server $LocalVC -ErrorAction SilentlyContinue | Select -ExpandProperty Entity 
	ForEach ($VM in $DRVMs)
		{Get-VM $VM.Name -server $LocalVC -ErrorAction SilentlyContinue | Get-TagAssignment | Select -ExpandProperty Tag
		}
)
#Write-host "List created" -ForegroundColor green
Write-host 
#Creating unique list of tags
$global:mytags = $global:mytags | Select-Object Name -Unique
Write-host "Tag list created" -ForegroundColor Yellow
Write-host 
#Creating unique list of categories 
$global:localCategories = @()
$global:localCategories = get-tag ($global:mytags).Name
$global:localCategories = $global:localCategories | Select-Object Category -Unique
Write-host "Category list created" -ForegroundColor Yellow
Write-host 
#Checking if category exists in remote SDDC & creating it
Write-host "Creating Categorys" -ForegroundColor yellow
ForEach ($Category in $global:localCategories)
{
$catname = ($Category | select -expandproperty category).Name
If ((get-tagcategory $Category.category -server $RemoteVC -ErrorAction SilentlyContinue) -eq $null)
			{ Write-host "Creating Category $catname" -ForegroundColor yellow
			  New-TagCategory -Name $Category.category -server $RemoteVC} 
		else 
			{ Write-host "Category $catname Already Exists" -ForegroundColor green}
}
write-host
write-host "Category creation complete"  -ForegroundColor Yellow
write-host

#Checking if tag exists in remote SDDC and creating it
Write-host "Creating Tags" -ForegroundColor yellow
ForEach ($tag in $global:mytags)
{
$tagname = $tag | select -expandproperty Name
$tagcategory = (get-tag -name $tag.Name -server $LocalVC).Category
If ((get-Tag -Name $tag.Name -server $RemoteVC -ErrorAction SilentlyContinue) -eq $null)
			{ Write-host "Creating $tagname" -ForegroundColor yellow
			  Get-TagCategory -Name $tagcategory.Name -server $RemoteVC | New-Tag -Name $tag.Name} 
		else 
			{ Write-host "Tag $tagname already exists" -ForegroundColor green}
}
write-host
write-host "Tag creation complete"  -ForegroundColor Yellow
write-host
}

CopyTags