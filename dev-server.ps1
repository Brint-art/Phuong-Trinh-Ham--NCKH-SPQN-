# ============================================================
# dev-server.ps1 - Simple static server for Windows
# No Node.js/Python needed. Use to preview the UI while developing.
# Run:  powershell -ExecutionPolicy Bypass -File dev-server.ps1
# Note: this file does NOT run the API functions in api/ (AI trả bộ bài mẫu).
#       To run the API too, install Node.js and use "node server.js".
# ============================================================

param([int]$Port = 8899)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.ico'  = 'image/x-icon'
}

Write-Host "Ham so - static server running at http://localhost:$Port/ (Ctrl+C to stop)"

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.AbsolutePath
    # Không phục vụ file ẩn (.env, .env.local, .git...) — tránh lộ thông tin nhạy cảm
    if ($path.Split('/') | Where-Object { $_.StartsWith('.') }) {
      $ctx.Response.StatusCode = 404
      $msg = [System.Text.Encoding]::UTF8.GetBytes('404 - Not Found')
      $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
      $ctx.Response.Close()
      continue
    }
    if ($path -eq '/') { $path = '/index.html' }
    $file = Join-Path $root ($path.TrimStart('/').Replace('/', '\'))
    if ((Test-Path $file -PathType Leaf) -and (Split-Path $file -Resolve).StartsWith($root)) {
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      $ctx.Response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    else {
      $ctx.Response.StatusCode = 404
      $msg = [System.Text.Encoding]::UTF8.GetBytes('404 - Not Found')
      $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $ctx.Response.Close()
  }
}
finally {
  $listener.Stop()
}
