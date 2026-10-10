# ============================================================
# dev-server.ps1 — Máy chủ dev cho Windows: file tĩnh + 2 endpoint AI
# KHÔNG cần Node.js, KHÔNG cần Python, KHÔNG cần deploy lên Vercel.
# Chạy:  powershell -ExecutionPolicy Bypass -File dev-server.ps1
#        rồi mở http://localhost:3000/   (Ctrl+C để dừng)
#
# AI: script đọc MISTRAL_API_KEY (và MISTRAL_MODEL tùy chọn) từ biến môi
#     trường hoặc file .env.local / .env đặt cạnh script.
#     Chưa có key → endpoint vẫn trả 200 với bộ bài mẫu / câu trả lời minh
#     hoa, giống hệt hành vi của api/*.js khi chạy trên Vercel.
#
# Đây là bản mô phỏng api/ask-solution.js và api/generate-exercises.js phục
# vụ TEST GIAO DIỆN + LOGIC tại chỗ. Code thật để deploy vẫn là api/*.js.
# (Ghi chú: bản dev này bỏ qua rate-limit vì chỉ chạy trên máy của bạn.)
# ============================================================

param(
  [int]$Port = 3000,
  [string]$MistralKey = ''
)

$ProgressPreference = 'SilentlyContinue'   # bỏ progress bar của Invoke-WebRequest (kéo chậm hẳn)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------- Nạp biến môi trường từ .env.local / .env (tự làm, không cần thư viện) ----------
function Read-EnvFile([string]$file) {
  if (-not (Test-Path $file -PathType Leaf)) { return }
  foreach ($line in [System.IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8)) {
    if ($line -match '^\s*([A-Za-z0-9_]+)\s*=\s*(.*?)\s*$') {
      $name = $Matches[1]
      $value = $Matches[2].Trim('"', "'")
      if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name))) {
        [Environment]::SetEnvironmentVariable($name, $value)
      }
    }
  }
}
Read-EnvFile (Join-Path $root '.env.local')
Read-EnvFile (Join-Path $root '.env')

if ([string]::IsNullOrEmpty($MistralKey)) { $MistralKey = [Environment]::GetEnvironmentVariable('MISTRAL_API_KEY') }
$MistralModel = [Environment]::GetEnvironmentVariable('MISTRAL_MODEL')
if ([string]::IsNullOrEmpty($MistralModel)) { $MistralModel = 'ministral-14b-latest' }
$MistralEndpoint = 'https://api.mistral.ai/v1/chat/completions'

# PowerShell 5.1 mặc định chỉ bật TLS cũ → kết nối HTTPS của Mistral sẽ fail. Bật TLS 1.2+.
[Net.ServicePointManager]::SecurityProtocol = `
  [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.ico'  = 'image/x-icon'
}

# ---------- Helper ----------
function Cut([string]$s, [int]$max) {
  if ([string]::IsNullOrEmpty($s)) { return '' }
  if ($s.Length -gt $max) { return $s.Substring(0, $max) }
  return $s
}

function Send-Json($ctx, [int]$status, $object) {
  $json = ConvertTo-Json -InputObject $object -Depth 10 -Compress
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
  $ctx.Response.StatusCode = $status
  $ctx.Response.ContentType = 'application/json; charset=utf-8'
  $ctx.Response.Headers['Access-Control-Allow-Origin'] = '*'
  $ctx.Response.ContentLength64 = $bytes.Length
  $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
}

function Read-JsonBody($ctx) {
  $reader = New-Object System.IO.StreamReader($ctx.Request.InputStream, [System.Text.Encoding]::UTF8)
  $raw = $reader.ReadToEnd()
  $reader.Close()
  if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
  return ConvertFrom-Json -InputObject $raw
}

# Gọi Mistral, tra ve @{ ok; content } hoac @{ ok = $false; error }
function Invoke-Mistral($messages, [double]$temperature, [switch]$JsonMode) {
  $payloadObj = @{
    model       = $MistralModel
    messages    = $messages
    temperature = $temperature
  }
  # Che do JSON: model buoc tra ra JSON hop le (chi dung khi can parse JSON,
  # khong dung cho ask-solution vi o do ta muon tra van ban tu do).
  if ($JsonMode) { $payloadObj.response_format = @{ type = 'json_object' } }
  $payload = ConvertTo-Json -InputObject $payloadObj -Depth 10 -Compress
  try {
    $resp = Invoke-WebRequest -Uri $MistralEndpoint -Method Post `
      -ContentType 'application/json' `
      -Headers @{ Authorization = "Bearer $MistralKey" } `
      -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
      -UseBasicParsing -TimeoutSec 300
    $text = [System.Text.Encoding]::UTF8.GetString($resp.RawContentStream.ToArray())
    $data = ConvertFrom-Json -InputObject $text
    return @{ ok = $true; content = [string]$data.choices[0].message.content }
  } catch {
    $detail = ''
    try {
      $webResp = $_.Exception.Response
      if ($webResp) {
        $sr = New-Object System.IO.StreamReader($webResp.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $detail = Cut ($sr.ReadToEnd()) 300
        $sr.Close()
      }
    } catch { }
    return @{ ok = $false; error = ($_.Exception.Message + ' ' + $detail) }
  }
}

# ---------- /api/ask-solution ----------
function Handle-AskSolution($ctx) {
  try { $body = Read-JsonBody $ctx } catch { $body = $null }
  if (-not $body) { return Send-Json $ctx 400 @{ error = 'Dữ liệu gửi lên không hợp lệ' } }

  $problem = Cut ([string]$body.problem) 4000
  $question = Cut ([string]$body.question) 500
  $steps = @()
  if ($body.solutionSteps) { $steps = @($body.solutionSteps | ForEach-Object { Cut ([string]$_) 2000 }) }
  $stepIndex = 0
  if ($null -ne $body.stepIndex) { $stepIndex = [int]$body.stepIndex }

  if (-not $problem -or -not $question) { return Send-Json $ctx 400 @{ error = 'Thiếu đề bài hoặc câu hỏi' } }

  $stepContent = '(không có bước này)'
  if ($stepIndex -ge 0 -and $stepIndex -lt $steps.Count) { $stepContent = $steps[$stepIndex] }

  if ([string]::IsNullOrEmpty($MistralKey)) {
    return Send-Json $ctx 200 @{
      answer = "(Chưa cấu hình MISTRAL_API_KEY nên đây là câu trả lời minh họa.)`n`n" +
        "Bước bạn hỏi: $stepContent`n`n" +
        'Hãy thử tự trả lời các câu hỏi sau: bước này dùng định nghĩa/định lý nào? ' +
        'Tại sao phép thế này hợp lệ (tập nguồn có chứa giá trị được thế không)? ' +
        'Mục tiêu của bước là gì — rút gọn điều kiện, tìm f(0), hay chứng minh đơn ánh/toàn ánh? ' +
        'Khi cấu hình key Mistral, AI sẽ giải thích chi tiết bước này.'
    }
  }

  $stepLines = @()
  for ($i = 0; $i -lt $steps.Count; $i++) { $stepLines += "Bước $($i + 1): $($steps[$i])" }
  $userContent = (@('ĐỀ BÀI:', $problem, '', 'LỜI GIẢI THAM KHẢO (theo bước):') + $stepLines +
    @('', "NGƯỜI HỌC HỎI VỀ BƯỚC $($stepIndex + 1):", "`"$question`"", '', 'Hãy giải thích bước này.')) -join "`n"

  $messages = @(
    @{ role = 'system'; content = 'Bạn là trợ giảng Toán giải thích lời giải phương trình hàm. ' +
        'Trả lời tập trung ĐÚNG vào bước được hỏi, nêu rõ kỹ thuật hoặc định lý liên quan, ' +
        'dùng LaTeX ($...$) cho công thức, giải thích ngắn gọn dễ hiểu cho học sinh giỏi THPT.' },
    @{ role = 'user'; content = $userContent }
  )
  $r = Invoke-Mistral $messages 0.4
  if (-not $r.ok) {
    return Send-Json $ctx 502 @{ error = "Mistral API lỗi (model: $MistralModel). $($r.error)" }
  }
  return Send-Json $ctx 200 @{ answer = $r.content; model = $MistralModel }
}

# Model nhỏ hay bọc JSON trong fence Markdown (```json ... ```) hoặc thêm văn bản
# thừa → thử bỏ fence, nếu vẫn hỏng thì lấy khối {...} lớn nhất.
function ConvertFrom-AiJson([string]$text) {
  if ([string]::IsNullOrWhiteSpace($text)) { return $null }
  $t = $text.Trim()
  if ($t -match '(?s)```(?:json)?\s*(.*?)\s*```') { $t = $Matches[1] }
  try { return ConvertFrom-Json -InputObject $t } catch { }
  $a = $t.IndexOf('{'); $b = $t.LastIndexOf('}')
  if ($a -ge 0 -and $b -gt $a) {
    try { return ConvertFrom-Json -InputObject $t.Substring($a, $b - $a + 1) } catch { }
  }
  return $null
}

# ---------- /api/generate-exercises ----------
$DIFFICULTY_LABEL = @{ 1 = 'cơ bản'; 2 = 'vận dụng'; 3 = 'nâng cao' }

function Get-GeneratePrompt($topic, $technique, $difficulty, $count) {
  $label = if ($DIFFICULTY_LABEL.ContainsKey($difficulty)) { $DIFFICULTY_LABEL[$difficulty] } else { 'vận dụng' }
  $lines = @(
    'Bạn là giáo viên Toán chuyên về phương trình hàm cho học sinh giỏi THPT.',
    "Hãy tạo $count bài tập tự luyện thuộc chuyên đề: `"$topic`".",
    $(if ($technique) { "Trọng tâm kỹ thuật cần luyện: `"$technique`"." } else { 'Bám sát các kỹ thuật chính của chuyên đề.' }),
    "Mức độ: $label.",
    'Yêu cầu:',
    '- Đề bài viết bằng LaTeX (dùng $...$ cho công thức).',
    '- Mỗi bài có gợi ý ngắn và lời giải theo từng bước rõ ràng.',
    '- Định dạng chuỗi (bắt buộc):',
    '+ title/problem/hint phải nằm trên ĐÚNG MỘT dòng, xuống dòng phải viết thành \n.',
    '+ solutionSteps là MẢNG CHUỖI (không phải mảng object), mỗi bước tối đa 2 câu.',
    '+ không dùng $$, không dùng danh sách gạch đầu dòng bên trong chuỗi.',
    '- Trả về ĐÚNG định dạng JSON, không thêm văn bản nào khác:',
    '{"exercises":[{"title":"...","problem":"...","hint":"...","solutionSteps":["Bước 1","Bước 2"]}]}'
    '+ Quy tắc escape JSON: mỗi dấu \ trong LaTeX phải ghi thành hai dấu \ liên tiếp.'
  )
  return $lines -join "`n"
}

# JSON "ăn" mất dấu gạch chéo của LaTeX: model ghi "\mathbb" (1 dấu \) thì
# ConvertFrom-Json biến \math thành ký tự backspace + "mathbb", \to thành
# tab + "o" -> MathJax báo "Math input error". Phục hồi lại các ký tự này.
function Repair-Latex([string]$s) {
  if ([string]::IsNullOrEmpty($s)) { return '' }
  $t = $s.Replace([string][char]8, '\b').Replace([string][char]12, '\f')
  $t = $t.Replace([string][char]9, '\t').Replace([string][char]13, '\r')
  return $t
}

function Get-DemoExercises([int]$count) {
  $samples = @(
    @{
      title = 'Bài mẫu 1'
      problem = 'Tìm tất cả các hàm $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn $f(x + y) = f(x) + f(y)$ với mọi $x, y \in \mathbb{R}$, biết $f$ liên tục.'
      hint = 'Tính f(0), sau đó mở rộng từ ℕ lên ℚ rồi dùng tính trù mật.'
      solutionSteps = @('Thế x = y = 0 được f(0) = 0.', 'Quy nạp được f(n) = nf(1) với n ∈ ℕ, mở rộng ra ℚ.', 'Dùng tính liên tục và trù mật suy ra f(x) = cx với c = f(1).')
    },
    @{
      title = 'Bài mẫu 2'
      problem = 'Tìm tất cả các đa thức $P$ thỏa mãn $P(x + 1) = P(x) + 2x + 1$ với mọi $x \in \mathbb{R}$.'
      hint = 'So sánh bậc hai vế rồi đặt dạng tổng quát của P.'
      solutionSteps = @('Vế phải bậc 1 nên deg P = 2, đặt P(x) = ax² + bx + c.', 'Thay vào điều kiện và so sánh hệ số tìm được a = 1, b = 0, c tùy ý.', 'Kết luận P(x) = x² + c.')
    },
    @{
      title = 'Bài mẫu 3'
      problem = 'Cho $f: \mathbb{N} \to \mathbb{N}$ thỏa mãn $f(n + 1) > f(f(n))$ với mọi $n \in \mathbb{N}$. Chứng minh $f(n) = n$.'
      hint = 'Dùng nguyên lý cực hạn: xét giá trị nhỏ nhất của f.'
      solutionSteps = @('Gọi m là giá trị nhỏ nhất của f, giả sử đạt tại n₀.', 'Nếu n₀ > 0 thì f(n₀) > f(f(n₀ − 1)) ≥ m, mâu thuẫn tính nhỏ nhất của m.', 'Vậy f(0) = m, tiếp tục chỉ ra m = 0 và quy nạp được f(n) = n.')
    }
  )
  $picked = @()
  for ($i = 0; $i -lt $count; $i++) {
    $s = $samples[$i % $samples.Count]
    $picked += @{ title = "$($s.title) ($($i + 1))"; problem = $s.problem; hint = $s.hint; solutionSteps = $s.solutionSteps }
  }
  return ,$picked
}

function Handle-GenerateExercises($ctx) {
  try { $body = Read-JsonBody $ctx } catch { $body = $null }
  if (-not $body) { return Send-Json $ctx 400 @{ error = 'Dữ liệu gửi lên không hợp lệ' } }

  $topic = Cut ([string]$body.topic) 200
  $technique = Cut ([string]$body.technique) 100
  $difficulty = if ($body.difficulty) { [int]$body.difficulty } else { 2 }
  $count = 3
  if ($body.count) { $count = [int]$body.count }
  if ($count -lt 1) { $count = 1 }
  if ($count -gt 10) { $count = 10 }
  if (-not $topic) { return Send-Json $ctx 400 @{ error = 'Thiếu chuyên đề' } }

  if ([string]::IsNullOrEmpty($MistralKey)) {
    return Send-Json $ctx 200 @{
      isDemo = $true
      note = 'Chưa cấu hình MISTRAL_API_KEY'
      exercises = Get-DemoExercises $count
    }
  }

  $messages = @(
    @{ role = 'system'; content = 'Bạn chỉ trả về JSON hợp lệ, đúng cấu trúc được yêu cầu.' },
    @{ role = 'user'; content = (Get-GeneratePrompt $topic $technique $difficulty $count) }
  )
  $r = Invoke-Mistral $messages 0.7 -JsonMode
  if (-not $r.ok) {
    return Send-Json $ctx 502 @{ error = "Mistral API lỗi (model: $MistralModel). $($r.error)" }
  }

  $parsed = ConvertFrom-AiJson $r.content
  $rawList = @(if ($parsed -and $parsed.exercises) { $parsed.exercises })
  if ($rawList.Count -eq 0) {
    return Send-Json $ctx 502 @{ error = 'AI trả về cấu trúc không đúng (thiếu trường exercises/problem/solutionSteps)' }
  }
  # Chuan hoa: moi phan tu solutionSteps phai la chuoi (model hay tra object {step, content})
  $exercises = @($rawList | ForEach-Object {
    $one = $_
    $steps = @()
    if ($one.solutionSteps) { $steps = @($one.solutionSteps | ForEach-Object {
      if ($_ -is [string]) { $_ }
      elseif ($_.content) { [string]$_.content }
      elseif ($_.step) { [string]$_.step }
      else { ConvertTo-Json -InputObject $_ -Compress -Depth 5 }
    }) }
    @{ title = [string]$one.title; problem = [string]$one.problem; hint = [string]$one.hint; solutionSteps = $steps }
  })
  if ($exercises.Count -gt $count) { $exercises = @($exercises[0..($count - 1)]) }
  # Phuc hui dau gach cheo LaTeX bi JSON an mat (noi dung nay gir nguyen tieng Viet).
  $exercises = @($exercises | ForEach-Object {
    $e = $_
    @{
      title = Repair-Latex ([string]$e.title)
      problem = Repair-Latex ([string]$e.problem)
      hint = Repair-Latex ([string]$e.hint)
      solutionSteps = @($e.solutionSteps | ForEach-Object { Repair-Latex ([string]$_) })
    }
  })
  return Send-Json $ctx 200 @{ isDemo = $false; model = $MistralModel; exercises = $exercises }
}

# ---------- /api/generate-similar ----------
function Handle-GenerateSimilar($ctx) {
  try { $body = Read-JsonBody $ctx } catch { $body = $null }
  if (-not $body) { return Send-Json $ctx 400 @{ error = 'Dữ liệu gửi lên không hợp lệ' } }

  if ([string]::IsNullOrEmpty($MistralKey)) {
    return Send-Json $ctx 200 @{
      question = "Demo Đề bài AI: Tìm m để hàm số đồng biến trên R."
      detailed_solution = "Demo Giải: Đạo hàm... $\Delta \le 0$..."
    }
  }

  $prompt = @(
    'Bạn là giáo viên Toán chuyên ra đề tự luận cho học sinh giỏi THPT.',
    'Nhiệm vụ: Tạo ra MỘT bài tập hoàn toàn MỚI, tương tự bài gốc.',
    '',
    '[KIẾN THỨC NỀN TẢNG (RAG)] - Sử dụng định lý/lý thuyết sau làm gốc:',
    $(if ($body.foundational_knowledge) { $body.foundational_knowledge } else { 'Tự sử dụng kiến thức phù hợp.' }),
    '',
    '--- BẮT ĐẦU BÀI GỐC (FEW-SHOT EXAMPLE) ---',
    'ĐỀ BÀI MẪU:',
    $body.original_question,
    'ĐÁP ÁN MẪU:',
    $body.original_solution,
    '--- KẾT THÚC BÀI GỐC ---',
    '',
    'Lưu ý quan trọng:',
    '- Bắt chước văn phong và logic của bài mẫu, nhưng thay đổi dữ kiện/biểu thức để thành bài toán mới.',
    '- Trả về đúng 2 trường dạng JSON: "de_bai_moi" và "dap_an_chi_tiet".'
  ) -join "`n"

  $messages = @(
    @{ role = 'system'; content = 'Bạn là máy chủ tạo bài tập tự luận định dạng JSON chuẩn.' },
    @{ role = 'user'; content = $prompt }
  )
  
  $r = Invoke-Mistral $messages 0.7 -JsonMode
  if (-not $r.ok) {
    return Send-Json $ctx 502 @{ error = "Mistral API lỗi: $($r.error)" }
  }

  $parsed = ConvertFrom-AiJson $r.content
  if (-not $parsed -or -not $parsed.de_bai_moi) {
    return Send-Json $ctx 502 @{ error = 'AI trả về cấu trúc không đúng' }
  }

  return Send-Json $ctx 200 @{
    question = Repair-Latex ([string]$parsed.de_bai_moi)
    detailed_solution = Repair-Latex ([string]$parsed.dap_an_chi_tiet)
  }
}

# ---------- Vòng lặp phục vụ request ----------
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

Write-Host "Ham so - dev server (tinh + AI) chay tai http://localhost:$Port/ (Ctrl+C de dung)"
if ([string]::IsNullOrEmpty($MistralKey)) {
  Write-Host "Chua co MISTRAL_API_KEY -> nut AI tra ve noi dung mau. Tao .env.local de dung AI that." -ForegroundColor Yellow
} else {
  Write-Host "AI da san sang (MISTRAL_API_KEY co san, model: $MistralModel)." -ForegroundColor Green
}

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
      $path = $ctx.Request.Url.AbsolutePath

      # --- Endpoint AI ---
      if ($path -eq '/api/ask-solution' -or $path -eq '/api/generate-exercises' -or $path -eq '/api/generate-similar') {
        if ($ctx.Request.HttpMethod -eq 'OPTIONS') {
          $ctx.Response.StatusCode = 200
          $ctx.Response.Headers['Access-Control-Allow-Origin'] = '*'
          $ctx.Response.Headers['Access-Control-Allow-Headers'] = 'Content-Type'
          $ctx.Response.Headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        }
        elseif ($ctx.Request.HttpMethod -ne 'POST') {
          Send-Json $ctx 405 @{ error = 'Chỉ chấp nhận POST' }
        }
        elseif ($path -eq '/api/ask-solution') { Handle-AskSolution $ctx }
        elseif ($path -eq '/api/generate-similar') { Handle-GenerateSimilar $ctx }
        else { Handle-GenerateExercises $ctx }
        Write-Host "$($ctx.Request.HttpMethod) $path -> $($ctx.Response.StatusCode)" -ForegroundColor Cyan
      }
      # --- File tĩnh ---
      else {
        # Không phục vụ file ẩn (.env, .env.local, .git...) và mã nguồn trong api/
        if (($path.Split('/') | Where-Object { $_.StartsWith('.') }) -or $path.StartsWith('/api/')) {
          $ctx.Response.StatusCode = 404
          $msg = [System.Text.Encoding]::UTF8.GetBytes('404 - Not Found')
          $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
        }
        else {
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
        }
      }
    }
    catch {
      try { Send-Json $ctx 500 @{ error = ('Lỗi máy chủ: ' + $_.Exception.Message) } } catch { }
    }
    finally {
      $ctx.Response.Close()
    }
  }
}
finally {
  $listener.Stop()
}
