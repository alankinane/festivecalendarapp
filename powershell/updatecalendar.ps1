#Install required PowerShell modules
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module Az.Resources, Az.Storage, AzTable -ErrorAction Stop
Import-Module AzTable

#Fetch new blog
$ResourceGroupName = "dry-run"
$StorageAccountName = "azurealanblogs"
$AzureTableName = "blogs"

$today = Get-Date

#Get Storage Context to add Blog URL/details to
$saContext = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context   
$TableContext = (Get-AzStorageTable -Name $AzureTableName -Context $saContext.Context).CloudTable

$post = Get-AzTableRow -table $TableContext | Where-Object RowKey -eq $today.day

$title = $post.title
$link = $post.url

$newday = Get-Date -Format("D")

Add-Content -Path ./calendar.html -Value "<b>$newday</b><br>"
Add-Content -Path ./calendar.html -Value "<a href=`"$link`" target=`"content_iframe`">$title</a><br><br><hr>"
