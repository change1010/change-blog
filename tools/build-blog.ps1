$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$postsDir = Join-Path $root "posts"
$articlesDir = Join-Path $root "articles"
New-Item -ItemType Directory -Force -Path $articlesDir | Out-Null

function HtmlEncode($text) {
  return [System.Net.WebUtility]::HtmlEncode([string]$text)
}

function SlugFromFile($path) {
  return [System.IO.Path]::GetFileNameWithoutExtension($path)
}

function ParsePost($path) {
  $raw = Get-Content -Path $path -Raw -Encoding UTF8
  $meta = @{}
  $body = $raw

  if ($raw -match "(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$") {
    $front = $Matches[1]
    $body = $Matches[2]
    foreach ($line in ($front -split "\r?\n")) {
      if ($line -match "^\s*([^:]+):\s*(.*)\s*$") {
        $meta[$Matches[1].Trim()] = $Matches[2].Trim()
      }
    }
  }

  $slug = SlugFromFile $path
  [pscustomobject]@{
    Slug = $slug
    Title = $meta["title"]
    Date = $meta["date"]
    Category = $meta["category"]
    Cover = $meta["cover"]
    Summary = $meta["summary"]
    Body = $body
    Source = $path
  }
}

function ConvertInlineMarkdown($text) {
  $encoded = HtmlEncode $text
  $encoded = [regex]::Replace($encoded, '\[([^\]]+)\]\((https?://[A-Za-z0-9][A-Za-z0-9._~:/?#@!$&*+,;=%-]*)\)', {
    param($match)
    $label = $match.Groups[1].Value
    $url = $match.Groups[2].Value
    return "<a href=""$url"" target=""_blank"" rel=""noopener noreferrer"">$label</a>"
  })
  $encoded = [regex]::Replace($encoded, '(?<!["''=])(https?://[A-Za-z0-9][A-Za-z0-9._~:/?#@!$&*+,;=%-]*)', {
    param($match)
    $url = $match.Groups[1].Value
    $suffix = ""
    while ($url.Length -gt 0 -and ".,;:!?，。；：！？、）)".Contains($url.Substring($url.Length - 1))) {
      $suffix = $url.Substring($url.Length - 1) + $suffix
      $url = $url.Substring(0, $url.Length - 1)
    }
    return "<a href=""$url"" target=""_blank"" rel=""noopener noreferrer"">$url</a>$suffix"
  })
  $encoded = [regex]::Replace($encoded, '`([^`]+)`', '<code>$1</code>')
  $encoded = [regex]::Replace($encoded, "\*\*([^*]+)\*\*", '<strong>$1</strong>')
  return $encoded
}

function ConvertMarkdown($markdown) {
  $lines = $markdown -split "\r?\n"
  $html = New-Object System.Collections.Generic.List[string]
  $inCode = $false
  $inList = $false
  $paragraph = New-Object System.Collections.Generic.List[string]

  function FlushParagraph {
    if ($paragraph.Count -gt 0) {
      $text = ($paragraph -join " ").Trim()
      if ($text.Length -gt 0) {
        $html.Add("<p>$(ConvertInlineMarkdown $text)</p>")
      }
      $paragraph.Clear()
    }
  }

  foreach ($line in $lines) {
    if ($line -match '^```') {
      FlushParagraph
      if ($inList) {
        $html.Add("</ul>")
        $inList = $false
      }
      if ($inCode) {
        $html.Add("</code></pre>")
        $inCode = $false
      } else {
        $html.Add("<pre><code>")
        $inCode = $true
      }
      continue
    }

    if ($inCode) {
      $html.Add((HtmlEncode $line))
      continue
    }

    if ($line.Trim().Length -eq 0) {
      FlushParagraph
      if ($inList) {
        $html.Add("</ul>")
        $inList = $false
      }
      continue
    }

    if ($line -match "^(#{1,3})\s+(.+)$") {
      FlushParagraph
      if ($inList) {
        $html.Add("</ul>")
        $inList = $false
      }
      $level = $Matches[1].Length
      $content = ConvertInlineMarkdown $Matches[2]
      $html.Add("<h$level>$content</h$level>")
      continue
    }

    if ($line -match "^\s*[-*]\s+(.+)$") {
      FlushParagraph
      if (-not $inList) {
        $html.Add("<ul>")
        $inList = $true
      }
      $html.Add("<li>$(ConvertInlineMarkdown $Matches[1])</li>")
      continue
    }

    $paragraph.Add($line.Trim())
  }

  FlushParagraph
  if ($inList) {
    $html.Add("</ul>")
  }
  if ($inCode) {
    $html.Add("</code></pre>")
  }

  return ($html -join "`n")
}

function SiteHeader($prefix) {
@"
<header class="site-header">
  <nav class="nav" aria-label="Main navigation">
    <a class="brand" href="${prefix}index.html#top">
      <span>change</span>
    </a>
    <div class="nav-links">
      <a href="${prefix}index.html#posts">&#25991;&#31456;</a>
      <a href="https://github.com/change1010/change-blog">GitHub</a>
    </div>
  </nav>
</header>
"@
}

$posts = @(Get-ChildItem -Path $postsDir -Filter "*.md" | ForEach-Object { ParsePost $_.FullName } | Sort-Object Date -Descending)
if ($posts.Count -eq 0) {
  throw "No markdown posts found in posts/."
}

$currentArticleNames = @{}
foreach ($post in $posts) {
  $currentArticleNames["$($post.Slug).html"] = $true
}

Get-ChildItem -Path $articlesDir -Filter "*.html" -File | ForEach-Object {
  if (-not $currentArticleNames.ContainsKey($_.Name)) {
    Remove-Item -LiteralPath $_.FullName
    Write-Host "Removed stale article: $($_.Name)"
  }
}

foreach ($post in $posts) {
  $title = HtmlEncode $post.Title
  $description = HtmlEncode $post.Summary
  $category = HtmlEncode $post.Category
  $articleBody = ConvertMarkdown $post.Body
  $articlePath = Join-Path $articlesDir "$($post.Slug).html"
  $article = @"
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="$description">
  <title>$title - change1010 Blog</title>
  <link rel="stylesheet" href="../assets/style.css">
  <link rel="icon" href="../image/favicon.png" type="image/png">
</head>
<body class="article-page">
$(SiteHeader "../")
  <section class="hero article-hero" style="--cover: url('$($post.Cover)')">
    <div class="hero-content">
      <p class="eyebrow">$($post.Date) / $category</p>
      <h1 class="article-title">$title</h1>
      <p class="hero-copy">$description</p>
    </div>
  </section>
  <main class="article-shell">
    <article class="article-content">
$articleBody
    </article>
  </main>
  <footer class="site-footer">
    <p>&copy; 2026 change1010. Built with GitHub Pages.</p>
  </footer>
</body>
</html>
"@
  Set-Content -Path $articlePath -Value $article -Encoding UTF8
}

$postCards = foreach ($post in $posts) {
  $href = "articles/$($post.Slug).html"
  $title = HtmlEncode $post.Title
  $summary = HtmlEncode $post.Summary
  $category = HtmlEncode $post.Category
@"
          <article class="post-card">
            <img src="$($post.Cover)" alt="$title">
            <div class="post-body">
              <div class="meta">
                <span>$($post.Date)</span>
                <span class="tag">$category</span>
              </div>
              <h3>$title</h3>
              <p>$summary</p>
              <a class="read-more" href="$href">&#32487;&#32493;&#38405;&#35835;</a>
            </div>
          </article>
"@
}
$postCardsHtml = $postCards -join "`n"

$index = @"
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="change1010 personal blog.">
  <title>change1010 Blog</title>
  <link rel="stylesheet" href="assets/style.css">
  <link rel="icon" href="image/favicon.png" type="image/png">
</head>
<body>
$(SiteHeader "")
  <section class="hero" id="top">
    <span class="petal"></span>
    <span class="petal"></span>
    <span class="petal"></span>
    <span class="petal"></span>
    <span class="petal"></span>
    <div class="hero-content">
      <h1>change &#30340;&#21338;&#23458;</h1>
      <p class="hero-copy">&#25226;&#23398;&#20064;&#36807;&#31243;&#12289;&#39033;&#30446;&#35760;&#24405;&#21644;&#20598;&#28982;&#20882;&#20986;&#30340;&#24819;&#27861;&#37117;&#23433;&#25918;&#22312;&#36825;&#37324;&#12290;</p>
      <div class="hero-actions">
        <a class="button primary" href="#posts">&#38405;&#35835;&#26368;&#26032;&#25991;&#31456;</a>
      </div>
    </div>
  </section>

  <main>
    <section class="section" id="posts">
      <div class="section-heading">
        <div>
          <h2>&#26368;&#26032;&#25991;&#31456;</h2>
        </div>
      </div>

      <div class="layout">
        <div class="post-list">
$postCardsHtml
        </div>

        <aside class="sidebar" aria-label="Sidebar">
          <section class="panel profile">
            <div class="profile-cover"></div>
            <div class="profile-body">
              <div class="avatar">C</div>
              <h2>change</h2>
              <div class="stats" aria-label="Blog stats">
                <div class="stat"><strong>$($posts.Count)</strong><span>&#25991;&#31456;</span></div>
                <div class="stat"><strong>4</strong><span>&#20998;&#31867;</span></div>
                <div class="stat"><strong>1</strong><span>&#31449;&#28857;</span></div>
              </div>
            </div>
          </section>
        </aside>
      </div>
    </section>

    <section class="about-band" id="about">
      <div class="section about-content">
        <div class="about-copy">
          <h2>&#20851;&#20110;&#36825;&#20010;&#23567;&#31449;</h2>
          <p>&#36825;&#26159;&#19968;&#20010;&#37096;&#32626;&#22312; GitHub Pages &#19978;&#30340;&#32431;&#38745;&#24577;&#21338;&#23458;&#12290;&#20320;&#29616;&#22312;&#21487;&#20197;&#29992; Markdown &#20889;&#25991;&#31456;&#65292;&#28982;&#21518;&#29983;&#25104;&#38745;&#24577;&#39029;&#38754;&#12290;</p>
        </div>
      </div>
    </section>
  </main>

  <footer class="site-footer">
    <p>&copy; 2026 change1010. Built with GitHub Pages.</p>
  </footer>
</body>
</html>
"@

Set-Content -Path (Join-Path $root "index.html") -Value $index -Encoding UTF8
Write-Host "Build complete: $($posts.Count) post(s)."
