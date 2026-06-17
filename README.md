# 事件分析项目

这个仓库用于沉淀“国际事件分析”的组织方式。核心目标不是把新闻按时间堆起来，而是把**事件事实、分析话题、参与实体、关联关系、来源证据**拆开存放，便于后续做时间线、关联传播、局势评估与专题追踪。

## 推荐组织原则

- `Event`：原子事件。一次明确发生的事实。
- `Topic`：分析话题。一个话题可以聚合多个事件。
- `Entity`：参与方。国家、组织、人物、地区、机构。
- `Relation`：关联关系。允许 `topic-topic`、`event-event`、`event-topic`、`entity-event` 多对多。
- `Source / Claim`：来源与具体说法，负责溯源和置信度。

一句话总结：**事件是事实单元，话题是聚合单元，关系是分析骨架。**

## 目录

- [docs/topic-model-and-us-iran-2026-06-17.md](docs/topic-model-and-us-iran-2026-06-17.md)：建模示例、截至 2026-06-17 的美伊局势样例分析，以及油价与 SPR 影响说明。
- [docs/oil-price-and-us-energy-security-2026-06-17.md](docs/oil-price-and-us-energy-security-2026-06-17.md)：石油价格影响链、特朗普和谈动机、美国受影响路径与 SPR 风险专题。
- [docs/copper-supply-demand-and-tariff-2026-06-17.md](docs/copper-supply-demand-and-tariff-2026-06-17.md)：铜供需、库存迁移、美国关税预期与价格走向判断。
- [examples/us-iran-2026-06-17.topic.json](examples/us-iran-2026-06-17.topic.json)：可直接复用的结构化样例。
- [TODO.codex.md](TODO.codex.md)：持续开发上下文。

## 最小落地建议

如果下一步要从文档走向系统实现，建议优先做这三件事：

1. 固定 `relation_type` 枚举，例如 `leads_to`、`pressure_on`、`core_dispute`、`spillover_risk`。
2. 先实现 `Topic + Event + Relation + Source` 四类对象，不要一开始做复杂 UI。
3. 先用关系型数据库承载；只有在高频查询明显变成多跳图遍历时，再考虑图数据库。
