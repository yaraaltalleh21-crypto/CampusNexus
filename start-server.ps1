$port = 3000
$dir = $PSScriptRoot
if (-not $dir) { $dir = (Get-Location).Path }

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$port/"
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
} catch {
    $port = 3001
    $prefix = "http://localhost:$port/"
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($prefix)
    $listener.Start()
}

Write-Host ""
Write-Host "===========================================================" -ForegroundColor Green
Write-Host " Campus360 Web Application is running live!" -ForegroundColor Green
Write-Host " URL: $prefix" -ForegroundColor Cyan
Write-Host " Press Ctrl+C in this window to stop the server." -ForegroundColor Yellow
Write-Host "===========================================================" -ForegroundColor Green
Write-Host ""

Start-Process $prefix

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $rawPath = $request.Url.LocalPath.TrimStart('/')
        if (-not $rawPath -or $rawPath -eq "") {
            $rawPath = "index.html"
        }

        $filePath = Join-Path $dir $rawPath

        if (Test-Path -LiteralPath $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime = switch ($ext) {
                ".html" { "text/html; charset=utf-8" }
                ".htm"  { "text/html; charset=utf-8" }
                ".css"  { "text/css; charset=utf-8" }
                ".js"   { "application/javascript; charset=utf-8" }
                ".json" { "application/json; charset=utf-8" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".svg"  { "image/svg+xml" }
                Default { "application/octet-stream" }
            }
            $response.ContentType = $mime
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    } catch {
        # ignore abort on close
    }
}
