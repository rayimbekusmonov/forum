@echo off
title Forum Live - Local Server
color 0A
echo.
echo  ============================================
echo   FORUM LIVE - Local HTTP Server
echo  ============================================
echo.
echo  Starting server on http://localhost:8080
echo  Opening browser automatically...
echo.
echo  Press Ctrl+C to stop the server.
echo  ============================================
echo.

:: Start browser after 1.5 seconds
start "" /B powershell -Command "Start-Sleep 2; Start-Process 'http://localhost:8080/index.html'"

:: Start PowerShell HTTP server (no install needed, built into Windows)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$listener = New-Object System.Net.HttpListener;" ^
  "$listener.Prefixes.Add('http://localhost:8080/');" ^
  "$listener.Start();" ^
  "Write-Host ' Server running at http://localhost:8080' -ForegroundColor Green;" ^
  "Write-Host ' Open: http://localhost:8080/index.html' -ForegroundColor Cyan;" ^
  "Write-Host '';" ^
  "$root = '%~dp0';" ^
  "while ($listener.IsListening) {" ^
    "try {" ^
      "$ctx = $listener.GetContext();" ^
      "$req = $ctx.Request; $res = $ctx.Response;" ^
      "$path = $req.Url.LocalPath.TrimStart('/');" ^
      "if ($path -eq '' -or $path -eq '/') { $path = 'index.html' };" ^
      "$file = Join-Path $root $path;" ^
      "if (Test-Path $file -PathType Leaf) {" ^
        "$ext = [System.IO.Path]::GetExtension($file).ToLower();" ^
        "$mime = switch ($ext) {" ^
          "'.html' { 'text/html; charset=utf-8' }" ^
          "'.css'  { 'text/css' }" ^
          "'.js'   { 'application/javascript' }" ^
          "'.png'  { 'image/png' }" ^
          "'.jpg'  { 'image/jpeg' }" ^
          "'.svg'  { 'image/svg+xml' }" ^
          "'.woff2'{ 'font/woff2' }" ^
          "default { 'application/octet-stream' }" ^
        "};" ^
        "$bytes = [System.IO.File]::ReadAllBytes($file);" ^
        "$res.ContentType = $mime;" ^
        "$res.ContentLength64 = $bytes.Length;" ^
        "$res.OutputStream.Write($bytes, 0, $bytes.Length);" ^
      "} else {" ^
        "$res.StatusCode = 404;" ^
        "$msg = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found');" ^
        "$res.OutputStream.Write($msg, 0, $msg.Length);" ^
      "};" ^
      "$res.OutputStream.Close();" ^
    "} catch {}" ^
  "};"

pause
