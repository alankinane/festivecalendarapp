#Get RSS feed from blog
$rssfeed = [xml](Invoke-WebRequest "https://azurealan.ie/feed/" -UseBasicParsing) 

$ResourceGroupName = "azurealancalendar"
$StorageAccountName = "azurealanblogs"
$AzureTableName = "blogs"
 
#Get Storage Account variables for blog posts
$saContext = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context
$cloudTable = (Get-AzStorageTable -Name $AzureTableName -Context $saContext).CloudTable

$blogItem = 1

#Loop 31 time due to 31 days in the month of December
While ($blogItem -lt 32)
{
    #Get random blog post from RSS feed
    $blog = ($rssfeed.rss.channel.item) | Get-Random

    #Check if blog post has already been stored to table
    If(Get-AzTableRow -table $cloudTable | Where-Object URL -eq $blog.link) {

        #Blog item already exists in table so fetch another random post
        Write-Host "Duplicate - " $blog.title
    }
    else {

        #New blog post so add to table and move to next row
        Add-AzTableRow -table $cloudTable -partitionKey "BlogID"-rowKey $blogItem -property @{"Title"=$blog.title;"URL"=$blog.link}
        $blogItem++
   
    }
}