# 客户中心功能需求产品需求文档 (PRD)

> 文档版本：v1.0  
> 创建日期：2026 年 4 月 20 日  
> 项目名称：象小秘 AI 直营平台 - 客户中心  
> 适用系统：xxm_mjoys

---

## 目录

1. [文档概述](#1-文档概述)
2. [产品定位](#2-产品定位)
3. [用户角色](#3-用户角色)
4. [功能架构](#4-功能架构)
5. [详细功能需求](#5-详细功能需求)
6. [数据结构设计](#6-数据结构设计)
7. [接口需求](#7-接口需求)
8. [非功能性需求](#8-非功能性需求)
9. [UI/UX 要求](#9-uiux-要求)
10. [版本规划](#10-版本规划)

---

## 1. 文档概述

### 1.1 文档目的

本文档旨在明确"象小秘 AI 直营平台"客户中心模块的功能需求，为开发团队、测试团队及相关干系人提供统一的需求参考依据。

### 1.2 背景说明

当前银行/金融行业在数字化转型过程中，需要高效管理海量客户资源，实现精细化客户运营。客户中心作为直营平台的核心模块，承载着客户数据管理、客户分群运营、客户价值挖掘等重要职能。

### 1.3 现状分析

**已有功能**：
- ✅ 客户管理（基础 CRUD）
- ✅ 客群管理（数据批次管理）

**待完善功能**：
- ⚠️ 客户详情页（仅有弹窗展示）
- ⚠️ 客户导入/导出（仅有按钮，无实现）
- ❌ 客户跟进记录
- ❌ 客户 360°画像
- ❌ 客户分配/转移机制
- ❌ 客户统计报表

### 1.4 术语定义

| 术语 | 定义 |
|------|------|
| 客户 | 在系统中登记的个人或企业用户，具有唯一客户号 |
| 客群 | 具有共同特征的客户集合，用于批量运营 |
| 跟进 | 坐席与客户的交互记录，包括电话、短信等 |
| 标签 | 用于标识客户特征的标记，支持自定义 |
| 数据批次 | 批量导入客户数据时形成的数据集合 |

---

## 2. 产品定位

### 2.1 产品愿景

打造银行/金融行业领先的智能化客户管理平台，实现客户全生命周期管理，赋能精细化运营，提升客户价值。

### 2.2 核心价值

| 价值维度 | 说明 |
|----------|------|
| **数据统一** | 整合分散的客户数据，形成统一客户视图 |
| **精准分群** | 基于多维标签体系，实现客户精准分群 |
| **智能运营** | 结合 AI 能力，实现智能化客户触达与跟进 |
| **价值挖掘** | 通过数据分析，挖掘客户潜在价值 |

### 2.3 功能边界

**本模块负责**：
- 客户数据的增删改查
- 客户标签管理
- 客户分群运营
- 客户跟进记录
- 客户统计分析

**与其他模块的边界**：
- 与**电话工作台**：提供客户拨打任务，接收拨打结果
- 与**质检工作台**：提供客户交互录音用于质检
- 与**坐席管理**：客户分配给坐席进行跟进
- 与**数据看板**：提供客户统计数据用于展示
- 与**数据湖**：从数据湖同步客户相关数据

---

## 3. 用户角色

### 3.1 角色定义

| 角色 | 职责 | 使用场景 |
|------|------|----------|
| **系统管理员** | 系统配置、权限管理 | 配置客户字段、标签体系、分配规则 |
| **运营管理员** | 客群运营策略制定 | 创建客群、制定触达策略、分析效果 |
| **坐席人员** | 客户跟进与维护 | 查看分配客户、记录跟进、更新客户信息 |
| **数据分析师** | 客户数据分析 | 客户画像分析、价值分析、流失预警 |
| **普通用户** | 基础数据查看 | 查看客户列表、客户详情 |

### 3.2 角色权限矩阵

| 功能模块 | 系统管理员 | 运营管理员 | 坐席人员 | 数据分析师 | 普通用户 |
|----------|-----------|-----------|----------|-----------|----------|
| 客户列表查看 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 客户新增/编辑 | ✅ | ✅ | ✅(仅分配客户) | ❌ | ❌ |
| 客户删除 | ✅ | ❌ | ❌ | ❌ | ❌ |
| 客户导入/导出 | ✅ | ✅ | ❌ | ✅ | ❌ |
| 客群创建/编辑 | ✅ | ✅ | ❌ | ✅ | ❌ |
| 客户分配 | ✅ | ✅ | ❌ | ❌ | ❌ |
| 跟进记录 | ✅ | ✅ | ✅ | ❌ | ❌ |
| 客户统计 | ✅ | ✅ | ❌ | ✅ | ❌ |
| 标签管理 | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## 4. 功能架构

### 4.1 功能架构图

```
客户中心
├── 客户管理
│   ├── 客户列表
│   ├── 客户详情
│   ├── 客户新增/编辑
│   ├── 客户导入/导出
│   ├── 客户分配
│   └── 客户标签管理
├── 客群管理
│   ├── 客群列表
│   ├── 客群创建
│   ├── 客群规则配置
│   ├── 客群数据统计
│   └── 数据批次管理
├── 跟进管理
│   ├── 跟进记录列表
│   ├── 跟进记录新增
│   ├── 跟进计划
│   └── 跟进统计
├── 客户画像
│   ├── 基本信息
│   ├── 标签画像
│   ├── 行为轨迹
│   ├── 跟进历史
│   └── 关联数据
└── 统计分析
    ├── 客户概览
    ├── 客户增长分析
    ├── 客户价值分析
    └── 流失预警分析
```

### 4.2 功能优先级

| 优先级 | 功能模块 | 说明 |
|--------|----------|------|
| **P0** | 客户列表、客户详情、客户编辑 | 基础功能，必须实现 |
| **P0** | 客户导入/导出 | 批量操作核心功能 |
| **P1** | 客群管理 | 精细化运营基础 |
| **P1** | 跟进记录 | 客户维护核心功能 |
| **P2** | 客户画像 | 提升用户体验 |
| **P2** | 客户分配 | 坐席协作需求 |
| **P3** | 统计分析 | 数据决策支持 |

---

## 5. 详细功能需求

### 5.1 客户管理

#### 5.1.1 客户列表

**功能描述**：展示客户列表，支持搜索、筛选、排序、分页等操作。

**页面元素**：
- 搜索栏：客户号/客户名称/联系方式、银行机构、标签、创建时间范围
- 工具栏：新增客户、批量导入、批量导出、批量删除、列设置
- 数据表格：展示客户核心字段
- 分页器：支持自定义每页数量

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CM-001 | 支持按客户号/客户名称/联系方式模糊搜索 | P0 |
| CM-002 | 支持按银行机构筛选 | P0 |
| CM-003 | 支持按标签多选筛选 | P1 |
| CM-004 | 支持按创建时间范围筛选 | P1 |
| CM-005 | 支持表格列自定义显示/隐藏 | P1 |
| CM-006 | 支持表格列拖拽排序 | P1 |
| CM-007 | 支持多选客户进行批量操作 | P0 |
| CM-008 | 支持客户数据导出（Excel） | P0 |
| CM-009 | 支持客户数据批量导入（Excel） | P0 |
| CM-010 | 支持批量删除客户 | P0 |

**列表字段**：

| 字段名 | 字段代码 | 类型 | 说明 |
|--------|----------|------|------|
| 客户号 | customerNo | String | 唯一标识，系统自动生成 |
| 客户名称 | customerName | String | 客户姓名 |
| 性别 | gender | Enum | 男/女/未知 |
| 联系方式 | contactPhone | String | 手机号码 |
| 银行机构号 | orgCode | String | 所属银行机构编码 |
| 机构名称 | orgName | String | 所属银行机构名称 |
| 直营坐席工号 | seatNo | String | 负责坐席工号 |
| 坐席姓名 | seatName | String | 负责坐席姓名 |
| 标签 | tags | Array | 客户标签列表 |
| 备注 | remark | String | 备注信息 |
| 创建时间 | createTime | DateTime | 记录创建时间 |
| 更新时间 | updateTime | DateTime | 记录最后更新时间 |

---

#### 5.1.2 客户详情

**功能描述**：展示客户完整信息，包括基本信息、标签、跟进历史、关联数据等。

**页面布局**：

```
┌─────────────────────────────────────────────────────────┐
│  客户详情                                    [关闭]     │
├─────────────────────────────────────────────────────────┤
│  【基本信息】                                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 客户号：C202604200001    客户名称：张三          │   │
│  │ 性别：男                联系方式：138****1234   │   │
│  │ 银行机构：XX 银行分行    直营坐席：001(李四)    │   │
│  │ 标签：[VIP 客户] [高价值] [潜力客户]            │   │
│  │ 备注：重要客户，需重点维护                      │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  【标签管理】[编辑标签]                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 已有标签：VIP 客户  高价值  潜力客户             │   │
│  │ 添加标签：[选择标签 ▼]  [新增标签]              │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  【跟进历史】[新增跟进]                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 时间       坐席    跟进方式  跟进内容摘要       │   │
│  │ 2026-04-20 001   电话     了解客户需求...      │   │
│  │ 2026-04-19 002   短信     发送产品介绍...      │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  【关联数据】                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 关联场景：场景 A  关联任务：任务 B              │   │
│  │ 拨打次数：5 次   最后拨打：2026-04-20 10:30    │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CD-001 | 展示客户完整基本信息 | P0 |
| CD-002 | 支持编辑客户标签 | P1 |
| CD-003 | 展示跟进历史列表 | P1 |
| CD-004 | 支持新增跟进记录 | P1 |
| CD-005 | 展示客户关联场景/任务数据 | P2 |
| CD-006 | 展示客户拨打统计信息 | P2 |
| CD-007 | 支持从详情页直接分配客户 | P2 |
| CD-008 | 支持从详情页直接发起拨打 | P3 |

---

#### 5.1.3 客户新增/编辑

**功能描述**：支持新增客户或编辑现有客户信息。

**表单字段**：

| 字段名 | 必填 | 类型 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| 客户名称 | ✅ | 文本 | 2-50 字符 | 客户真实姓名 |
| 性别 | ✅ | 单选 | 必选 | 男/女/未知 |
| 联系方式 | ✅ | 文本 | 11 位手机号 | 用于联系客户的手机号 |
| 银行机构 | ✅ | 下拉 | 必选 | 从机构列表选择 |
| 直营坐席 | ❌ | 下拉 | - | 可选，分配给具体坐席 |
| 标签 | ❌ | 多选 | - | 从标签库选择 |
| 备注 | ❌ | 文本域 | 最多 500 字 | 补充说明信息 |

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CE-001 | 表单字段必填校验 | P0 |
| CE-002 | 手机号格式校验 | P0 |
| CE-003 | 客户号自动生成（编辑时不可改） | P0 |
| CE-004 | 银行机构从机构列表选择 | P0 |
| CE-005 | 标签支持多选和自定义新增 | P1 |
| CE-006 | 编辑时记录操作人和操作时间 | P1 |
| CE-007 | 支持草稿保存 | P3 |

---

#### 5.1.4 客户导入

**功能描述**：支持通过 Excel 文件批量导入客户数据。

**功能流程**：
1. 点击下载导入模板
2. 填写模板数据
3. 上传 Excel 文件
4. 数据预览与校验
5. 确认导入
6. 查看导入结果

**导入模板字段**：

| 序号 | 字段名 | 必填 | 校验规则 |
|------|--------|------|----------|
| 1 | 客户名称 | ✅ | 2-50 字符 |
| 2 | 性别 | ✅ | 男/女 |
| 3 | 联系方式 | ✅ | 11 位手机号 |
| 4 | 银行机构号 | ✅ | 有效机构编码 |
| 5 | 标签 | ❌ | 多标签用逗号分隔 |
| 6 | 备注 | ❌ | 最多 500 字 |

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CI-001 | 提供标准导入模板下载 | P0 |
| CI-002 | 支持 Excel 文件上传（.xlsx/.xls） | P0 |
| CI-003 | 文件大小限制（最大 10MB） | P0 |
| CI-004 | 数据格式校验（手机号、机构号等） | P0 |
| CI-005 | 重复数据检测（按手机号去重） | P0 |
| CI-006 | 导入前数据预览 | P0 |
| CI-007 | 显示导入进度 | P1 |
| CI-008 | 导入结果统计（成功/失败条数） | P0 |
| CI-009 | 失败数据下载（含失败原因） | P0 |
| CI-010 | 支持导入任务历史记录 | P2 |

---

#### 5.1.5 客户导出

**功能描述**：支持导出客户数据为 Excel 文件。

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CE-001 | 支持导出当前搜索结果 | P0 |
| CE-002 | 支持导出选中客户 | P0 |
| CE-003 | 支持导出全部客户 | P0 |
| CE-004 | 支持自定义导出字段 | P1 |
| CE-005 | 导出文件命名规范（客户数据_YYYYMMDD_HHMMSS.xlsx） | P1 |
| CE-006 | 大数据量异步导出（>10000 条） | P2 |
| CE-007 | 导出任务历史记录 | P2 |

---

#### 5.1.6 客户分配

**功能描述**：将客户分配给指定坐席进行跟进维护。

**分配方式**：
- 手动分配：单个或批量选择客户分配给坐席
- 自动分配：根据预设规则自动分配

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CA-001 | 支持单个客户分配 | P1 |
| CA-002 | 支持批量客户分配 | P1 |
| CA-003 | 分配时显示坐席列表（含负载情况） | P1 |
| CA-004 | 支持收回已分配客户 | P1 |
| CA-005 | 支持客户转移（坐席间转移） | P1 |
| CA-006 | 记录分配历史 | P1 |
| CA-007 | 自动分配规则配置 | P2 |
| CA-008 | 分配通知（站内信/短信） | P3 |

---

### 5.2 客群管理

#### 5.2.1 客群列表

**功能描述**：展示客群列表，支持搜索、筛选、统计信息展示。

**列表字段**：

| 字段名 | 说明 |
|--------|------|
| 客群编号 | 系统自动生成 |
| 客群名称 | 客群名称 |
| 客群类型 | 高价值客群/潜力客群/普通客群/流失客群 |
| 客户数量 | 该客群包含的客户数 |
| 创建方式 | 手动创建/规则创建/导入创建 |
| 创建人 | 创建该客群的用户 |
| 创建时间 | 创建时间 |
| 状态 | 启用/禁用 |

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CG-001 | 支持按客群名称搜索 | P0 |
| CG-002 | 支持按客群类型筛选 | P0 |
| CG-003 | 支持按创建时间范围筛选 | P1 |
| CG-004 | 支持按状态筛选 | P1 |
| CG-005 | 显示客群客户数量统计 | P0 |
| CG-006 | 支持客群启用/禁用 | P1 |

---

#### 5.2.2 客群创建

**创建方式**：
1. **手动创建**：从客户列表中选择客户加入客群
2. **规则创建**：配置筛选规则，自动匹配客户
3. **导入创建**：通过导入文件创建客群

**规则创建条件**：

| 条件类型 | 条件项 | 操作符 | 值类型 |
|----------|--------|--------|--------|
| 基础属性 | 性别 | = / ≠ / 包含 | 枚举 |
| 基础属性 | 年龄范围 | 介于 | 数字范围 |
| 基础属性 | 地区 | = / ≠ / 包含 | 枚举 |
| 标签属性 | 客户标签 | = / ≠ / 包含 | 枚举 |
| 行为属性 | 近 N 天拨打次数 | >/</= | 数字 |
| 行为属性 | 近 N 天联系次数 | >/</= | 数字 |
| 价值属性 | 客户价值等级 | = / ≠ / 包含 | 枚举 |
| 价值属性 | 资产规模 | >/</= | 数字 |

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CC-001 | 支持手动选择客户创建客群 | P0 |
| CC-002 | 支持规则配置创建客群 | P1 |
| CC-003 | 支持导入创建客群 | P0 |
| CC-004 | 规则支持多条件组合（AND/OR） | P1 |
| CC-005 | 规则创建时预览匹配客户数 | P1 |
| CC-006 | 支持保存常用规则模板 | P2 |

---

#### 5.2.3 客群数据统计

**统计维度**：
- 客户数量统计
- 客户分布（地区、年龄、性别等）
- 触达统计（拨打次数、接通率等）
- 转化统计（转化率、成交金额等）

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CS-001 | 展示客群客户数量趋势图 | P1 |
| CS-002 | 展示客户分布饼图 | P1 |
| CS-003 | 展示触达统计柱状图 | P1 |
| CS-004 | 展示转化统计漏斗图 | P2 |
| CS-005 | 支持统计数据导出 | P1 |

---

#### 5.2.4 数据批次管理

**功能描述**：管理批量导入的客户数据批次，追踪批次状态和数据质量。

**批次状态**：
- 待上传：批次创建，等待数据上传
- 处理中：数据正在导入处理
- 已完成：数据导入完成
- 失败：数据导入失败

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CB-001 | 展示数据批次列表 | P0 |
| CB-002 | 展示批次详细信息 | P0 |
| CB-003 | 展示批次数据统计（总量/成功/失败） | P0 |
| CB-004 | 支持批次数据导出 | P0 |
| CB-005 | 支持批次数据删除 | P0 |
| CB-006 | 支持批次数据重新导入 | P1 |
| CB-007 | 批次处理进度实时展示 | P1 |

---

### 5.3 跟进管理

#### 5.3.1 跟进记录列表

**功能描述**：展示客户跟进记录，支持搜索、筛选。

**列表字段**：

| 字段名 | 说明 |
|--------|------|
| 跟进编号 | 系统生成 |
| 客户名称 | 被跟进的客户 |
| 跟进方式 | 电话/短信/微信/面谈/其他 |
| 跟进内容 | 跟进内容摘要 |
| 跟进坐席 | 执行跟进的坐席 |
| 跟进时间 | 跟进发生时间 |
| 下次联系时间 | 计划下次联系时间 |

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| FL-001 | 支持按客户名称搜索 | P0 |
| FL-002 | 支持按跟进方式筛选 | P0 |
| FL-003 | 支持按跟进坐席筛选 | P0 |
| FL-004 | 支持按跟进时间范围筛选 | P0 |
| FL-005 | 支持按下次联系时间筛选 | P1 |
| FL-006 | 支持查看跟进详情 | P0 |

---

#### 5.3.2 跟进记录新增

**功能描述**：记录与客户的跟进情况。

**表单字段**：

| 字段名 | 必填 | 类型 | 说明 |
|--------|------|------|------|
| 客户 | ✅ | 选择 | 选择要跟进的客户 |
| 跟进方式 | ✅ | 单选 | 电话/短信/微信/面谈/其他 |
| 跟进内容 | ✅ | 文本域 | 详细记录跟进内容 |
| 跟进结果 | ❌ | 单选 | 成功/失败/待跟进 |
| 备注说明 | ❌ | 文本域 | 补充说明 |
| 下次联系时间 | ❌ | 日期 | 计划下次联系时间 |
| 附件上传 | ❌ | 文件 | 录音/截图等附件 |

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| FA-001 | 支持从客户详情页快速新增跟进 | P0 |
| FA-002 | 支持独立页面新增跟进 | P0 |
| FA-003 | 跟进内容必填校验 | P0 |
| FA-004 | 支持附件上传（录音/图片） | P1 |
| FA-005 | 自动记录跟进坐席和时间 | P0 |
| FA-006 | 支持跟进记录编辑（24 小时内） | P1 |
| FA-007 | 支持跟进记录删除（仅本人） | P1 |

---

#### 5.3.3 跟进计划

**功能描述**：制定客户跟进计划，提醒坐席按时联系客户。

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| FP-001 | 展示待跟进客户列表 | P1 |
| FP-002 | 展示今日需跟进客户 | P1 |
| FP-003 | 展示逾期跟进提醒 | P1 |
| FP-004 | 支持标记跟进完成 | P1 |
| FP-005 | 支持跟进计划排序（按优先级） | P2 |
| FP-006 | 支持跟进计划提醒（站内信） | P2 |

---

### 5.4 客户画像

#### 5.4.1 基本信息

**展示内容**：
- 客户基础信息（姓名、性别、联系方式等）
- 账户信息（客户号、开户时间等）
- 机构信息（所属机构、负责坐席等）

---

#### 5.4.2 标签画像

**展示内容**：
- 基础标签：性别、年龄段、地区等
- 价值标签：VIP 客户、高价值客户、潜力客户等
- 行为标签：活跃客户、沉睡客户、流失风险等
- 自定义标签：用户自定义标签

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CP-001 | 标签分类展示 | P1 |
| CP-002 | 支持标签权重显示 | P2 |
| CP-003 | 支持标签时间轴展示（标签变化历史） | P2 |
| CP-004 | 支持手动添加/删除标签 | P1 |

---

#### 5.4.3 行为轨迹

**展示内容**：
- 拨打记录：拨打时间、拨打时长、拨打结果
- 短信记录：发送时间、短信内容、发送状态
- 微信记录：聊天时间、聊天内容摘要
- 面谈记录：面谈时间、面谈地点、面谈内容

**功能需求**：

| 需求 ID | 需求描述 | 优先级 |
|--------|----------|--------|
| CT-001 | 行为记录时间轴展示 | P1 |
| CT-002 | 支持按行为类型筛选 | P1 |
| CT-003 | 支持按时间范围筛选 | P1 |
| CT-004 | 支持查看行为详情 | P1 |

---

#### 5.4.4 跟进历史

**展示内容**：
- 历史跟进记录列表
- 跟进统计（跟进次数、跟进方式分布等）
- 跟进趋势图

---

#### 5.4.5 关联数据

**展示内容**：
- 关联场景：客户参与的业务场景
- 关联任务：客户相关的任务列表
- 关联合同：客户签订的合同/协议
- 关联产品：客户购买/咨询的产品

---

### 5.5 统计分析

#### 5.5.1 客户概览

**展示内容**：
- 客户总数、今日新增、本月新增
- 客户分布（机构、地区、标签等）
- 客户状态分布（活跃、沉睡、流失等）

**图表要求**：
- 关键指标卡片
- 客户趋势折线图
- 客户分布饼图

---

#### 5.5.2 客户增长分析

**分析维度**：
- 新增客户趋势（日/周/月）
- 新增客户来源分析
- 新增客户质量分析

---

#### 5.5.3 客户价值分析

**分析维度**：
- 客户价值等级分布
- 高价值客户趋势
- 客户贡献度分析

---

#### 5.5.4 流失预警分析

**分析维度**：
- 流失风险客户列表
- 流失原因分析
- 流失预警模型

---

## 6. 数据结构设计

### 6.1 客户表 (t_customer)

```sql
CREATE TABLE t_customer (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键 ID',
    customer_no     VARCHAR(32) NOT NULL COMMENT '客户号',
    customer_name   VARCHAR(50) NOT NULL COMMENT '客户名称',
    gender          TINYINT DEFAULT 0 COMMENT '性别 0-未知 1-男 2-女',
    contact_phone   VARCHAR(20) COMMENT '联系方式',
    contact_email   VARCHAR(100) COMMENT '联系邮箱',
    org_code        VARCHAR(32) COMMENT '银行机构号',
    org_name        VARCHAR(100) COMMENT '机构名称',
    seat_no         VARCHAR(32) COMMENT '直营坐席工号',
    seat_name       VARCHAR(50) COMMENT '坐席姓名',
    tags            JSON COMMENT '标签列表',
    remark          VARCHAR(500) COMMENT '备注',
    status          TINYINT DEFAULT 1 COMMENT '状态 0-禁用 1-启用',
    create_by       VARCHAR(32) COMMENT '创建人',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by       VARCHAR(32) COMMENT '更新人',
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted         TINYINT DEFAULT 0 COMMENT '删除标记 0-未删除 1-已删除',
    
    UNIQUE KEY uk_customer_no (customer_no),
    KEY idx_contact_phone (contact_phone),
    KEY idx_org_code (org_code),
    KEY idx_seat_no (seat_no),
    KEY idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户表';
```

---

### 6.2 客群表 (t_customer_group)

```sql
CREATE TABLE t_customer_group (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键 ID',
    group_no        VARCHAR(32) NOT NULL COMMENT '客群编号',
    group_name      VARCHAR(100) NOT NULL COMMENT '客群名称',
    group_type      TINYINT COMMENT '客群类型 1-高价值 2-潜力 3-普通 4-流失',
    create_type     TINYINT DEFAULT 1 COMMENT '创建方式 1-手动 2-规则 3-导入',
    rule_config     JSON COMMENT '规则配置（规则创建时）',
    customer_count  INT DEFAULT 0 COMMENT '客户数量',
    status          TINYINT DEFAULT 1 COMMENT '状态 0-禁用 1-启用',
    create_by       VARCHAR(32) COMMENT '创建人',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_by       VARCHAR(32) COMMENT '更新人',
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted         TINYINT DEFAULT 0 COMMENT '删除标记',
    
    UNIQUE KEY uk_group_no (group_no),
    KEY idx_group_type (group_type),
    KEY idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客群表';
```

---

### 6.3 客群客户关联表 (t_group_customer_rel)

```sql
CREATE TABLE t_group_customer_rel (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键 ID',
    group_id        BIGINT NOT NULL COMMENT '客群 ID',
    customer_id     BIGINT NOT NULL COMMENT '客户 ID',
    join_type       TINYINT DEFAULT 1 COMMENT '加入方式 1-手动 2-规则 3-导入',
    join_time       DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    join_by         VARCHAR(32) COMMENT '加入人',
    
    UNIQUE KEY uk_group_customer (group_id, customer_id),
    KEY idx_customer_id (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客群客户关联表';
```

---

### 6.4 跟进记录表 (t_follow_record)

```sql
CREATE TABLE t_follow_record (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键 ID',
    record_no       VARCHAR(32) NOT NULL COMMENT '跟进编号',
    customer_id     BIGINT NOT NULL COMMENT '客户 ID',
    customer_name   VARCHAR(50) COMMENT '客户名称（冗余）',
    follow_type     TINYINT COMMENT '跟进方式 1-电话 2-短信 3-微信 4-面谈 5-其他',
    follow_content  TEXT NOT NULL COMMENT '跟进内容',
    follow_result   TINYINT COMMENT '跟进结果 1-成功 2-失败 3-待跟进',
    remark          VARCHAR(500) COMMENT '备注说明',
    next_contact_time DATETIME COMMENT '下次联系时间',
    attachments     JSON COMMENT '附件列表',
    seat_no         VARCHAR(32) COMMENT '跟进坐席工号',
    seat_name       VARCHAR(50) COMMENT '跟进坐席姓名',
    follow_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '跟进时间',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted         TINYINT DEFAULT 0 COMMENT '删除标记',
    
    UNIQUE KEY uk_record_no (record_no),
    KEY idx_customer_id (customer_id),
    KEY idx_seat_no (seat_no),
    KEY idx_follow_time (follow_time),
    KEY idx_next_contact_time (next_contact_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='跟进记录表';
```

---

### 6.5 客户标签表 (t_customer_tag)

```sql
CREATE TABLE t_customer_tag (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键 ID',
    tag_code        VARCHAR(32) NOT NULL COMMENT '标签编码',
    tag_name        VARCHAR(50) NOT NULL COMMENT '标签名称',
    tag_category    TINYINT COMMENT '标签分类 1-基础 2-价值 3-行为 4-自定义',
    tag_color       VARCHAR(20) COMMENT '标签颜色',
    tag_weight      INT DEFAULT 0 COMMENT '标签权重',
    description     VARCHAR(200) COMMENT '标签描述',
    status          TINYINT DEFAULT 1 COMMENT '状态 0-禁用 1-启用',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY uk_tag_code (tag_code),
    KEY idx_category (tag_category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户标签表';
```

---

### 6.6 数据批次表 (t_data_batch)

```sql
CREATE TABLE t_data_batch (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键 ID',
    batch_no        VARCHAR(32) NOT NULL COMMENT '批次编号',
    batch_name      VARCHAR(100) NOT NULL COMMENT '批次名称',
    org_code        VARCHAR(32) COMMENT '机构号',
    org_name        VARCHAR(100) COMMENT '机构名称',
    scene_no        VARCHAR(32) COMMENT '场景编号',
    scene_name      VARCHAR(100) COMMENT '场景名称',
    task_id         VARCHAR(32) COMMENT '任务 ID',
    total_count     INT DEFAULT 0 COMMENT '数据总量',
    valid_count     INT DEFAULT 0 COMMENT '去重后有效量',
    dialed_count    INT DEFAULT 0 COMMENT '已拨打量',
    contact_type    VARCHAR(50) COMMENT '联系方式类型',
    batch_type      TINYINT COMMENT '批次类型 1-导入 2-手动 3-API',
    source          VARCHAR(50) COMMENT '数据来源',
    upload_by       VARCHAR(32) COMMENT '上传人',
    upload_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    status          TINYINT DEFAULT 0 COMMENT '状态 0-待上传 1-处理中 2-已完成 3-失败',
    start_date      DATE COMMENT '开始拨打日期',
    end_date        DATE COMMENT '结束拨打日期',
    dnc_count       INT DEFAULT 0 COMMENT '免打扰数量',
    anti_harass_count INT DEFAULT 0 COMMENT '防骚扰数量',
    remark          VARCHAR(500) COMMENT '批次说明',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted         TINYINT DEFAULT 0 COMMENT '删除标记',
    
    UNIQUE KEY uk_batch_no (batch_no),
    KEY idx_org_code (org_code),
    KEY idx_status (status),
    KEY idx_upload_time (upload_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据批次表';
```

---

### 6.7 客户分配历史表 (t_customer_assign_history)

```sql
CREATE TABLE t_customer_assign_history (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键 ID',
    customer_id     BIGINT NOT NULL COMMENT '客户 ID',
    from_seat_no    VARCHAR(32) COMMENT '原坐席工号',
    to_seat_no      VARCHAR(32) NOT NULL COMMENT '新坐席工号',
    assign_type     TINYINT COMMENT '分配类型 1-新分配 2-转移 3-收回',
    assign_by       VARCHAR(32) COMMENT '分配人',
    assign_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '分配时间',
    remark          VARCHAR(200) COMMENT '分配说明',
    
    KEY idx_customer_id (customer_id),
    KEY idx_assign_time (assign_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户分配历史表';
```

---

## 7. 接口需求

### 7.1 客户管理接口

| 接口编号 | 接口名称 | 请求方式 | 接口路径 | 优先级 |
|----------|----------|----------|----------|--------|
| API-CM-001 | 获取客户列表 | GET | /api/customer/list | P0 |
| API-CM-002 | 获取客户详情 | GET | /api/customer/{id} | P0 |
| API-CM-003 | 新增客户 | POST | /api/customer | P0 |
| API-CM-004 | 编辑客户 | PUT | /api/customer/{id} | P0 |
| API-CM-005 | 删除客户 | DELETE | /api/customer/{id} | P0 |
| API-CM-006 | 批量删除客户 | DELETE | /api/customer/batch | P0 |
| API-CM-007 | 客户导入 | POST | /api/customer/import | P0 |
| API-CM-008 | 客户导出 | POST | /api/customer/export | P0 |
| API-CM-009 | 导入模板下载 | GET | /api/customer/import-template | P0 |
| API-CM-010 | 客户分配 | POST | /api/customer/assign | P1 |
| API-CM-011 | 客户转移 | POST | /api/customer/transfer | P1 |
| API-CM-012 | 获取客户标签列表 | GET | /api/customer/tags | P1 |
| API-CM-013 | 更新客户标签 | PUT | /api/customer/{id}/tags | P1 |

---

### 7.2 客群管理接口

| 接口编号 | 接口名称 | 请求方式 | 接口路径 | 优先级 |
|----------|----------|----------|----------|--------|
| API-CG-001 | 获取客群列表 | GET | /api/customer-group/list | P0 |
| API-CG-002 | 获取客群详情 | GET | /api/customer-group/{id} | P0 |
| API-CG-003 | 新增客群 | POST | /api/customer-group | P0 |
| API-CG-004 | 编辑客群 | PUT | /api/customer-group/{id} | P0 |
| API-CG-005 | 删除客群 | DELETE | /api/customer-group/{id} | P0 |
| API-CG-006 | 客群客户列表 | GET | /api/customer-group/{id}/customers | P0 |
| API-CG-007 | 添加客户到客群 | POST | /api/customer-group/{id}/customers | P0 |
| API-CG-008 | 从客群移除客户 | DELETE | /api/customer-group/{id}/customers/{customerId} | P0 |
| API-CG-009 | 客群规则匹配预览 | POST | /api/customer-group/rule/preview | P1 |
| API-CG-010 | 客群统计信息 | GET | /api/customer-group/{id}/statistics | P1 |
| API-CG-011 | 客群启用/禁用 | PUT | /api/customer-group/{id}/status | P1 |

---

### 7.3 跟进管理接口

| 接口编号 | 接口名称 | 请求方式 | 接口路径 | 优先级 |
|----------|----------|----------|----------|--------|
| API-FL-001 | 获取跟进记录列表 | GET | /api/follow-record/list | P0 |
| API-FL-002 | 获取跟进记录详情 | GET | /api/follow-record/{id} | P0 |
| API-FL-003 | 新增跟进记录 | POST | /api/follow-record | P0 |
| API-FL-004 | 编辑跟进记录 | PUT | /api/follow-record/{id} | P1 |
| API-FL-005 | 删除跟进记录 | DELETE | /api/follow-record/{id} | P1 |
| API-FL-006 | 获取待跟进列表 | GET | /api/follow-record/pending | P1 |
| API-FL-007 | 标记跟进完成 | PUT | /api/follow-record/{id}/complete | P1 |
| API-FL-008 | 跟进统计信息 | GET | /api/follow-record/statistics | P1 |

---

### 7.4 客户画像接口

| 接口编号 | 接口名称 | 请求方式 | 接口路径 | 优先级 |
|----------|----------|----------|----------|--------|
| API-CP-001 | 获取客户画像 | GET | /api/customer-portrait/{customerId} | P1 |
| API-CP-002 | 获取客户标签画像 | GET | /api/customer-portrait/{customerId}/tags | P1 |
| API-CP-003 | 获取客户行为轨迹 | GET | /api/customer-portrait/{customerId}/behaviors | P1 |
| API-CP-004 | 获取客户跟进历史 | GET | /api/customer-portrait/{customerId}/follow-history | P1 |
| API-CP-005 | 获取客户关联数据 | GET | /api/customer-portrait/{customerId}/relations | P2 |

---

### 7.5 统计分析接口

| 接口编号 | 接口名称 | 请求方式 | 接口路径 | 优先级 |
|----------|----------|----------|----------|--------|
| API-ST-001 | 客户概览统计 | GET | /api/customer-stats/overview | P1 |
| API-ST-002 | 客户增长趋势 | GET | /api/customer-stats/growth-trend | P1 |
| API-ST-003 | 客户分布统计 | GET | /api/customer-stats/distribution | P1 |
| API-ST-004 | 客户价值分析 | GET | /api/customer-stats/value-analysis | P2 |
| API-ST-005 | 流失预警分析 | GET | /api/customer-stats/churn-warning | P2 |

---

### 7.6 数据批次接口

| 接口编号 | 接口名称 | 请求方式 | 接口路径 | 优先级 |
|----------|----------|----------|----------|--------|
| API-DB-001 | 获取数据批次列表 | GET | /api/data-batch/list | P0 |
| API-DB-002 | 获取数据批次详情 | GET | /api/data-batch/{id} | P0 |
| API-DB-003 | 新增数据批次 | POST | /api/data-batch | P0 |
| API-DB-004 | 编辑数据批次 | PUT | /api/data-batch/{id} | P0 |
| API-DB-005 | 删除数据批次 | DELETE | /api/data-batch/{id} | P0 |
| API-DB-006 | 批次数据统计 | GET | /api/data-batch/{id}/statistics | P0 |
| API-DB-007 | 批次数据导出 | POST | /api/data-batch/{id}/export | P0 |
| API-DB-008 | 批次进度查询 | GET | /api/data-batch/{id}/progress | P1 |

---

## 8. 非功能性需求

### 8.1 性能需求

| 需求项 | 指标要求 | 说明 |
|--------|----------|------|
| 列表加载时间 | < 2 秒 | 万级数据量下 |
| 详情加载时间 | < 1 秒 | 包含关联数据 |
| 导入处理速度 | > 1000 条/分钟 | 批量导入 |
| 导出响应时间 | < 5 秒 | 千级数据量 |
| 并发用户数 | > 100 | 同时在线操作 |

---

### 8.2 安全需求

| 需求项 | 要求 | 说明 |
|--------|------|------|
| 数据权限 | 基于角色的数据可见性 | 坐席仅可见分配给自己的客户 |
| 操作审计 | 所有增删改操作记录日志 | 记录操作人、时间、内容 |
| 数据脱敏 | 敏感信息脱敏展示 | 手机号中间 4 位脱敏 |
| 接口鉴权 | 所有接口需身份验证 | Token 验证 |
| 防重放攻击 | 关键操作防重放 | 导入、删除等操作 |

---

### 8.3 可用性需求

| 需求项 | 指标 | 说明 |
|--------|------|------|
| 系统可用性 | > 99.9% | 工作日 9:00-18:00 |
| 数据准确性 | 100% | 数据计算准确 |
| 错误恢复 | < 5 分钟 | 异常后快速恢复 |
| 数据备份 | 每日备份 | 防止数据丢失 |

---

### 8.4 兼容性需求

| 需求项 | 要求 |
|--------|------|
| 浏览器 | Chrome 80+、Edge 80+、Firefox 75+ |
| 分辨率 | 1920×1080 及以上 |
| 移动端 | 暂不支持 |

---

### 8.5 可维护性需求

| 需求项 | 要求 |
|--------|------|
| 代码规范 | 遵循 Vue 3 + TypeScript 规范 |
| 注释要求 | 关键逻辑注释覆盖率 > 80% |
| 日志规范 | 统一日志格式，支持日志级别 |
| 接口文档 | 提供完整的 API 文档 |

---

## 9. UI/UX 要求

### 9.1 设计规范

- **UI 框架**：Ant Design Vue 4.x
- **主题色**：沿用系统主色调（蓝色系）
- **字体**：系统默认字体，字号 14px 为主
- **间距**：统一使用 8px 倍数间距

---

### 9.2 交互规范

| 场景 | 交互要求 |
|------|----------|
| 列表加载 | 显示 Loading 骨架屏 |
| 操作成功 | Toast 提示，3 秒自动消失 |
| 操作失败 | Toast 提示，显示失败原因 |
| 删除操作 | 二次确认弹窗 |
| 表单校验 | 实时校验，错误提示清晰 |
| 数据为空 | 显示空状态插图和引导文案 |

---

### 9.3 页面布局规范

**列表页布局**：
```
┌────────────────────────────────────────────┐
│  页面标题                                   │
├────────────────────────────────────────────┤
│  搜索栏（可折叠）                          │
├────────────────────────────────────────────┤
│  工具栏（操作按钮）                        │
├────────────────────────────────────────────┤
│  数据表格                                  │
├────────────────────────────────────────────┤
│  分页器                                    │
└────────────────────────────────────────────┘
```

**详情页布局**：
```
┌────────────────────────────────────────────┐
│  返回按钮  页面标题          [操作按钮]    │
├────────────────────────────────────────────┤
│  信息卡片 1                                 │
├────────────────────────────────────────────┤
│  信息卡片 2                                 │
├────────────────────────────────────────────┤
│  列表/图表区域                              │
└────────────────────────────────────────────┘
```

---

### 9.4 响应式要求

- 表格支持横向滚动
- 弹窗自适应屏幕大小
- 表单字段在小屏下自动换行

---

## 10. 版本规划

### 10.1 版本计划

| 版本 | 功能范围 | 预计周期 |
|------|----------|----------|
| **v1.0** | 客户管理基础功能（列表/详情/新增/编辑/删除） | 2 周 |
| **v1.1** | 客户导入/导出、客户分配 | 2 周 |
| **v1.2** | 客群管理（列表/创建/规则/统计） | 3 周 |
| **v1.3** | 跟进管理（记录/计划/统计） | 2 周 |
| **v1.4** | 客户画像（基本信息/标签/行为） | 2 周 |
| **v1.5** | 统计分析（概览/增长/价值/流失） | 2 周 |

---

### 10.2 迭代优先级

**第一阶段（v1.0-v1.1）**：夯实基础
- 完善客户管理基础功能
- 实现批量导入导出能力
- 建立客户分配机制

**第二阶段（v1.2-v1.3）**：精细运营
- 搭建客群管理体系
- 建立跟进记录机制
- 支持跟进计划提醒

**第三阶段（v1.4-v1.5）**：数据驱动
- 完善客户画像
- 建设统计分析能力
- 支持数据决策

---

## 附录

### 附录 A：字段字典

**性别字典**：
| 代码 | 名称 |
|------|------|
| 0 | 未知 |
| 1 | 男 |
| 2 | 女 |

**客群类型字典**：
| 代码 | 名称 |
|------|------|
| 1 | 高价值客群 |
| 2 | 潜力客群 |
| 3 | 普通客群 |
| 4 | 流失客群 |

**跟进方式字典**：
| 代码 | 名称 |
|------|------|
| 1 | 电话 |
| 2 | 短信 |
| 3 | 微信 |
| 4 | 面谈 |
| 5 | 其他 |

---

### 附录 B：参考文档

- [数据市场需求规格说明书](./PRD/数据市场需求规格说明书.md)
- [智能质检技术方案](./PRD/智能质检技术方案.md)

---

### 附录 C：修订历史

| 版本 | 修订日期 | 修订人 | 修订内容 |
|------|----------|--------|----------|
| v1.0 | 2026-04-20 | - | 初始版本创建 |

---

**文档结束**
