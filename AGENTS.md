# STJSON AGENTS

## 0. 路径边界

以下分层是长期约束：

```text
.
├── AGENTS.md                          # repo-wide 长期规则
├── skills/                            # 对外 public skills，仅放反馈 / 更新入口
│   ├── README.md
│   ├── stjson-dev-feedback/
│   └── stjson-update/
├── .agents/skills/                    # 仓库内部维护流程与实现流程
├── docs-dev/features/                 # 功能规格与验收边界
├── docs-dev/dev/                      # 技术方案、测试矩阵、维护说明
└── memory/YYYY-MM-DD.md               # 关键决策、阶段结论、会话沉淀
```

补充约束：

1. `skills/` 只保留面向外部使用者的 public skills，不再放 repo 内部实现流程。
2. repo 内部可复用流程优先沉淀到 `.agents/skills/`。
3. 只有 repo-wide、长期稳定、每次都应遵守的规则才进入 `AGENTS.md`。

## 1. 全局原则

1. 全程中文沟通。
2. 先明确需求边界和验收条件，再动代码或文档。
3. 代码改动遵循 BDD + TDD：先场景，再测试，再实现。
4. 以最小改动复用现有实现与测试结构，避免顺手重构。
5. 公开 API、行为语义和包管理接入方式，未经明确要求不要改名或扩面。
6. 任何可复用且会重复出现的维护流程，优先更新 `.agents/skills/`；只有升级为长期治理规则时才更新 `AGENTS.md`。
7. 对外使用者可见的反馈、更新、安装、升级路径发生变化时，必须同步 `skills/` 与发布打包逻辑。
8. 变更完成后要同步相关文档与记忆，避免代码、skill、文档三处口径漂移。

## 2. 标准工作流

1. 先定位影响面：`Source/STJSON/`、`Source/AnyCodable/`、`Source/SwiftyJSON/`、`Tests/`、`docs-dev/`、`skills/`。
2. 若是行为修复或能力新增，先补失败测试，再做最小实现。
3. 优先跑 focused tests；只有影响面扩大时再跑全量 `swift test`。
4. 若改动触达 public skills、发布资产或接入说明，同步检查 `skills/README.md`、`skills/stjson-update/` 和 `.github/workflows/release.yml`。
5. 若本轮工作提炼出维护者会反复使用的流程，把它写进 `.agents/skills/`，不要继续塞回 public `skills/`。

## 3. 测试与校验门禁

1. 代码改动必须运行对应测试；未运行时要明确说明原因和风险。
2. 纯文档 / skill / workflow 改动，至少执行这些结构校验：
   - `git diff --check`
   - `find skills -mindepth 1 -maxdepth 1 -type d | sort`
   - `rg -n '^name:|^description:' skills/*/SKILL.md .agents/skills/*/SKILL.md`
3. 涉及 Swift 行为、编码解码、JSONLines、JSON-RPC、AnyCodable 的改动，优先跑对应 `swift test --filter <SuiteOrCase>`，必要时再跑全量 `swift test`。
4. 禁止“只改不验”。

## 4. 文档与记忆

1. 功能规格、验收边界放 `docs-dev/features/`。
2. 技术方案、测试矩阵、维护说明放 `docs-dev/dev/`。
3. 关键决策、阶段结论、后续注意事项写入 `memory/YYYY-MM-DD.md`。
4. 若 public skills 的职责边界变化，需要同步更新 `skills/README.md`。

## 5. Skills 治理

1. `skills/` 当前允许这些 public skills：
   - `stjson-usage`
   - `stjson-dev-feedback`
   - `stjson-update`
2. `skills/` 发布时以 `STJSON.skills/` 作为安装根目录打包，不把 `.agents/skills/` 混入 release asset。
3. `stjson-usage` 负责外部用户安装、接入、常见使用方式与能力路由。
4. `stjson-dev-feedback` 负责外部用户试用、接入、兼容性、文档缺口、缺陷反馈的 issue 流程。
5. `stjson-update` 负责外部用户更新 STJSON 版本与 public skills bundle。
6. repo 内部实现、治理、发版、文档沉淀流程统一走 `.agents/skills/`。

## 6. 完成定义

1. 验收场景满足。
2. 相关测试或结构校验已执行，并记录结果。
3. 代码、文档、skills 口径一致。
4. 若出现新的可复用维护流程，已更新 `.agents/skills/` 或说明为何暂不沉淀。
