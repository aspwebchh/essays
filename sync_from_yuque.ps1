#chcp 65001

function base64decode($string) {
    $bytes  = [System.Convert]::FromBase64String($string)
    $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
    return $decoded;
}

function decodeURI($string) {
    return [System.Web.HttpUtility]::UrlDecode($string)
}

function getLocalFiles {
    Get-ChildItem -Path "./" | ForEach-Object {$_.Name}
}

function countBy( $fileName ) {
    (getLocalFiles | Where-Object {$_ -ilike "*"+ $fileName +"*"} | Measure-Object).Count
}

function extactBase64StringFromHtmlContent( $htmlContent ) {
    $regex = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList "yuque-app-data.+?>([^<]+)";
    $match = $regex.Match($htmlContent);
    if($match.Success) {
        return $match.Groups[1].Value
    } else {
        throw "html invalid"
    }
}

function getContentFromYuQue {
    $webResponse = Invoke-WebRequest -Uri https://yuque.com/aspwebchh/suibi
    $contentHtml = $webResponse.Content
    $contentHtml = extactBase64StringFromHtmlContent $contentHtml
    $contentHtml = base64decode $contentHtml
    $contentHtml = decodeURI $contentHtml
    return ConvertFrom-Json $contentHtml
}

function getArticleIdList {
    $content = getContentFromYuQue
    $articleList = $content.book.toc_docs
    $result = $articleList | Select-Object {$_.slug}
    return $result
}

getArticleIdList

