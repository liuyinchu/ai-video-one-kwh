# 完整工程备份

备份日期：2026-10-24（Asia/Shanghai）。

原始工程来自 `yangshuyun@10.10.10.1:/Users/yangshuyun/workspace/dev/ai-video/ai-video-1024-astra`。

本仓库完整保存源代码、脚本、许可证、`build/` 制作缓存、`build/v1/` 初版源文件、`output/` 中的两版成片、旁白、字幕、时间轴、分镜和验证报告。`build/` 与 `output/` 虽然仍在原始 `.gitignore` 中，但此次已显式加入 Git 跟踪，并非仅备份源码。

原始目录有 350 个普通文件（共 292,172,503 字节）、29 个子目录、2 个相对符号链接。所有文件均小于 100 MiB，可以直接通过 Git 完整备份，不需要 Git LFS 或外部下载地址。

`original-manifest.json` 记录原始工程的每个相对路径、类型、权限、文件大小、SHA-256 或符号链接目标。`original-git-metadata.tar.gz` 保留首次提交前原始 `.git/` 的完整内容，包括当时的空仓库状态。GitHub 上的新提交提供本次备份的版本历史。

## 恢复

```sh
git clone git@github.com:liuyinchu/ai-video-one-kwh.git
cd ai-video-one-kwh
```

克隆会直接恢复所有工程内容和两个相对符号链接。制作方法见根目录 README。无需再下载视频、旁白或缓存。

若需要检查首次备份前的 Git 元数据，可将 `BACKUP/original-git-metadata.tar.gz` 解压到单独的空目录。不要覆盖克隆后正在使用的 `.git/`。

`manifest.rb` 可在设置 UTF-8 locale 后生成同格式清单，例如 `LC_ALL=en_US.UTF-8 ruby BACKUP/manifest.rb /path/to/project`。比较时应使用归档中的原始 `.git/`，并排除本次新增的 `BACKUP/` 目录及克隆后新增的 Git 元数据。
