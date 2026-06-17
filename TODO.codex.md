# 2026-06-17 事件分析项目初始化

## Background
- 当前仓库为空，需要先沉淀一版“国际事件分析项目”的组织方法，并用“美伊 2026-06 局势”做完整示例。
- 用户进一步要求补充石油价格分析，包括当前油价驱动因素、特朗普为何同意和谈、油价涨跌对美国的影响、近两日油价暴跌原因、美国战略石油储备低位影响。
- 用户继续要求分析金属铜，包括供需关系、库存变化、美国关税预期及价格走向判断。
- 用户要求继续直接补三项：铜专题结构化 JSON、铜/铝/镍横向比较、以及可落地的数据库 schema。

## Goal
- 建立文档型仓库骨架。
- 给出 Topic / Event / Entity / Relation 的推荐组织方式。
- 产出一份可直接复用的“美伊局势与和谈协议”样例分析。
- 补充与该话题直接相关的石油价格分析说明。
- 新增一份铜市场专题，解释当前价格驱动与后续判断。
- 增加跨金属比较文档和 Postgres 初始 schema。

## Scope
- `README.md`
- `docs/topic-model-and-us-iran-2026-06-17.md`
- `docs/oil-price-and-us-energy-security-2026-06-17.md`
- `docs/copper-supply-demand-and-tariff-2026-06-17.md`
- `docs/base-metals-comparison-2026-06-17.md`
- `docs/postgres-schema-design.md`
- `schema/postgres-initial-schema.sql`
- `examples/us-iran-2026-06-17.topic.json`
- `examples/copper-2026-06-17.topic.json`
- `.gitignore`

## Constraints
- 以中文为主。
- 先做文档与样例，不扩展到数据库代码或服务端实现。
- 明确区分事实、判断、待确认事项。

## Todo
- [x] 初始化 git 仓库。
- [x] 明确仓库定位与目录结构。
- [x] 落地 Topic / Event / Relation 组织建议。
- [x] 编写 2026-06-17 美伊局势示例分析。
- [x] 提供可入库 JSON 示例。
- [x] 补充油价驱动、美国影响与 SPR 风险分析。
- [x] 拆出独立油价与美国能源安全专题文档。
- [x] 新增铜供需、库存、美国关税预期与走向判断专题。
- [x] 补铜专题结构化 JSON 示例。
- [x] 补铜/铝/镍横向比较专题。
- [x] 补 Postgres 初始 schema 与设计说明。
- [ ] 后续如需继续，补查询 API 设计。

## Verification
- 文档可单独阅读并理解建模方式。
- JSON 样例可直接作为后续 schema 设计输入。
- 文档能回答“为什么这两日油价暴跌、对美国意味着什么、SPR 低位有什么影响”。
- 文档能回答“铜为什么强/弱、库存迁移意味着什么、美国关税预期如何影响定价”。
- 文档与 schema 能支撑后续直接进入数据建模和 API 设计。
- 首次 commit 包含 `TODO.codex.md`。

## Open Questions / Items Requiring Human Confirmation
- 后续是否采用关系型数据库（如 Postgres）还是图数据库。
- 关系类型枚举是否要在下一轮固定下来。
- 是否需要继续落到 API / 表结构 / 前端查看器。
- 铜专题后续是否要扩展到铝、锌、镍等有色金属横向比较。
- schema 是否需要兼容多语言内容、嵌入向量检索和图查询加速。
