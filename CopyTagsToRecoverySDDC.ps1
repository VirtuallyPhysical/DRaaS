Function CopyTags {
    param (
        [Parameter(Mandatory=$true)]
        [string] $LocalVC,

        [Parameter(Mandatory=$true)]
        [string] $RemoteVC,

        [Parameter(Mandatory=$true)]
        [string] $TagCategory
    )

    Write-host "Gathering a list of Tags & Categorys from $LocalVC" -ForegroundColor Yellow
    Write-host "Please note that this can take several minutes" -ForegroundColor Yellow

    $mytags = Get-TagAssignment -Category $TagCategory -server $LocalVC -ErrorAction SilentlyContinue | Select -ExpandProperty Entity | ForEach-Object {
        Get-VM $_.Name -server $LocalVC -ErrorAction SilentlyContinue | Get-TagAssignment | Select -ExpandProperty Tag
    } | Select-Object Name -Unique

    Write-host "Tag list created" -ForegroundColor Yellow

    $localCategories = Get-Tag ($mytags).Name | Select-Object Category -Unique

    Write-host "Category list created" -ForegroundColor Yellow

    Write-host "Creating Categories" -ForegroundColor Yellow

    foreach ($Category in $localCategories) {
        $catname = $Category.Category.Name
        if ((Get-TagCategory $catname -server $RemoteVC -ErrorAction SilentlyContinue) -eq $null) {
            Write-host "Creating Category $catname" -ForegroundColor Yellow
            New-TagCategory -Name $catname -server $RemoteVC
        } else {
            Write-host "Category $catname Already Exists" -ForegroundColor Green
        }
    }

    write-host "Category creation complete"  -ForegroundColor Yellow

    Write-host "Creating Tags" -ForegroundColor Yellow

    foreach ($tag in $mytags) {
        $tagname = $tag.Name
        $tagcategory = (Get-Tag -name $tagname -server $LocalVC).Category
        if ((Get-Tag -Name $tagname -server $RemoteVC -ErrorAction SilentlyContinue) -eq $null) {
            Write-host "Creating $tagname" -ForegroundColor Yellow
            Get-TagCategory -Name $tagcategory.Name -server $RemoteVC | New-Tag -Name $tagname
        } else {
            Write-host "Tag $tagname already exists" -ForegroundColor Green
        }
    }

    write-host "Tag creation complete"  -ForegroundColor Yellow
}
