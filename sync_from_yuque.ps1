#chcp 65001

function accepAllCookie {
    $reg="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    Set-ItemProperty -Path $reg -Name "1A10" -Value 0   #Accept all Cookies
}

function base64decode($string) {
    $bytes  = [System.Convert]::FromBase64String($string)
    $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
    return $decoded;
}

function decodeURI($string) {
    return [uri]::UnescapeDataString($string)
    #return [System.Web.HttpUtility]::UrlDecode($string)
}

# function getLocalFiles {
#     Get-ChildItem -Path "./" | ForEach-Object {$_.Name}
# }

# function countBy( $fileName ) {
#     (getLocalFiles | Where-Object {$_ -ilike "*"+ $fileName +"*"} | Measure-Object).Count
# }

function extactBase64StringFromHtmlContent( $htmlContent ) {
    $regex = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList "yuque-app-data.+?>([^<]+)";
    $match = $regex.Match($htmlContent);
    if($match.Success) {
        return $match.Groups[1].Value
    } else {
        throw "html invalid"
    }
}

function data2Json( $contentHtml ) {
    $contentHtml = extactBase64StringFromHtmlContent $contentHtml
    $contentHtml = base64decode $contentHtml
    $contentHtml = decodeURI $contentHtml
    return ConvertFrom-Json $contentHtml
}

function getContentFromYuQue {
    $webResponse = Invoke-WebRequest -Uri https://yuque.com/aspwebchh/suibi
    $contentHtml = $webResponse.Content
    data2Json $contentHtml
}

function getArticleIdList {
    $content = getContentFromYuQue
    $articleList = $content.book.toc_docs
    $result = $articleList | ForEach-Object {$_.slug}
    return $result
}

function getMarkdownContent($articleId , $bookId) {
    $t = [datetime]::Now.Ticks
    $markdownContentUrl = "https://yuque.com/api/docs/${articleId}?book_id=${bookId}&raw=true&t=${t}"
    $response = Invoke-WebRequest -Uri $markdownContentUrl
    $content = $response.Content
    $json = ConvertFrom-Json $content
    $title = $json.data.title
    $body =  $json.data.body
    return [System.Tuple]::Create($title, $body);
}

function saveItem( $articleId ) {
    $url = "https://yuque.com/aspwebchh/suibi/eeuv91/raw"
    $response = Invoke-WebRequest -Uri $url
    $contentHtml = $response.Content
    $json = data2Json $contentHtml
    $bookId = $json.book.id
    $markDownContent = getMarkdownContent $articleId $bookId
    $title = $markDownContent.Item1;
    $body = $markDownContent.Item2;
    $title = $title.Replace("/","").Replace("\","")
    $filePath = ".\yuque\${title}.md"
    $body | Out-File $filePath
    $title + " -- saved"
}

accepAllCookie

$articleIdList = getArticleIdList

foreach($articleId in $articleIdList) {
    saveItem $articleId 
}


