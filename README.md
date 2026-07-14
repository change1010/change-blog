# change-blog

这是 change1010 的 GitHub Pages 静态博客。

## 快速发文章

1. 在 `posts` 文件夹里复制一篇 `.md` 文件，改成新文件名，例如：

   ```text
   posts/2026-07-15-my-note.md
   ```

2. 修改文件开头的信息：

   ```markdown
   ---
   title: 我的新文章
   date: 2026-07-15
   category: 学习笔记
   cover: https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=900&q=80
   summary: 这里写文章摘要，会显示在首页卡片里。
   ---
   ```

3. 在下面用 Markdown 写正文。

   正文不用再写一级标题，因为 `title` 会自动显示在文章页顶部。可以直接从普通段落或 `## 二级标题` 开始。

4. 生成静态页面：

   ```powershell
   cd E:\blog
   .\tools\build-blog.ps1
   ```

5. 发布到 GitHub Pages：

   ```powershell
   git add .
   git commit -m "Add new post"
   git push
   ```

## 常用修改

- 修改首页样式：编辑 `assets/style.css`
- 修改首页文案：编辑 `tools/build-blog.ps1` 里的首页模板，然后重新运行脚本
- 修改文章：编辑 `posts/*.md`，然后重新运行脚本
- 删除文章：删除 `posts` 里的对应 `.md` 文件，然后重新运行脚本；`articles` 里的旧 HTML 会自动清理
- 查看生成的文章页：打开 `articles/*.html`

站点地址：

```text
https://change1010.github.io/change-blog/
```

报错解决：Failed to connect to github.com port 443

git config --global http.proxy http://127.0.0.1:7897

git push