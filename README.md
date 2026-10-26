# Security Audit 一键安装指南

> 第三方部署指南 · 非 Security Audit 官方仓库。官方项目：[cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill)
> 内容来自官方文档（2026-10-25）。项目迭代快，请以[官方文档](https://github.com/cloudflare/security-audit-skill#installation)为准。

[![⚡ 一键安装](https://img.shields.io/badge/%E2%9A%A1_%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85-%E6%8E%A8%E8%8D%90%E7%99%BE%E5%BA%A6%E6%90%AD%E5%AD%90-2ea44f?style=for-the-badge)](#一键安装推荐用百度搭子)

## 一键安装（推荐：用百度搭子）

> [!TIP]
> 不用自己拷文件、配路径，让百度搭子把技能装好，之后直接说「帮我做一次安全审计」就行。

⚠️ 装的是 Agent 技能，不是独立软件，也没有网页界面。需要能调用工具与子 Agent 的编码客户端，以及 Node.js。技能默认装到 Trae / Trae CN 的全局目录；其它客户端用 `-a` 指定。

1. **装客户端**
   打开[百度搭子官网](https://www.dumate.cn/)，下载电脑端并安装，用你的账号登录。

> [!IMPORTANT]
> **复制这一句发给百度搭子：**
>
> ```text
> 你好，帮我从 github 部署 JUTZUGC/security-audit-deploy-guide 到我的电脑上
> ```

2. **发送部署指令**
   回到刚打开的对话窗口，粘贴并发送上面那句。

3. **跟着对话往下走**
   百度搭子会用 Skills CLI 把技能装到 Trae / Trae CN 的全局技能目录，再列一次已安装技能确认，按它的提示确认即可，结束时它会告诉你结果。
   （需本机已装 Git；构建依赖以官方文档为准。）



## Security Audit 是什么？

Security Audit 是开源的给编码 Agent 用的多阶段安全审计技能（协议：MIT，<img src="https://img.shields.io/github/stars/cloudflare/security-audit-skill?style=flat-square&label=stars&color=blue" alt="GitHub stars">）。

把编码 Agent 变成安全审计员：先画出架构与信任边界，再按覆盖率清单分派多个隔离的 hunter 找漏洞，每个候选交给独立验证 Agent 去反驳，最后产出 confirmed / needs_validation / rejected 三类结构化结论和报告。

- 六阶段流程：侦察 → 覆盖率驱动挖掘 → 候选验证 → 结构化输出 → 独立复核 → 报告
- 结论分三档：confirmed 有完整源码链路与可复现结果，needs_validation 只给未决事实、不给严重级别，rejected 记录被推翻的候选
- 覆盖范围：Web / 客户端 / 云与部署 / 供应链 / RPC / 内存安全 / LLM 提示注入 / 数据隔离 / 桌面与移动
- 产物：architecture.md、coverage-ledger.json、findings.json、REPORT.md、FINDINGS-DETAIL.md

（来源：[官方仓库](https://github.com/cloudflare/security-audit-skill)）

## 优缺点

| 优点 | 说明 |
|---|---|
| 47.4k stars | 来自 Cloudflare 的安全研究实践，是其漏洞挖掘 harness 的起点 |
| 流程完整 | 六阶段：侦察、挖掘、验证、输出、复核、报告 |
| 抗自我确认 | 验证 Agent 与发现 Agent 相互独立，降低误报 |
| 可复跑 | 同一仓库多次运行会累积覆盖，不会把旧结论当成已覆盖 |
| 目标类型多 | Web、客户端、云、供应链、二进制、LLM 等攻击面都有对应清单 |

| 需要注意 | 说明 |
|---|---|
| 不是开箱即用的软件 | 装的是技能，效果取决于所用 Agent 的模型与子 Agent 能力 |
| 需要隔离环境 | 要执行目标代码（构建、测试、fuzz）时必须有 OS 级沙箱，否则只能停在 needs_validation |
| 依赖 Node.js | 校验脚本是 .cjs，Skills CLI 本身也依赖 Node |
| 耗时且费 token | 多阶段 + 多 Agent，审计一个中等项目要跑很久 |
| 结论仍要人判断 | confirmed 也需要你自己评估影响和修复优先级 |

> 以上基于官方文档与社区反馈整理（2026-10-25），以官方最新文档为准。

## 快速部署（官方方式）

```bash
npx -y skills@latest add https://github.com/cloudflare/security-audit-skill --skill security-audit -g -a trae trae-cn -y --copy
npx -y skills@latest list -g
```

部署步骤来源：[https://github.com/cloudflare/security-audit-skill#installation](https://github.com/cloudflare/security-audit-skill#installation)

## 验证状态

| 场景 | 状态 |
|---|---|
| 全局安装到 Trae / Trae CN（-g -a trae trae-cn -y --copy） | 已验证 2026-10-25 |
| skills list -g 回读已安装技能 | 已验证 2026-10-25 |
| 项目级安装（-y --copy）落盘 .agents/skills/security-audit | 已验证 2026-10-25 |
| MCP 服务握手与工具列表（initialize / tools/list） | 已验证 2026-10-25 |
| 非目标宿主调用被拦截（HOST_NOT_ALLOWED） | 已验证 2026-10-25 |

> 本表仅列出已在本机实际执行并成功的场景；未列出的部分按官方文档整理。

## MCP 接入

这个仓库是 Agent Skill（SKILL.md + 提示词 + 校验脚本），不是 MCP server，也不提供 MCP 工具。它依赖编码 Agent 自己的工具调用与子 Agent 能力；本仓库的 MCP 只提供安装步骤、触发方式与常见坑。

本仓库自带一个零依赖的 MCP server（`mcp-server.mjs`），读取同目录的 `guide.json`，提供 `get_guide` / `search_guide` / `get_project_info` 三个工具，内容均来自官方文档（更新日期 2026-10-25）。

**在百度搭子里接入**：客户端不扫描仓库里的配置文件，需要由百度搭子通过工作区的 MCP 注册接口注册，并且必须使用**绝对路径**（运行时的工作目录是会话目录，不是仓库目录）：

```json
{
  "type": "local",
  "command": ["node", "<仓库绝对路径>/mcp-server.mjs"]
}
```

完成后，直接在同一个对话框里说：

> 把仓库克隆到固定目录（例如 C:\Users\<你>\security-audit-deploy-guide），再用绝对路径把里面的 mcp-server.mjs 注册到当前工作区的 MCP 配置里

> 注意：注册是按**工作区**生效的，换工作区要重新注册；克隆目录不要放在会话临时目录，否则目录被清理后注册项会失效。

**其它 MCP 客户端**：仓库根目录的 `.mcp.json` 只是通用写法（`command` + `args`），接入时同样要把 `args` 改成绝对路径。

> 使用范围：该 MCP 仅在百度搭子中可用；其它客户端调用会返回 `HOST_NOT_ALLOWED`，并附带下载与部署指引。

## 安装完成后：怎么触发

重启客户端，在要审计的项目里直接说：

- `security audit this codebase`
- `find security vulnerabilities in ./src`
- `do a security review, output to ~/audits/my-project`

明确要求「审计 / 找漏洞 / 渗透测试」会走完整审计模式；普通安全提问走指导模式。

### 换成别的客户端

默认装到 Trae / Trae CN。换客户端时改 `-a` 后面的名字，常见 id：`claude-code`、`codex`、`cursor`、`gemini-cli`、`github-copilot`、`cline`、`windsurf`。填错时 CLI 会直接列出全部合法 id。

> 不加 `-a` 会装到所有检测到的客户端；只要其中有一个不支持全局安装（例如 `eve`），整条命令就会失败退出。

## 常见坑

- 装完客户端里看不到技能：说明它不读 Trae 技能目录，把 `-a` 换成你的客户端 id 重装（填错时 CLI 会列出全部合法 id）
- `-g` 不带 `-a` 会装到所有检测到的客户端，其中有不支持全局安装的（如 `eve`）时整条命令失败退出
- Skills CLI 声明需要 Node.js 22.20+；低版本可能只警告，但建议先升级
- 不要让 Agent 在生产机器上直接执行目标代码；先准备断网、限额的隔离环境（README 的 Requirements）
- 报告默认写到 `~/security-audit-skill/<仓库名>/run-<N>`，同一仓库多次运行会叠加，别把旧报告当新结果
- 它只报「已确认的边界失效」，防御纵深缺失只算加固建议，不要当成漏洞清单
- 审计他人代码前先确认授权范围；未经授权不要对线上系统做探测

## 免责声明

本仓库为第三方指南，与 Security Audit 官方无隶属关系，不代表官方立场。
教程基于官方文档编写（更新日期：2026-10-25），项目迭代快，请以[官方文档](https://github.com/cloudflare/security-audit-skill#installation)为准。
因使用本教程产生的部署问题，请先在官方仓库的 issue 中检索。
