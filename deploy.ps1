# Security Audit 一键安装脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/cloudflare/security-audit-skill#installation
# 更新日期：2026-10-25
# 类型：script
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '需要先安装 Git' }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw '需要先安装 Node.js' }

New-Item -ItemType Directory -Force -Path .download | Out-Null
Set-Location -Path .download

npx -y skills@latest add https://github.com/cloudflare/security-audit-skill --skill security-audit -g -a trae trae-cn -y --copy
npx -y skills@latest list -g

Write-Host ''

Write-Host '安装完成：重启客户端，在要审计的项目里说 security audit this codebase；报告默认写到 ~/security-audit-skill/<仓库名>/run-<N>'
Write-Host '若结果异常或需要改配置，请参考官方文档：https://github.com/cloudflare/security-audit-skill#installation'
