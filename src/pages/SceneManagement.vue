<template>
  <div class="scene-management">
    <!-- 顶部工具栏 - 放在标签页上方 -->
    <div class="top-toolbar">
      <a-space class="toolbar-actions">
        <a-button @click="handleImportScene">
          <template #icon><import-outlined /></template>
          导入场景
        </a-button>
        <a-button type="primary" @click="handleCreateScene">
          <template #icon><plus-outlined /></template>
          创建场景
        </a-button>
        <a-button type="primary" class="scene-shop-btn" @click="handleOpenSceneShop">
          <template #icon><shop-outlined /></template>
          场景小店
        </a-button>
      </a-space>
      <!-- 隐藏的文件输入框，用于导入场景 -->
      <input
        ref="fileInputRef"
        type="file"
        accept=".json,.xml"
        style="display: none"
        @change="handleFileChange"
      />
    </div>

    <!-- 顶部标签页 -->
    <a-tabs v-model:activeKey="activeTab" class="scene-tabs">
      <a-tab-pane key="active" tab="开启场景">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-row :gutter="[16, 16]">
            <!-- 第一行 -->
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.institution"
                placeholder="请选择机构"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="hzbank">杭州银行</a-select-option>
                <a-select-option value="nbbank">宁波银行</a-select-option>
                <a-select-option value="shbank">上海银行</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.sceneName"
                placeholder="请输入场景名称搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.creator"
                placeholder="请输入创建者搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.templateType"
                placeholder="请选择模版类型"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="collection">催收模版</a-select-option>
                <a-select-option value="marketing">营销模版</a-select-option>
                <a-select-option value="service">服务模版</a-select-option>
              </a-select>
            </a-col>
            <!-- 第二行 -->
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.templateSubtype"
                placeholder="请选择模版子类型"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="loan">贷款类</a-select-option>
                <a-select-option value="credit_card">信用卡类</a-select-option>
                <a-select-option value="deposit">存款类</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.publishedToShop"
                placeholder="是否上架场景小店"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="true">已上架</a-select-option>
                <a-select-option value="false">未上架</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.sceneCode"
                placeholder="请输入场景编号搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-space>
                <a-button type="primary" @click="handleSearch">
                  <search-outlined />
                  搜索
                </a-button>
                <a-button @click="handleReset">
                  <reload-outlined />
                  重置
                </a-button>
              </a-space>
            </a-col>
          </a-row>
        </div>

        <!-- 操作按钮区域 -->
        <div class="toolbar-area">
          <div class="toolbar-left">
            <span class="total-info">共 {{ activeSceneList.length }} 条</span>
          </div>
          <div class="toolbar-right">
            <a-select
              v-model:value="sortOrder"
              placeholder="按编辑时间排序"
              style="width: 180px"
            >
              <a-select-option value="desc">编辑时间降序</a-select-option>
              <a-select-option value="asc">编辑时间升序</a-select-option>
            </a-select>
          </div>
        </div>

        <!-- 场景卡片列表 - 每个卡片单独一行 -->
        <div class="scene-list">
          <div v-for="scene in activeSceneList" :key="scene.id" class="scene-card-row">
            <div class="scene-card">
              <!-- 卡片头部 -->
              <div class="card-header">
                <div class="header-left">
                  <div class="scene-title">
                    <span class="title-indicator"></span>
                    <span class="title-text">{{ scene.name }}</span>
                  </div>
                  <a-tag v-if="scene.tag" :color="scene.tagColor">{{ scene.tag }}</a-tag>
                  <!-- 已发布到场景小店的标识 -->
                  <a-tag v-if="scene.publishedToShop" color="purple">
                    <template #icon><shop-outlined /></template>
                    场景小店已发布
                  </a-tag>
                </div>
                <!-- 右上角操作区 -->
                <div class="header-right">
                  <!-- 发布至场景小店按钮 -->
                  <a-button
                    v-if="!scene.publishedToShop"
                    type="primary"
                    size="small"
                    class="publish-shop-btn header-btn"
                    @click="handlePublishToShop(scene)"
                  >
                    <template #icon><upload-outlined /></template>
                    发布至场景小店
                  </a-button>
                  <!-- 从场景小店下架按钮（已发布时显示） -->
                  <a-button
                    v-else
                    type="default"
                    size="small"
                    class="unpublish-shop-btn header-btn"
                    @click="handleUnpublishFromShop(scene)"
                  >
                    <template #icon><logout-outlined /></template>
                    从场景小店下架
                  </a-button>
                  <!-- 启用开关 -->
                  <div class="enable-switch-wrapper">
                    <a-switch
                      v-model:checked="scene.enabled"
                      size="default"
                      @change="handleEnabledChange(scene)"
                    />
                  </div>
                </div>
              </div>

              <!-- 卡片内容 -->
              <div class="card-body">
                <div class="body-wrapper">
                  <!-- 左侧信息区 -->
                  <div class="body-left">
                    <div class="info-grid">
                      <!-- 第一行 -->
                      <div class="info-row">
                        <div class="info-item">
                          <span class="label">语音类型：</span>
                          <span class="value">{{ scene.voiceType }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">跟进方式：</span>
                          <span class="value">{{ scene.followUpMethod }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">到期时间：</span>
                          <span class="value">{{ scene.expireTime }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">平台版本/行方版本：</span>
                          <span class="value">{{ scene.platformVersion }}</span>
                        </div>
                      </div>
                      <!-- 第二行 -->
                      <div class="info-row">
                        <div class="info-item">
                          <span class="label">场景编号：</span>
                          <span class="value">{{ scene.code }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">创建时间：</span>
                          <span class="value">{{ scene.createTime }}</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 右侧操作按钮区 -->
                  <div class="body-right">
                    <div class="action-grid">
                      <a class="action-link" @click="handleView(scene)">查看</a>
                      <a class="action-link" @click="handleExport(scene)">导出</a>
                      <a class="action-link" @click="handleCopy(scene)">复制</a>
                      <a class="action-link danger" @click="handleDelete(scene)">删除</a>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 底部操作链接 -->
              <div class="card-footer">
                <a class="footer-link blue" @click="handleSceneCheck(scene)">场景检测</a>
                <a class="footer-link blue" @click="handleScriptCheck(scene)">话术完整性检查</a>
                <a class="footer-link blue" @click="handleViewTimeSlot(scene)">查看拨打时间段</a>
                <a class="footer-link blue" @click="handleAddDataBatch(scene)">添加数据批次</a>
                <a class="footer-link blue" @click="handleQuickTest(scene)">快速拨测</a>
                <a class="footer-link blue" @click="handleScriptTest(scene)">话术测试</a>
                <a class="footer-link blue" @click="handleReport(scene)">场景报表</a>
              </div>
            </div>
          </div>
        </div>
      </a-tab-pane>

      <a-tab-pane key="closed" tab="关闭场景">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-row :gutter="[16, 16]">
            <!-- 第一行 -->
            <a-col :span="6">
              <a-select
                v-model:value="closedSearchForm.institution"
                placeholder="请选择机构"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="hzbank">杭州银行</a-select-option>
                <a-select-option value="nbbank">宁波银行</a-select-option>
                <a-select-option value="shbank">上海银行</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="closedSearchForm.sceneName"
                placeholder="请输入场景名称搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="closedSearchForm.creator"
                placeholder="请输入创建者搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-select
                v-model:value="closedSearchForm.templateType"
                placeholder="请选择模版类型"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="collection">催收模版</a-select-option>
                <a-select-option value="marketing">营销模版</a-select-option>
                <a-select-option value="service">服务模版</a-select-option>
              </a-select>
            </a-col>
            <!-- 第二行 -->
            <a-col :span="6">
              <a-select
                v-model:value="closedSearchForm.templateSubtype"
                placeholder="请选择模版子类型"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="loan">贷款类</a-select-option>
                <a-select-option value="credit_card">信用卡类</a-select-option>
                <a-select-option value="deposit">存款类</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-select
                v-model:value="closedSearchForm.publishedToShop"
                placeholder="是否上架场景小店"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="true">已上架</a-select-option>
                <a-select-option value="false">未上架</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="closedSearchForm.sceneCode"
                placeholder="请输入场景编号搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-space>
                <a-button type="primary" @click="handleClosedSearch">
                  <search-outlined />
                  搜索
                </a-button>
                <a-button @click="handleClosedReset">
                  <reload-outlined />
                  重置
                </a-button>
              </a-space>
            </a-col>
          </a-row>
        </div>

        <!-- 操作按钮区域 -->
        <div class="toolbar-area">
          <div class="toolbar-left">
            <span class="total-info">共 {{ closedSceneList.length }} 条</span>
          </div>
          <div class="toolbar-right">
            <a-select
              v-model:value="closedSortOrder"
              placeholder="按编辑时间排序"
              style="width: 180px"
            >
              <a-select-option value="desc">编辑时间降序</a-select-option>
              <a-select-option value="asc">编辑时间升序</a-select-option>
            </a-select>
          </div>
        </div>

        <!-- 场景卡片列表 -->
        <div class="scene-list">
          <div v-for="scene in closedSceneList" :key="scene.id" class="scene-card-row">
            <div class="scene-card">
              <!-- 卡片头部 -->
              <div class="card-header">
                <div class="header-left">
                  <div class="scene-title">
                    <span class="title-indicator"></span>
                    <span class="title-text">{{ scene.name }}</span>
                  </div>
                  <a-tag v-if="scene.tag" :color="scene.tagColor">{{ scene.tag }}</a-tag>
                  <!-- 已发布到场景小店的标识 -->
                  <a-tag v-if="scene.publishedToShop" color="purple">
                    <template #icon><shop-outlined /></template>
                    场景小店已发布
                  </a-tag>
                </div>
                <!-- 右上角操作区 -->
                <div class="header-right">
                  <!-- 发布至场景小店按钮 -->
                  <a-button
                    v-if="!scene.publishedToShop"
                    type="primary"
                    size="small"
                    class="publish-shop-btn header-btn"
                    @click="handlePublishToShop(scene)"
                  >
                    <template #icon><upload-outlined /></template>
                    发布至场景小店
                  </a-button>
                  <!-- 从场景小店下架按钮（已发布时显示） -->
                  <a-button
                    v-else
                    type="default"
                    size="small"
                    class="unpublish-shop-btn header-btn"
                    @click="handleUnpublishFromShop(scene)"
                  >
                    <template #icon><logout-outlined /></template>
                    从场景小店下架
                  </a-button>
                  <!-- 启用开关 -->
                  <div class="enable-switch-wrapper">
                    <a-switch
                      v-model:checked="scene.enabled"
                      size="default"
                      @change="handleEnabledChange(scene)"
                    />
                  </div>
                </div>
              </div>

              <!-- 卡片内容 -->
              <div class="card-body">
                <div class="body-wrapper">
                  <!-- 左侧信息区 -->
                  <div class="body-left">
                    <div class="info-grid">
                      <!-- 第一行 -->
                      <div class="info-row">
                        <div class="info-item">
                          <span class="label">语音类型：</span>
                          <span class="value">{{ scene.voiceType }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">跟进方式：</span>
                          <span class="value">{{ scene.followUpMethod }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">到期时间：</span>
                          <span class="value">{{ scene.expireTime }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">平台版本/行方版本：</span>
                          <span class="value">{{ scene.platformVersion }}</span>
                        </div>
                      </div>
                      <!-- 第二行 -->
                      <div class="info-row">
                        <div class="info-item">
                          <span class="label">场景编号：</span>
                          <span class="value">{{ scene.code }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">创建时间：</span>
                          <span class="value">{{ scene.createTime }}</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 右侧操作按钮区 -->
                  <div class="body-right">
                    <div class="action-grid">
                      <a class="action-link" @click="handleView(scene)">查看</a>
                      <a class="action-link" @click="handleExport(scene)">导出</a>
                      <a class="action-link" @click="handleCopy(scene)">复制</a>
                      <a class="action-link danger" @click="handleDelete(scene)">删除</a>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 底部操作链接 -->
              <div class="card-footer">
                <a class="footer-link blue" @click="handleSceneCheck(scene)">场景检测</a>
                <a class="footer-link blue" @click="handleScriptCheck(scene)">话术完整性检查</a>
                <a class="footer-link blue" @click="handleViewTimeSlot(scene)">查看拨打时间段</a>
                <a class="footer-link blue" @click="handleAddDataBatch(scene)">添加数据批次</a>
                <a class="footer-link blue" @click="handleQuickTest(scene)">快速拨测</a>
                <a class="footer-link blue" @click="handleScriptTest(scene)">话术测试</a>
                <a class="footer-link blue" @click="handleReport(scene)">场景报表</a>
              </div>
            </div>
          </div>
        </div>
      </a-tab-pane>

      <a-tab-pane key="expired" tab="过期场景">
        <a-empty description="暂无过期场景" />
      </a-tab-pane>
    </a-tabs>

    <!-- 场景小店弹窗 -->
    <a-modal
      v-model:open="sceneShopVisible"
      title="场景小店"
      :width="1200"
      :footer="null"
      class="scene-shop-modal"
      @cancel="handleCloseSceneShop"
    >
      <div class="scene-shop-container">
        <!-- 左侧分类菜单 -->
        <div class="sidebar">
          <div class="left-menu">
            <!-- 全部选项 -->
            <div
              :class="['menu-all-item', { active: selectedShopCategory === '全部' }]"
              @click="handleShopCategoryClick('全部')"
            >
              全部
            </div>
            <!-- 分类菜单 -->
            <div
              v-for="(category, index) in shopMenuCategories"
              :key="index"
              class="menu-category"
            >
              <div
                class="menu-category-title"
                @click="toggleShopCategory(index)"
              >
                <span class="category-name">{{ category.name }}</span>
                <DownOutlined :class="{ 'menu-arrow-down': category.expanded }" />
              </div>
              <div v-if="category.expanded" class="menu-sub-items">
                <div
                  v-for="subItem in category.items"
                  :key="subItem"
                  :class="['menu-sub-item', { active: selectedShopCategory === subItem }]"
                  @click="handleShopCategoryClick(subItem)"
                >
                  {{ subItem }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 右侧内容区 -->
        <div class="content">
          <!-- 搜索栏 -->
          <div class="search-bar">
            <div class="search-row">
              <a-input
                v-model:value="searchKeyword"
                placeholder="请输入场景名称搜索"
                class="search-input"
                :allow-clear="true"
              >
                <template #prefix>
                  <search-outlined />
                </template>
              </a-input>
              <a-select
                v-model:value="selectedLine"
                placeholder="所属条线"
                class="line-select"
                :allow-clear="true"
              >
                <a-select-option value="">全部条线</a-select-option>
                <a-select-option value="retail">零售金融</a-select-option>
                <a-select-option value="corporate">公司金融</a-select-option>
                <a-select-option value="operation">运营管理</a-select-option>
              </a-select>
              <a-button type="primary" @click="handleSceneShopSearch">
                <template #icon><search-outlined /></template>
                搜索
              </a-button>
              <a-button @click="handleSceneShopReset">重置</a-button>
            </div>
          </div>

          <!-- 场景卡片列表 -->
          <div class="scene-shop-list">
            <a-row :gutter="[16, 16]">
              <a-col
                v-for="scene in filteredSceneList"
                :key="scene.id"
                :xs="24"
                :sm="12"
                :md="8"
              >
                <a-card class="scene-shop-card" hoverable @click="handleOpenSceneDetail(scene)">
                  <div class="scene-card-header">
                    <span class="scene-name">{{ scene.name }}</span>
                  </div>

                  <div class="scene-tags">
                    <a-tag
                      v-for="tag in scene.tags"
                      :key="tag"
                      color="blue"
                    >
                      {{ tag }}
                    </a-tag>
                  </div>

                  <p class="scene-description">{{ scene.description }}</p>

                  <div class="scene-actions">
                    <span v-if="scene.acquired" class="acquired-text">
                      <check-circle-outlined />
                      已获取
                    </span>
                    <a v-else class="get-scene-link" @click.stop="handleGetScene(scene)">
                      <download-outlined />
                      获取场景
                    </a>
                  </div>
                </a-card>
              </a-col>
            </a-row>
          </div>

          <!-- 分页 -->
          <div class="pagination-container">
            <a-pagination
              v-model:current="currentPage"
              v-model:pageSize="pageSize"
              :total="shopTotal"
              show-size-changer
              show-quick-jumper
              :show-total="((total: number) => `共 ${total} 条`) as any"
              :locale="{
                items_per_page: '条/页',
                jump_to: '跳至',
                page: '页',
              }"
            />
          </div>
        </div>
      </div>
    </a-modal>

    <!-- 场景详情弹窗 -->
    <a-modal
      v-model:open="sceneDetailVisible"
      :title="currentSceneDetail?.name || '场景详情'"
      :width="1000"
      :footer="null"
      class="scene-detail-modal"
      @cancel="handleCloseSceneDetail"
    >
      <div class="scene-detail-container">
        <!-- 顶部标签页 -->
        <div class="detail-tabs-section">
          <a-tabs v-model:activeKey="detailActiveTabKey">
            <a-tab-pane key="basic" tab="基本信息" />
            <a-tab-pane key="process" tab="主流程设置" />
            <a-tab-pane key="qa" tab="QA 库" />
            <a-tab-pane key="intent" tab="意图库" />
            <a-tab-pane key="fallback" tab="流程兜底设置" />
            <a-tab-pane key="script" tab="话术管理" />
            <a-tab-pane key="scene-voice" tab="场景语音" />
            <a-tab-pane key="user-classify" tab="用户分类" />
            <a-tab-pane key="system-settings" tab="场景系统设置" />
            <a-tab-pane key="sms" tab="场景短信" />
          </a-tabs>
        </div>

        <!-- 基本信息内容 -->
        <div v-if="detailActiveTabKey === 'basic'" class="detail-content">
          <a-descriptions bordered :column="2" size="middle">
            <a-descriptions-item label="场景名称" :span="2">
              {{ currentSceneDetail?.templateName || currentSceneDetail?.name }}
            </a-descriptions-item>
            <a-descriptions-item label="场景分类">
              {{ currentSceneDetail?.category }}
            </a-descriptions-item>
            <a-descriptions-item label="所属条线">
              {{ getLineText(currentSceneDetail?.line) }}
            </a-descriptions-item>
            <a-descriptions-item label="场景标签" :span="2">
              <a-tag v-for="tag in currentSceneDetail?.tags" :key="tag" color="blue">
                {{ tag }}
              </a-tag>
            </a-descriptions-item>
            <a-descriptions-item label="场景描述" :span="2">
              {{ currentSceneDetail?.description }}
            </a-descriptions-item>
            <a-descriptions-item label="创建人">
              {{ currentSceneDetail?.creator || '未知' }}
            </a-descriptions-item>
            <a-descriptions-item label="创建时间">
              {{ currentSceneDetail?.createTime || '未知' }}
            </a-descriptions-item>
            <a-descriptions-item label="适用机构" :span="2">
              {{ currentSceneDetail?.institutions?.join('、') || '全部机构' }}
            </a-descriptions-item>
            <a-descriptions-item label="跟进方式" :span="2">
              {{ getFollowTypeText(currentSceneDetail?.followType) }}
            </a-descriptions-item>
            <a-descriptions-item label="目标客户" :span="2">
              {{ currentSceneDetail?.targetCustomer || '暂无' }}
            </a-descriptions-item>
            <a-descriptions-item label="适用活动" :span="2">
              {{ currentSceneDetail?.applicableActivity || '暂无' }}
            </a-descriptions-item>
            <a-descriptions-item label="金融产品" :span="2">
              {{ currentSceneDetail?.financialProduct || '暂无' }}
            </a-descriptions-item>
          </a-descriptions>
        </div>

        <!-- 主流程设置内容 -->
        <div v-if="detailActiveTabKey === 'process'" class="detail-content process-content">
          <div class="process-canvas-wrapper">
            <div class="canvas-toolbar">
              <div class="toolbar-left">
                <a-space>
                  <a-button size="small" @click="handleZoomIn">
                    <zoom-in-outlined />
                    放大
                  </a-button>
                  <a-button size="small" @click="handleZoomOut">
                    <zoom-out-outlined />
                    缩小
                  </a-button>
                  <a-button size="small" @click="handleResetZoom">
                    <fullscreen-outlined />
                    重置
                  </a-button>
                  <span class="zoom-text">缩放：{{ canvasZoom }}%</span>
                </a-space>
              </div>
            </div>
            <div ref="canvasRef" class="process-canvas" @click="handleCanvasClick">
              <div class="canvas-content" :style="{ transform: `scale(${canvasZoom / 100})`, transformOrigin: 'top left' }">
                <!-- 节点层 -->
                <div
                  v-for="node in currentSceneDetail?.processNodes || []"
                  :key="node.id"
                  class="process-node"
                  :class="['node-type-' + node.type]"
                  :style="{ left: node.x + 'px', top: node.y + 'px' }"
                >
                  <!-- 节点头部 -->
                  <div class="node-header">
                    <component :is="getNodeIcon(node.type)" />
                    <span class="node-title">{{ node.name }}</span>
                  </div>
                  <!-- 节点内容 -->
                  <div class="node-content">
                    <template v-if="node.type === 'start'">
                      <span class="node-desc">流程起点</span>
                    </template>
                    <template v-else-if="node.type === 'script'">
                      <span class="node-desc">{{ node.content?.text || '暂无话术内容' }}</span>
                    </template>
                    <template v-else-if="node.type === 'success_end'">
                      <span class="node-desc">成功结束</span>
                    </template>
                    <template v-else-if="node.type === 'fail_end'">
                      <span class="node-desc">失败结束</span>
                    </template>
                    <template v-else-if="node.type === 'transfer'">
                      <span class="node-desc">{{ node.content?.text || '暂无转人工话术' }}</span>
                    </template>
                    <template v-else-if="node.type === 'verify'">
                      <span class="node-desc">{{ node.content?.text || '暂无验证话术' }}</span>
                    </template>
                  </div>
                  <!-- 连接点（输出） -->
                  <div
                    v-if="node.type !== 'success_end' && node.type !== 'fail_end'"
                    class="node-connector node-connector-out"
                  ></div>
                  <!-- 连接点（输入） -->
                  <div
                    v-if="node.type !== 'start'"
                    class="node-connector node-connector-in"
                  ></div>
                </div>
                <!-- SVG 连接线层 -->
                <svg class="connection-layer">
                  <defs>
                    <marker
                      id="arrowhead"
                      markerWidth="10"
                      markerHeight="7"
                      refX="9"
                      refY="3.5"
                      orient="auto"
                    >
                      <polygon points="0 0, 10 3.5, 0 7" fill="#91d5ff" />
                    </marker>
                  </defs>
                  <g v-for="(conn, index) in currentSceneDetail?.connections || []" :key="conn.id || index">
                    <!-- 连接线（粗线用于点击检测） -->
                    <path
                      :d="getConnectionPath(conn)"
                      class="connection-hit"
                    />
                    <!-- 连接线（细线用于显示） -->
                    <path
                      :d="getConnectionPath(conn)"
                      class="connection-line"
                    />
                  </g>
                </svg>
              </div>
            </div>
          </div>
        </div>

        <!-- QA 库内容 -->
        <div v-if="detailActiveTabKey === 'qa'" class="detail-content qa-content">
          <div class="qa-scroll-wrapper">
            <!-- 顶部搜索区 -->
            <div class="qa-toolbar">
              <div class="toolbar-left">
                <a-space>
                  <a-select
                    v-model:value="qaTypeFilter"
                    placeholder="全部"
                    style="width: 150px"
                    allow-clear
                  >
                    <a-select-option value="all">全部</a-select-option>
                    <a-select-option value="场景 QA">场景 QA</a-select-option>
                    <a-select-option value="行业 QA">行业 QA</a-select-option>
                    <a-select-option value="通用 QA">通用 QA</a-select-option>
                  </a-select>
                  <a-input
                    v-model:value="qaSearchKeyword"
                    placeholder="请输入问题关键词搜索"
                    style="width: 280px"
                  >
                    <template #prefix>
                      <search-outlined />
                    </template>
                  </a-input>
                  <a-button type="primary" @click="handleQaSearch">搜索</a-button>
                  <a-button @click="handleQaReset">重置</a-button>
                </a-space>
              </div>
            </div>

            <!-- QA 卡片列表 -->
            <div class="qa-list">
              <div
                v-for="qa in filteredQaList"
                :key="qa.id"
                class="qa-card"
              >
                <!-- 卡片头部 -->
                <div class="qa-card-header">
                  <div class="header-left">
                    <span class="qa-id">ID: {{ qa.id }}</span>
                    <span class="qa-question">{{ qa.question }}</span>
                    <a-tag :color="getQaTypeColor(qa.qaType)">{{ qa.qaType }}</a-tag>
                    <span class="qa-process">后续流程：{{ qa.followProcess }}</span>
                    <a-tag :color="qa.intentType === '正向' ? 'green' : 'red'">
                      {{ qa.intentType }}
                    </a-tag>
                  </div>
                </div>

                <!-- 回复列表表格 -->
                <div class="reply-table-wrapper">
                  <a-table
                    :columns="qaReplyColumns"
                    :data-source="qa.replies"
                    :pagination="false"
                    row-key="id"
                    size="small"
                  >
                    <template #bodyCell="{ column, record, index }">
                      <template v-if="column.key === 'index'">
                        <span>{{ index + 1 }}</span>
                      </template>
                      <template v-if="column.key === 'replyText'">
                        <span class="reply-text">{{ record.replyText }}</span>
                      </template>
                      <template v-if="column.key === 'scene'">
                        <span class="scene-tag">{{ record.scene || '-' }}</span>
                      </template>
                    </template>
                  </a-table>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 意图库内容 -->
        <div v-if="detailActiveTabKey === 'intent'" class="detail-content intent-content">
          <div class="intent-scroll-wrapper">
            <!-- 顶部搜索区 -->
            <div class="intent-toolbar">
              <div class="toolbar-left">
                <a-space>
                  <a-select
                    v-model:value="intentMenuFilter"
                    placeholder="意图来源"
                    style="width: 150px"
                    allow-clear
                  >
                    <a-select-option value="all">全部</a-select-option>
                    <a-select-option value="scene">当前场景意图</a-select-option>
                    <a-select-option value="industry">内置行业意图</a-select-option>
                    <a-select-option value="common">内置通用意图</a-select-option>
                  </a-select>
                  <a-input
                    v-model:value="intentSearchKeyword"
                    placeholder="请输入意图名称"
                    style="width: 240px"
                  >
                    <template #prefix>
                      <search-outlined />
                    </template>
                  </a-input>
                  <a-select
                    v-model:value="intentTypeFilter"
                    placeholder="请选择意图类型"
                    style="width: 150px"
                    allow-clear
                  >
                    <a-select-option value="肯定">肯定</a-select-option>
                    <a-select-option value="否定">否定</a-select-option>
                    <a-select-option value="中性">中性</a-select-option>
                    <a-select-option value="重复">重复</a-select-option>
                  </a-select>
                  <a-button type="primary" @click="handleIntentSearch">
                    <search-outlined />
                    搜索
                  </a-button>
                  <a-button @click="handleIntentReset">
                    <reload-outlined />
                    重置
                  </a-button>
                </a-space>
              </div>
            </div>

            <!-- 数据表格 -->
            <div class="intent-table-wrapper">
              <a-table
                :columns="intentColumns"
                :data-source="filteredIntentList"
                :pagination="false"
                row-key="id"
                size="middle"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'intentType'">
                    <a-tag :color="getIntentTypeColor(record.intentType)">
                      {{ record.intentType }}
                    </a-tag>
                  </template>
                </template>
              </a-table>
            </div>
          </div>
        </div>

        <!-- 流程兜底设置内容 -->
        <div v-if="detailActiveTabKey === 'fallback'" class="detail-content fallback-content">
          <div class="fallback-form-wrapper">
            <!-- 静音超时设置 -->
            <div class="form-section">
              <div class="section-title">
                <div class="title-bar"></div>
                <span>静音超时设置</span>
              </div>
              <div class="section-content">
                <div class="fallback-item">
                  <span class="fallback-label">静音超时时长：</span>
                  <span class="fallback-value">{{ currentSceneDetail?.fallbackData?.silenceTimeout || 10000 }} 毫秒</span>
                </div>
                <div class="fallback-item">
                  <span class="fallback-label">静音超时回复：</span>
                  <div class="fallback-reply-list">
                    <div
                      v-for="(reply, index) in currentSceneDetail?.fallbackData?.silenceReplies || []"
                      :key="index"
                      class="fallback-reply-item"
                    >
                      <span class="reply-index">{{ index + 1 }}.</span>
                      <span class="reply-text">{{ reply }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 语义为空设置 -->
            <div class="form-section">
              <div class="section-title">
                <div class="title-bar"></div>
                <span>语义为空设置</span>
              </div>
              <div class="section-content">
                <div class="fallback-item">
                  <span class="fallback-label">语义为空回复：</span>
                  <div class="fallback-reply-list">
                    <div
                      v-for="(reply, index) in currentSceneDetail?.fallbackData?.emptySemanticsReplies || []"
                      :key="index"
                      class="fallback-reply-item"
                    >
                      <span class="reply-index">{{ index + 1 }}.</span>
                      <span class="reply-text">{{ reply }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 重复策略设置 -->
            <div class="form-section">
              <div class="section-title">
                <div class="title-bar"></div>
                <span>重复策略设置</span>
              </div>
              <div class="section-content">
                <div class="fallback-item">
                  <span class="fallback-label">同一意图重复命中：</span>
                  <span class="fallback-value">
                    {{ getRepeatModeText(currentSceneDetail?.fallbackData?.sameIntentRepeatMode) }}
                    {{ currentSceneDetail?.fallbackData?.sameIntentRepeatCount || 2 }}次则跳转到当前流程的下一流程
                  </span>
                </div>
                <div class="fallback-item">
                  <span class="fallback-label">同一流程重复次数：</span>
                  <span class="fallback-value">
                    {{ getRepeatModeText(currentSceneDetail?.fallbackData?.sameProcessRepeatMode) }}
                    {{ currentSceneDetail?.fallbackData?.sameProcessRepeatCount || 1 }}次则跳转到当前流程的下一流程
                  </span>
                </div>
              </div>
            </div>

            <!-- 强制挂断设置 -->
            <div class="form-section">
              <div class="section-title">
                <div class="title-bar"></div>
                <span>强制挂断设置</span>
              </div>
              <div class="section-content">
                <div class="fallback-item">
                  <span class="fallback-label">通话超时时长：</span>
                  <span class="fallback-value">{{ currentSceneDetail?.fallbackData?.callTimeout || 300 }} 秒</span>
                </div>
                <div class="fallback-item">
                  <span class="fallback-label">强制挂断回复：</span>
                  <div class="fallback-reply-list">
                    <div
                      v-for="(reply, index) in currentSceneDetail?.fallbackData?.hangupReplies || []"
                      :key="index"
                      class="fallback-reply-item"
                    >
                      <span class="reply-index">{{ index + 1 }}.</span>
                      <span class="reply-text">{{ reply }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 按键行为设置 -->
            <div class="form-section">
              <div class="section-title">
                <div class="title-bar"></div>
                <span>按键行为设置</span>
              </div>
              <div class="section-content">
                <div class="fallback-item">
                  <span class="fallback-label">按键输入等待时长：</span>
                  <span class="fallback-value">{{ currentSceneDetail?.fallbackData?.keyInputTimeout || 10 }} 秒</span>
                </div>
                <div class="fallback-item">
                  <span class="fallback-label">按键错误回复：</span>
                  <div class="fallback-reply-list">
                    <div
                      v-for="(reply, index) in currentSceneDetail?.fallbackData?.keyErrorReplies || []"
                      :key="index"
                      class="fallback-reply-item"
                    >
                      <span class="reply-index">{{ index + 1 }}.</span>
                      <span class="reply-text">{{ reply || '无' }}</span>
                    </div>
                  </div>
                </div>
                <div class="fallback-item">
                  <span class="fallback-label">按键错误次数：</span>
                  <span class="fallback-value">
                    {{ getRepeatModeText(currentSceneDetail?.fallbackData?.keyErrorRepeatMode) }}
                    {{ currentSceneDetail?.fallbackData?.keyErrorCount || 3 }}次则触发强制挂断回复并挂断
                  </span>
                </div>
              </div>
            </div>

            <!-- 其他设置 -->
            <div class="form-section">
              <div class="section-title">
                <div class="title-bar"></div>
                <span>其他设置</span>
              </div>
              <div class="section-content">
                <div class="fallback-item">
                  <span class="fallback-label">转人工坐席忙回复：</span>
                  <div class="fallback-reply-list">
                    <div
                      v-for="(reply, index) in currentSceneDetail?.fallbackData?.transferBusyReplies || []"
                      :key="index"
                      class="fallback-reply-item"
                    >
                      <span class="reply-index">{{ index + 1 }}.</span>
                      <span class="reply-text">{{ reply || '无' }}</span>
                    </div>
                  </div>
                </div>
                <div class="fallback-item">
                  <span class="fallback-label">语音断句时长设置：</span>
                  <span class="fallback-value">{{ currentSceneDetail?.fallbackData?.voiceBreakTimeout || 500 }} 毫秒</span>
                </div>
                <div class="fallback-item">
                  <span class="fallback-label">接通后 ASR 识别设置：</span>
                  <span class="fallback-value">{{ currentSceneDetail?.fallbackData?.asrInitTimeout || 0 }} 毫秒</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 话术管理内容 -->
        <div v-if="detailActiveTabKey === 'script'" class="detail-content script-content">
          <div class="script-scroll-wrapper">
            <!-- 话术管理子标签页 -->
            <div class="script-sub-tabs">
              <a-tabs v-model:activeKey="scriptSubTabKey">
                <a-tab-pane key="compliance" data-tab-key="compliance" tab="话术消保" />
                <a-tab-pane key="audio" data-tab-key="audio" tab="话术录音" />
                <a-tab-pane key="variable" data-tab-key="variable" tab="话术变量" />
              </a-tabs>
            </div>

            <!-- 话术消保内容 -->
            <div v-if="scriptSubTabKey === 'compliance'" class="script-sub-content">
              <!-- 顶部搜索区 -->
              <div class="script-toolbar-section">
                <div class="script-toolbar-left">
                  <a-space>
                    <a-input
                      v-model:value="scriptSearchKeyword"
                      placeholder="请输入话术文本搜索"
                      style="width: 200px"
                    >
                      <template #prefix>
                        <search-outlined />
                      </template>
                    </a-input>
                    <a-button type="primary" @click="handleScriptSearch">
                      <search-outlined />
                      搜索
                    </a-button>
                    <a-button @click="handleScriptReset">
                      <reload-outlined />
                      重置
                    </a-button>
                  </a-space>
                </div>
              </div>

              <!-- 数据表格 -->
              <div class="script-list">
                <div class="script-table-wrapper">
                  <a-table
                    :columns="scriptColumns"
                    :data-source="filteredScriptList"
                    :pagination="false"
                    row-key="id"
                    size="middle"
                    :scroll="{ x: 1000 }"
                  >
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'uid'">
                        <span>{{ record.uid }}</span>
                      </template>
                      <template v-if="column.key === 'source'">
                        <span>{{ record.source || '-' }}</span>
                      </template>
                      <template v-if="column.key === 'replyText'">
                        <span class="script-reply-text">{{ record.replyText }}</span>
                      </template>
                      <template v-if="column.key === 'variableValue'">
                        <span>{{ record.variableValue || '-' }}</span>
                      </template>
                      <template v-if="column.key === 'complianceStatus'">
                        <a-tag :color="getComplianceStatusColor(record.complianceStatus)">
                          {{ record.complianceStatus || '未消保' }}
                        </a-tag>
                      </template>
                    </template>
                  </a-table>
                </div>
              </div>
            </div>

            <!-- 话术录音内容 -->
            <div v-else-if="scriptSubTabKey === 'audio'" class="script-sub-content">
              <!-- 顶部搜索区 -->
              <div class="script-toolbar-section">
                <div class="script-toolbar-left">
                  <a-space>
                    <a-input
                      v-model:value="scriptSearchKeyword"
                      placeholder="请输入话术文本搜索"
                      style="width: 200px"
                    >
                      <template #prefix>
                        <search-outlined />
                      </template>
                    </a-input>
                    <a-button type="primary" @click="handleScriptSearch">
                      <search-outlined />
                      搜索
                    </a-button>
                    <a-button @click="handleScriptReset">
                      <reload-outlined />
                      重置
                    </a-button>
                  </a-space>
                </div>
              </div>

              <!-- 数据表格 -->
              <div class="script-list">
                <div class="script-table-wrapper">
                  <a-table
                    :columns="scriptAudioColumns"
                    :data-source="filteredScriptList"
                    :pagination="false"
                    row-key="id"
                    size="middle"
                    :scroll="{ x: 1200 }"
                  >
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'uid'">
                        <span>{{ record.uid }}</span>
                      </template>
                      <template v-if="column.key === 'replyText'">
                        <span class="script-reply-text">{{ record.replyText }}</span>
                      </template>
                      <template v-if="column.key === 'recordFileName'">
                        <span>{{ record.recordFileName || '-' }}</span>
                      </template>
                      <template v-if="column.key === 'audioUploadStatus'">
                        <a-tag :color="record.audioUploadStatus === '已上传' ? 'green' : 'default'">
                          {{ record.audioUploadStatus || '未上传' }}
                        </a-tag>
                      </template>
                      <template v-if="column.key === 'audio'">
                        <a-space>
                          <a-button
                            v-if="record.audioUrl"
                            type="link"
                            size="small"
                            @click="handlePlayAudio(record)"
                          >
                            <play-circle-outlined />
                            播放
                          </a-button>
                          <span v-else class="no-audio-text">无录音文件</span>
                        </a-space>
                      </template>
                    </template>
                  </a-table>
                </div>
              </div>
            </div>

            <!-- 话术变量内容 -->
            <div v-else-if="scriptSubTabKey === 'variable'" class="script-sub-content">
              <!-- 顶部操作区 -->
              <div class="script-toolbar-section">
                <div class="script-toolbar-left">
                  <a-space>
                    <a-input
                      v-model:value="variableSearchKeyword"
                      placeholder="请输入变量名搜索"
                      style="width: 200px"
                      @press-enter="handleVariableSearch"
                    >
                      <template #prefix>
                        <search-outlined />
                      </template>
                    </a-input>
                    <a-button type="primary" @click="handleVariableSearch">
                      <search-outlined />
                      搜索
                    </a-button>
                    <a-button @click="handleScriptReset">
                      <reload-outlined />
                      重置
                    </a-button>
                  </a-space>
                </div>
              </div>

              <!-- 变量列表表格 -->
              <div class="script-list">
                <div class="script-table-wrapper">
                  <a-table
                    :columns="variableColumns"
                    :data-source="filteredVariableList"
                    :pagination="false"
                    row-key="id"
                    size="middle"
                    :scroll="{ x: 1000 }"
                  >
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'variableName'">
                        <span class="variable-name">{{ record.variableName }}</span>
                      </template>
                      <template v-if="column.key === 'variableValue'">
                        <span class="variable-value-text">{{ record.variableValue || '-' }}</span>
                      </template>
                    </template>
                  </a-table>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 用户分类内容 -->
        <div v-if="detailActiveTabKey === 'user-classify'" class="detail-content user-classify-content">
          <div class="user-classify-wrapper">
            <!-- 左侧分类列表 -->
            <div class="classify-sidebar">
              <div class="sidebar-title">用户分类</div>
              <div
                v-for="(category, index) in currentSceneDetail?.userCategories || []"
                :key="category.id"
                :class="['category-item', { active: selectedUserCategoryId === category.id }]"
                @click="selectedUserCategoryId = category.id"
              >
                <span class="category-name">{{ category.name }}</span>
                <div class="category-item-right">
                  <a-switch
                    v-model:checked="category.enabled"
                    size="small"
                    disabled
                    :checked-children="'启用'"
                    :un-checked-children="'停用'"
                  />
                </div>
              </div>
            </div>

            <!-- 右侧规则配置区 -->
            <div class="classify-main-content">
              <!-- 顶部默认规则提示 -->
              <div class="default-rule-alert-wrapper">
                <div class="default-rule-alert">
                  <exclamation-circle-outlined style="margin-right: 8px; color: #faad14;" />
                  默认规则：通话意图"反向>=1"、"静音=全程"、"否定=全程"，标记客户为无意向；该规则优先级最高
                </div>
              </div>

              <!-- 规则列表区域 -->
              <div class="rule-list-container">
                <!-- 获取当前选中分类的规则 -->
                <template v-if="getCurrentUserCategoryRules.length > 0">
                  <div
                    v-for="(rule, index) in getCurrentUserCategoryRules"
                    :key="rule.id"
                    class="rule-item"
                  >
                    <div class="rule-header">
                      <span class="rule-index">表达式{{ index + 1 }}</span>
                    </div>
                    <div class="rule-content">
                      <!-- 条件列表 -->
                      <div class="condition-display-list">
                        <div
                          v-for="(condition, cIndex) in (rule.conditions || [])"
                          :key="cIndex"
                          class="condition-display-item"
                        >
                          <span class="condition-field">{{ condition.fieldType }}</span>
                          <span class="condition-operator">{{ condition.operator }}</span>
                          <span class="condition-value">{{ condition.value }}</span>
                          <span v-if="cIndex < (rule.conditions || []).length - 1" class="condition-connector">且</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </template>
              </div>
            </div>
          </div>
        </div>

        <!-- 场景系统设置内容 -->
        <div v-if="detailActiveTabKey === 'system-settings'" class="detail-content system-settings-content">
          <div class="system-settings-wrapper">
            <!-- 客户跟进配置 -->
            <div class="settings-section">
              <div class="section-title">
                <div class="title-bar"></div>
                <span>客户跟进配置</span>
              </div>
              <div class="section-content">
                <div class="settings-item">
                  <span class="settings-label">意向客户推送：</span>
                  <a-switch
                    :checked="currentSceneDetail?.systemSettings?.intentCustomerPush"
                    size="small"
                    disabled
                  />
                  <div class="settings-tip">机器人拨打电话后是否需要将意向客户推送给客户经理进行跟进，提高业务转化率</div>
                </div>
                <div class="settings-item">
                  <span class="settings-label">推送意向范围：</span>
                  <div class="settings-value">
                    <a-tag
                      v-for="range in currentSceneDetail?.systemSettings?.pushIntentRange || []"
                      :key="range"
                      color="blue"
                    >
                      {{ range }}
                    </a-tag>
                  </div>
                  <div class="settings-tip">用户分类对将用户拨打的数据进行分发</div>
                </div>
                <div class="settings-item">
                  <span class="settings-label">"意向率"包括：</span>
                  <div class="settings-value">
                    <a-tag
                      v-for="range in currentSceneDetail?.systemSettings?.intentRateRange || []"
                      :key="range"
                      color="green"
                    >
                      {{ range }}
                    </a-tag>
                  </div>
                  <div class="settings-tip">请勾选 系统统计 指标"有意向"包含哪些客户标签</div>
                </div>
                <div class="settings-item">
                  <span class="settings-label">当前场景跟进表单字段设置：</span>
                  <div class="settings-value follow-up-fields">
                    <span
                      v-for="field in getFollowUpFields(currentSceneDetail?.systemSettings?.followUpFields)"
                      :key="field"
                      class="field-tag"
                    >
                      {{ field }}
                    </span>
                  </div>
                  <div class="settings-tip">客户跟进字段可以前往客户信息配置中进行管理</div>
                </div>
              </div>
            </div>

            <!-- 人机协同配置 -->
            <div class="settings-section">
              <div class="section-title">
                <div class="title-bar"></div>
                <span>人机协同配置</span>
              </div>
              <div class="section-content">
                <div class="settings-item">
                  <span class="settings-label">人机协同模式：</span>
                  <a-switch
                    :checked="currentSceneDetail?.systemSettings?.humanMachineCollaboration"
                    size="small"
                    disabled
                  />
                  <span class="settings-value-inline">
                    话术中是否配置转人工：
                    <span :class="hasTransferScript ? 'success-text' : 'error-text'">
                      {{ hasTransferScript ? '是' : '否' }}
                    </span>
                  </span>
                </div>
                <div class="settings-item">
                  <span class="settings-label">协同方式：</span>
                  <span class="settings-value">{{ getCollaborationModeText(currentSceneDetail?.systemSettings?.collaborationMode) }}</span>
                </div>
                <div class="settings-item">
                  <span class="settings-label">转人工条件：</span>
                  <span class="settings-value">{{ getTransferConditionText(currentSceneDetail?.systemSettings?.transferCondition) }}</span>
                  <div class="settings-tip error-text">注意：接通自动转接模式中话术/QA 中的转人工配置不生效</div>
                </div>
                <div class="settings-item">
                  <span class="settings-label">协同策略：</span>
                  <span class="settings-value">{{ getCollaborationStrategyText(currentSceneDetail?.systemSettings?.collaborationStrategy) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 场景短信内容 -->
        <div v-if="detailActiveTabKey === 'sms'" class="detail-content sms-content">
          <div class="sms-scroll-wrapper">
            <!-- 顶部操作区 -->
            <div class="sms-toolbar-section">
              <div class="sms-toolbar-left">
                <a-space>
                  <a-input
                    v-model:value="smsTemplateNameFilter"
                    placeholder="请输入模版名称"
                    style="width: 200px"
                    @press-enter="handleSmsSearch"
                  >
                    <template #prefix>
                      <search-outlined />
                    </template>
                  </a-input>
                  <a-input
                    v-model:value="smsContentFilter"
                    placeholder="请输入短信内容"
                    style="width: 200px"
                    @press-enter="handleSmsSearch"
                  >
                    <template #prefix>
                      <search-outlined />
                    </template>
                  </a-input>
                  <a-button type="primary" @click="handleSmsSearch">
                    <search-outlined />
                    搜索
                  </a-button>
                  <a-button @click="handleSmsReset">
                    <reload-outlined />
                    重置
                  </a-button>
                </a-space>
              </div>
            </div>

            <!-- 数据表格 -->
            <div class="sms-list">
              <div class="sms-table-wrapper">
                <a-table
                  :columns="smsColumns"
                  :data-source="smsList"
                  :pagination="false"
                  row-key="id"
                  size="middle"
                  @change="handleSmsTableChange"
                  :scroll="{ x: 1200 }"
                >
                  <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'id'">
                      <span>{{ record.id }}</span>
                    </template>
                    <template v-if="column.key === 'smsName'">
                      <span class="sms-name">{{ record.smsName }}</span>
                    </template>
                    <template v-if="column.key === 'smsCode'">
                      <span class="sms-code">{{ record.smsCode }}</span>
                    </template>
                    <template v-if="column.key === 'smsContent'">
                      <span class="sms-content-text">{{ record.smsContent }}</span>
                    </template>
                    <template v-if="column.key === 'modifyTime'">
                      <span class="modify-time">{{ record.modifyTime }}</span>
                    </template>
                  </template>
                </a-table>
              </div>
              <!-- 分页 -->
              <div class="sms-pagination">
                <span class="total-text">总共 {{ smsTotal }} 条</span>
                <a-pagination
                  v-model:current="smsPagination.current"
                  v-model:page-size="smsPagination.pageSize"
                  :total="smsPagination.total"
                  show-size-changer
                  show-quick-jumper
                  :show-total="(total: number) => `共 ${total} 条`"
                  :page-size-options="['10', '20', '50']"
                  :locale="{
                    items_per_page: '条/页',
                    jump_to: '跳转至',
                    page: '页',
                  }"
                  @change="handleSmsPageChange"
                  @show-size-change="handleSmsPageSizeChange"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- 场景语音内容 -->
        <div v-if="detailActiveTabKey === 'scene-voice'" class="detail-content scene-voice-content">
          <div class="scene-voice-wrapper">
            <div class="voice-settings-form">
              <!-- 语音服务设置 -->
              <div class="settings-section">
                <div class="section-header">
                  <div class="section-title">
                    <div class="title-bar"></div>
                    <span>语音服务设置</span>
                  </div>
                </div>
                <div class="section-content">
                  <!-- 语音识别资源（ASR） -->
                  <div class="setting-item">
                    <div class="setting-label">
                      <span>语音识别资源（ASR）</span>
                    </div>
                    <div class="setting-control">
                      <a-radio-group v-model:value="voiceForm.asrResource" disabled>
                        <a-radio value="aliyun">阿里公有云</a-radio>
                        <a-radio value="sibichi">思必驰</a-radio>
                        <a-radio value="moxiang">摸象</a-radio>
                      </a-radio-group>
                    </div>
                  </div>

                  <!-- 语音合成资源（TTS） -->
                  <div class="setting-item">
                    <div class="setting-label">
                      <span>语音合成资源（TTS）</span>
                    </div>
                    <div class="setting-control">
                      <a-radio-group v-model:value="voiceForm.ttsResource" disabled>
                        <a-radio value="aliyun">阿里公有云</a-radio>
                        <a-radio value="sibichi">思必驰</a-radio>
                        <a-radio value="moxiang">摸象</a-radio>
                      </a-radio-group>
                    </div>
                  </div>

                  <!-- 语音生成方式 -->
                  <div class="setting-item">
                    <div class="setting-label">
                      <span>语音生成方式</span>
                    </div>
                    <div class="setting-control">
                      <a-radio-group v-model:value="voiceForm.voiceGenerateType" disabled>
                        <a-radio value="human">真人录音</a-radio>
                        <a-radio value="tts">语音合成</a-radio>
                      </a-radio-group>
                    </div>
                  </div>

                  <!-- 录音播放规则（真人录音时显示） -->
                  <div v-if="voiceForm.voiceGenerateType === 'human'" class="setting-item">
                    <div class="setting-label">
                      <span>录音播放规则</span>
                    </div>
                    <div class="setting-control">
                      <a-radio-group v-model:value="voiceForm.playbackRule" disabled>
                        <a-radio value="default">统一使用默认录音包</a-radio>
                        <a-radio value="agent">匹配管户坐席录音包</a-radio>
                      </a-radio-group>
                    </div>
                  </div>

                  <!-- 合成音色（语音合成时显示） -->
                  <div v-if="voiceForm.voiceGenerateType === 'tts'" class="setting-item">
                    <div class="setting-label">
                      <span>合成音色</span>
                    </div>
                    <div class="setting-control">
                      <a-input
                        v-model:value="voiceForm.ttsVoiceName"
                        placeholder="请选择合成音色"
                        style="width: 300px; margin-right: 12px;"
                        readonly
                      >
                        <template #suffix>
                          <search-outlined style="cursor: not-allowed" />
                        </template>
                      </a-input>
                    </div>
                  </div>

                  <!-- 音量配置（语音合成时显示） -->
                  <div v-if="voiceForm.voiceGenerateType === 'tts'" class="setting-item">
                    <div class="setting-label">
                      <span>音量</span>
                    </div>
                    <div class="setting-control">
                      <a-slider v-model:value="voiceForm.volume" :min="0" :max="100" :step="1" style="width: 300px" disabled />
                      <span class="slider-value">{{ voiceForm.volume }}%</span>
                    </div>
                  </div>

                  <!-- 语速配置（语音合成时显示） -->
                  <div v-if="voiceForm.voiceGenerateType === 'tts'" class="setting-item">
                    <div class="setting-label">
                      <span>语速</span>
                    </div>
                    <div class="setting-control">
                      <a-slider v-model:value="voiceForm.speed" :min="0.5" :max="2.0" :step="0.1" style="width: 300px" disabled />
                      <span class="slider-value">{{ voiceForm.speed }}x</span>
                    </div>
                  </div>

                  <!-- 语调配置（语音合成时显示） -->
                  <div v-if="voiceForm.voiceGenerateType === 'tts'" class="setting-item">
                    <div class="setting-label">
                      <span>语调</span>
                    </div>
                    <div class="setting-control">
                      <a-slider v-model:value="voiceForm.pitch" :min="0.5" :max="2.0" :step="0.1" style="width: 300px" disabled />
                      <span class="slider-value">{{ voiceForm.pitch }}x</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import { useRouter } from 'vue-router';
import {
  SearchOutlined,
  ReloadOutlined,
  ImportOutlined,
  PlusOutlined,
  ShopOutlined,
  DownOutlined,
  AppstoreOutlined,
  ShoppingOutlined,
  BellOutlined,
  SafetyOutlined,
  UserOutlined,
  DownloadOutlined,
  CheckCircleOutlined,
  EllipsisOutlined,
  EditOutlined,
  CopyOutlined,
  DeleteOutlined,
  UploadOutlined,
  LogoutOutlined,
  ZoomInOutlined,
  ZoomOutOutlined,
  FullscreenOutlined,
  LayoutOutlined,
  PlayCircleOutlined,
  QuestionCircleOutlined,
  ApiOutlined,
  ClusterOutlined,
  CheckCircleFilled,
  CloseOutlined,
  MessageOutlined,
  CustomerServiceOutlined,
  SafetyCertificateOutlined,
  ExclamationCircleOutlined,
} from '@ant-design/icons-vue';

const router = useRouter();

// 场景数据接口
interface SceneItem {
  id: number;
  name: string;
  tag?: string;
  tagColor?: string;
  expireTime: string;
  voiceType: string;
  platformVersion: string;
  followUpMethod: string;
  enabled: boolean;
  outboundStatus: string;
  code: string;
  createTime: string;
  publishedToShop?: boolean; // 是否已发布到场景小店
}

// 搜索表单数据
interface SearchForm {
  institution: string | undefined;
  sceneName: string | undefined;
  creator: string | undefined;
  templateType: string | undefined;
  templateSubtype: string | undefined;
  publishedToShop: string | undefined;
  sceneCode: string | undefined;
}

// 关闭场景搜索表单数据
interface ClosedSearchForm {
  institution: string | undefined;
  sceneName: string | undefined;
  creator: string | undefined;
  templateType: string | undefined;
  templateSubtype: string | undefined;
  publishedToShop: string | undefined;
  sceneCode: string | undefined;
}

// 当前激活的标签页
const activeTab = ref<string>('active');

// 搜索表单
const searchForm = reactive<SearchForm>({
  institution: undefined,
  sceneName: undefined,
  creator: undefined,
  templateType: undefined,
  templateSubtype: undefined,
  publishedToShop: undefined,
  sceneCode: undefined,
});

// 关闭场景搜索表单
const closedSearchForm = reactive<ClosedSearchForm>({
  institution: undefined,
  sceneName: undefined,
  creator: undefined,
  templateType: undefined,
  templateSubtype: undefined,
  publishedToShop: undefined,
  sceneCode: undefined,
});

// 排序方式
const sortOrder = ref<string>('desc');

// 关闭场景排序方式
const closedSortOrder = ref<string>('desc');

// 总数
const total = ref<number>(8);

// 场景列表数据（8 条模拟数据）
const sceneList = ref<SceneItem[]>([
  {
    id: 1,
    name: '贷款转存 - 接通即转（叶泽伟测试）',
    tag: '热门',
    tagColor: 'red',
    expireTime: '2026-12-31',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI 自动跟进',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309001',
    createTime: '2026-03-01 10:30:00',
    publishedToShop: true, // 已发布到场景小店
  },
  {
    id: 2,
    name: '信用卡逾期催收场景',
    tag: '推荐',
    tagColor: 'green',
    expireTime: '2026-06-30',
    voiceType: '真人录音',
    platformVersion: 'v2.4.0 / v3.0.0',
    followUpMethod: '人工跟进',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309002',
    createTime: '2026-03-02 14:20:00',
    publishedToShop: false,
  },
  {
    id: 3,
    name: '新客户营销回访',
    expireTime: '2026-09-30',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI 自动跟进',
    enabled: false,
    outboundStatus: '已暂停',
    code: 'SCENE20260309003',
    createTime: '2026-03-03 09:15:00',
    publishedToShop: false,
  },
  {
    id: 4,
    name: '存款到期提醒场景',
    tag: '新品',
    tagColor: 'blue',
    expireTime: '2026-12-31',
    voiceType: '混合语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI + 人工',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309004',
    createTime: '2026-03-05 16:45:00',
    publishedToShop: true,
  },
  {
    id: 5,
    name: '理财产品推广场景',
    expireTime: '2026-08-31',
    voiceType: '真人录音',
    platformVersion: 'v2.4.0 / v3.0.0',
    followUpMethod: '人工跟进',
    enabled: true,
    outboundStatus: '已完成',
    code: 'SCENE20260309005',
    createTime: '2026-03-07 11:00:00',
    publishedToShop: false,
  },
  {
    id: 6,
    name: '企业贷款审批通知',
    tag: '热门',
    tagColor: 'red',
    expireTime: '2026-11-30',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI 自动跟进',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309006',
    createTime: '2026-03-08 09:30:00',
    publishedToShop: false,
  },
  {
    id: 7,
    name: '个人消费贷营销',
    tag: '推荐',
    tagColor: 'green',
    expireTime: '2026-10-31',
    voiceType: '真人录音',
    platformVersion: 'v2.4.0 / v3.0.0',
    followUpMethod: 'AI + 人工',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309007',
    createTime: '2026-03-08 14:00:00',
    publishedToShop: false,
  },
  {
    id: 8,
    name: '账户异常提醒场景',
    expireTime: '2026-07-31',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: '人工跟进',
    enabled: false,
    outboundStatus: '已暂停',
    code: 'SCENE20260309008',
    createTime: '2026-03-09 10:15:00',
    publishedToShop: false,
  },
]);

// 计算属性：开启场景列表（enabled 为 true）
const activeSceneList = computed<SceneItem[]>(() => {
  return sceneList.value.filter(scene => scene.enabled);
});

// 计算属性：关闭场景列表（enabled 为 false）
const closedSceneList = computed<SceneItem[]>(() => {
  return sceneList.value.filter(scene => !scene.enabled);
});

/**
 * 搜索按钮点击
 */
const handleSearch = () => {
  console.log('执行搜索:', searchForm);
  // TODO: 实现搜索逻辑
};

/**
 * 重置按钮点击
 */
const handleReset = () => {
  searchForm.institution = undefined;
  searchForm.sceneName = undefined;
  searchForm.creator = undefined;
  searchForm.templateType = undefined;
  searchForm.templateSubtype = undefined;
  searchForm.publishedToShop = undefined;
  searchForm.sceneCode = undefined;
  // TODO: 重置后重新加载数据
};

/**
 * 关闭场景搜索按钮点击
 */
const handleClosedSearch = () => {
  console.log('执行搜索:', closedSearchForm);
  // TODO: 实现搜索逻辑
};

/**
 * 关闭场景重置按钮点击
 */
const handleClosedReset = () => {
  closedSearchForm.institution = undefined;
  closedSearchForm.sceneName = undefined;
  closedSearchForm.creator = undefined;
  closedSearchForm.templateType = undefined;
  closedSearchForm.templateSubtype = undefined;
  closedSearchForm.publishedToShop = undefined;
  closedSearchForm.sceneCode = undefined;
  // TODO: 重置后重新加载数据
};

// 文件输入引用
const fileInputRef = ref<HTMLInputElement | null>(null);

/**
 * 导入场景 - 点击按钮触发文件选择
 */
const handleImportScene = () => {
  console.log('导入场景');
  fileInputRef.value?.click();
};

/**
 * 文件选择变更处理
 */
const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (file) {
    console.log('选择的文件:', file.name);
    // TODO: 实现文件读取和导入逻辑
    // 例如：读取 JSON 文件内容并创建场景
  }
  // 清空 input 值，允许重复选择同一文件
  target.value = '';
};

/**
 * 创建场景 - 跳转到场景模板页面
 */
const handleCreateScene = () => {
  console.log('创建场景');
  router.push('/scene-template');
};

/**
 * 启用状态变更
 */
const handleEnabledChange = (scene: SceneItem) => {
  console.log(`场景 ${scene.name} 启用状态变更为：${scene.enabled}`);
  // TODO: 调用接口更新状态
};

/**
 * 刷新外呼状态
 */
const handleRefreshStatus = () => {
  console.log('刷新外呼状态');
  // TODO: 实现刷新逻辑
};

/**
 * 查看场景
 */
const handleView = (scene: SceneItem) => {
  console.log('查看场景:', scene.name);
  router.push(`/scene-detail/${scene.id}`);
};

/**
 * 查看报表
 */
const handleReport = (scene: SceneItem) => {
  console.log('查看报表:', scene.name);
  // TODO: 跳转到报表页
};

/**
 * 发布场景
 */
const handlePublish = (scene: SceneItem) => {
  console.log('发布场景:', scene.name);
  // TODO: 实现发布逻辑
};

/**
 * 发布至场景小店
 */
const handlePublishToShop = (scene: SceneItem) => {
  console.log('发布至场景小店:', scene.name);
  scene.publishedToShop = true;
  // TODO: 调用接口发布到场景小店
};

/**
 * 从场景小店下架
 */
const handleUnpublishFromShop = (scene: SceneItem) => {
  console.log('从场景小店下架:', scene.name);
  scene.publishedToShop = false;
  // TODO: 调用接口从场景小店下架
};

/**
 * 导出场景
 */
const handleExport = (scene: SceneItem) => {
  console.log('导出场景:', scene.name);
  // TODO: 实现导出逻辑
};

/**
 * 复制场景
 */
const handleCopy = (scene: SceneItem) => {
  console.log('复制场景:', scene.name);
  // TODO: 实现复制逻辑
};

/**
 * 删除场景
 */
const handleDelete = (scene: SceneItem) => {
  console.log('删除场景:', scene.name);
  // TODO: 实现删除逻辑（需二次确认）
};

/**
 * 场景检测
 */
const handleSceneCheck = (scene: SceneItem) => {
  console.log('场景检测:', scene.name);
  // TODO: 实现场景检测逻辑
};

/**
 * 话术完整性检查
 */
const handleScriptCheck = (scene: SceneItem) => {
  console.log('话术完整性检查:', scene.name);
  // TODO: 实现话术检查逻辑
};

/**
 * 查看拨打时间段
 */
const handleViewTimeSlot = (scene: SceneItem) => {
  console.log('查看拨打时间段:', scene.name);
  // TODO: 实现查看时间段逻辑
};

/**
 * 添加数据批次
 */
const handleAddDataBatch = (scene: SceneItem) => {
  console.log('添加数据批次:', scene.name);
  // TODO: 实现添加数据批次逻辑
};

/**
 * 快速拨测
 */
const handleQuickTest = (scene: SceneItem) => {
  console.log('快速拨测:', scene.name);
  // TODO: 实现快速拨测逻辑
};

/**
 * 话术测试
 */
const handleScriptTest = (scene: SceneItem) => {
  console.log('话术测试:', scene.name);
  // TODO: 实现话术测试逻辑
};

// ==================== 场景小店相关 ====================

// 场景小店弹窗可见性
const sceneShopVisible = ref<boolean>(false);

// 场景小店选中的分类
const selectedShopCategory = ref<string>('全部');

// 场景小店搜索关键词
const searchKeyword = ref<string>('');

// 场景小店所属条线
const selectedLine = ref<string>('');

// 场景小店分页
const currentPage = ref<number>(1);
const pageSize = ref<number>(9);
const shopTotal = ref<number>(27);

// 场景小店菜单分类接口
interface ShopMenuCategory {
  name: string;
  expanded: boolean;
  items: string[];
}

// 场景小店左侧菜单分类数据（参考 SceneTemplate.vue）
const shopMenuCategories = reactive<ShopMenuCategory[]>([
  {
    name: '存款',
    expanded: false,
    items: ['定期存款', '通知存款', '大额存单', '结构性存款', '存款到期提醒', '存款续存', '外币存款'],
  },
  {
    name: '理财',
    expanded: false,
    items: ['活期理财', '持有期型理财', '定期开放式理财', '封闭式理财', '开放式/每日可申赎理财', '理财服务开通', '外币理财'],
  },
  {
    name: '资产提升',
    expanded: false,
    items: ['月日均资产提升', '余额资产提升', '资产提升 + 理财', '资产提升 + 存款'],
  },
  {
    name: '信用卡',
    expanded: false,
    items: [
      '信用卡开卡',
      '信用卡激活',
      '信用卡促活',
      '信用卡账单分期',
      '信用卡消费分期',
      '信用卡现金分期',
      '信用卡快捷支付绑卡',
      '信用卡第三方绑卡',
      '信用卡装修分期',
      '信用卡自动还款',
    ],
  },
  {
    name: '借记卡',
    expanded: false,
    items: ['借记卡开卡', '借记卡促活', '借记卡换卡', '借记卡激活', '借记卡第三方绑卡', '借记卡快捷支付绑卡'],
  },
  {
    name: '贷款',
    expanded: false,
    items: ['个人信用贷款', '个人抵押贷款', '企业信用贷款', '企业抵押贷款', '贷款促支', '贷款续贷'],
  },
  {
    name: '手机银行',
    expanded: false,
    items: ['手机银行开通', '手机银行促活', '快捷支付活动', '手机银行功能介绍'],
  },
  {
    name: '数字人民币',
    expanded: false,
    items: ['数字人民币开通', '数字人民币促活'],
  },
  {
    name: '微信',
    expanded: false,
    items: ['企微加粉', '微信公众号'],
  },
  {
    name: '外汇',
    expanded: false,
    items: ['结汇/售汇', '跨境功能产品营销', '跨境活动营销'],
  },
  {
    name: '社保卡',
    expanded: false,
    items: ['社保卡开卡', '社保卡换卡', '社保卡激活'],
  },
  {
    name: '个人养老金',
    expanded: false,
    items: ['个人养老金开户', '个人养老金缴存', '个人养老金开户 + 缴存'],
  },
  {
    name: '对公业务',
    expanded: false,
    items: [
      '对公套餐签约',
      '对公开户',
      '企业手机银行促活',
      '对公促活',
      '企业手机银行开通',
      '企业网银开通',
      '会计对账',
      '对公资产提升',
      '商户活动',
    ],
  },
  {
    name: '保险',
    expanded: false,
    items: ['保险营销'],
  },
  {
    name: '基金',
    expanded: false,
    items: ['基金营销'],
  },
  {
    name: '证券',
    expanded: false,
    items: ['证券开户', '三方存管', '证券 APP 促活'],
  },
  {
    name: '贵金属',
    expanded: false,
    items: ['贵金属产品营销', '积存金'],
  },
  {
    name: '电子医保卡',
    expanded: false,
    items: ['电子医保申领', '电子医保激活'],
  },
  {
    name: '回访',
    expanded: false,
    items: ['开卡回访', '反诈骗回访', '活动回访', '调查问卷回访', '贷后回访', '满意度回访'],
  },
  {
    name: '催收',
    expanded: false,
    items: ['信用卡还款提醒', '信用卡逾期催收', '贷款还钱提醒', '贷款逾期催收'],
  },
  {
    name: '通知',
    expanded: false,
    items: ['一句话通知', '挽回式通知', '重听式通知', '一句话接通即转', '一句话转人工'],
  },
]);

// 场景小店数据接口
interface SceneShopItem {
  id: number;
  name: string;
  tags: string[];
  description: string;
  category: string;
  line: string;
  acquired?: boolean; // 是否已获取
  
  // 基本信息字段
  templateName?: string;
  templateType?: string[];
  followType?: string;
  targetCustomer?: string;
  applicableActivity?: string;
  financialProduct?: string;
  creator?: string;
  createTime?: string;
  institutions?: string[];
  
  // 主流程数据
  processNodes?: any[];
  connections?: any[];
  
  // QA 库数据
  qaList?: QaItem[];
  
  // 意图库数据
  intentList?: IntentItem[];
  
  // 流程兜底数据
  fallbackData?: FallbackData;
  
  // 话术管理数据
  scriptList?: ScriptItem[];
  
  // 用户分类数据
  userCategories?: UserCategory[];
  
  // 场景系统设置数据
  systemSettings?: SystemSettings;
}

// QA 列表项接口
interface QaItem {
  id: number;
  question: string;
  qaType: '场景 QA' | '行业 QA' | '通用 QA';
  followProcess: string;
  intentType: '正向' | '负向';
  replies: ReplyItem[];
}

// 回复列表项接口
interface ReplyItem {
  id: number;
  replyText: string;
  scene?: string;
}

// 意图列表项接口
interface IntentItem {
  id: number;
  intentName: string;
  intentType: string;
  priority: number;
  updateTime: string;
}

// 流程兜底数据接口
interface FallbackData {
  // 静音超时设置
  silenceTimeout: number;
  silenceReplies: string[];
  // 语义为空设置
  emptySemanticsReplies: string[];
  // 重复策略设置
  sameIntentRepeatMode: string;
  sameIntentRepeatCount: number;
  sameProcessRepeatMode: string;
  sameProcessRepeatCount: number;
  // 强制挂断设置
  callTimeout: number;
  hangupReplies: string[];
  // 按键行为设置
  keyInputTimeout: number;
  keyErrorReplies: string[];
  keyErrorRepeatMode: string;
  keyErrorCount: number;
  // 其他设置
  transferBusyReplies: string[];
  voiceBreakTimeout: number;
  asrInitTimeout: number;
}

// 话术列表项接口
interface ScriptItem {
  id: number;
  uid: number;
  replyText: string;
  variableValue?: string;
  recordFileName: string;
  audioUrl: string;
  complianceStatus?: '消保通过' | '消保不通过' | '未消保';
  audioUploadStatus?: '已上传' | '未上传';
  source?: string;
}

// 用户分类数据接口
interface UserCategory {
  id: number;
  name: string;
  priority: number;
  isDefault: boolean;
  enabled: boolean;
  rules: CategoryRule[];
}

// 规则条件接口
interface RuleCondition {
  id: number;
  fieldType: string;
  operator: string;
  value: string;
}

// 分类规则接口
interface CategoryRule {
  id: number;
  expression: string;
  resultType?: string;
  conditions?: RuleCondition[];
}

// 场景系统设置数据接口
interface SystemSettings {
  // 客户跟进配置
  intentCustomerPush: boolean;
  pushIntentRange: string[];
  intentRateRange: string[];
  followUpFields: string[];
  
  // 人机协同配置
  humanMachineCollaboration: boolean;
  collaborationMode: string;
  transferCondition: string;
  collaborationStrategy: string;
}

// 场景小店列表数据
const sceneShopList = ref<SceneShopItem[]>([
  {
    id: 1,
    name: '信用卡激活',
    tags: ['信用卡', '激活流程', '高频场景'],
    description: '用于短信下发后，再进行外呼。适用于信用卡新卡激活场景，包含完整的激活流程指引和常见问题解答',
    category: '信用卡',
    line: 'retail',
    acquired: true, // 已获取
    templateName: '信用卡激活场景',
    templateType: ['信用卡', '信用卡激活'],
    followType: 'sms+manual',
    targetCustomer: '持有未激活信用卡的新客户，包括个人客户和企业客户',
    applicableActivity: '2026 年信用卡开卡礼活动、首刷礼活动、新户专享理财活动',
    financialProduct: '信用卡产品：标准金卡、白金卡、钻石卡；关联产品：消费分期、账单分期、现金分期',
    creator: '张三',
    createTime: '2026-01-15 10:30:00',
    institutions: ['杭州银行', '宁波银行'],
    processNodes: [
      {
        id: 1,
        type: 'start',
        name: '开始',
        x: 300,
        y: 50,
      },
      {
        id: 2,
        type: 'script',
        name: '开场白',
        x: 300,
        y: 180,
        content: {
          text: '您好，我是 XX 银行的智能客服，请问您现在方便接听电话吗？',
        },
      },
      {
        id: 3,
        type: 'verify',
        name: '身份核实',
        x: 300,
        y: 320,
        content: {
          text: '为了您的账户安全，需要先核实一下您的身份信息。请问您的身份证号码后四位是多少？',
        },
      },
      {
        id: 4,
        type: 'script',
        name: '确认激活',
        x: 300,
        y: 460,
        content: {
          text: '好的，身份验证通过。您的信用卡尾号是 1234，请问您需要激活这张卡片吗？',
        },
      },
      {
        id: 5,
        type: 'success_end',
        name: '激活成功',
        x: 300,
        y: 600,
        content: {
          text: '您的信用卡已成功激活，可以正常使用。祝您用卡愉快！',
        },
      },
      {
        id: 6,
        type: 'transfer',
        name: '转人工',
        x: 500,
        y: 460,
      },
      {
        id: 7,
        type: 'fail_end',
        name: '验证失败',
        x: 100,
        y: 460,
      },
    ],
    connections: [
      { id: 1, sourceNodeId: 1, targetNodeId: 2 },
      { id: 2, sourceNodeId: 2, targetNodeId: 3 },
      { id: 3, sourceNodeId: 3, targetNodeId: 4 },
      { id: 4, sourceNodeId: 4, targetNodeId: 5 },
      { id: 5, sourceNodeId: 4, targetNodeId: 6 },
      { id: 6, sourceNodeId: 3, targetNodeId: 7 },
    ],
    qaList: [
      {
        id: 1001,
        question: '如何办理信用卡激活？',
        qaType: '场景 QA',
        followProcess: '信用卡激活流程',
        intentType: '正向',
        replies: [
          {
            id: 1,
            replyText: '您好，办理信用卡激活非常简单。您可以通过以下几种方式进行激活：1. 拨打信用卡背面的客服热线；2. 登录手机银行 APP 激活；3. 前往就近的银行网点激活。',
            scene: '当前模板新增',
          },
          {
            id: 2,
            replyText: '激活信用卡需要您提供身份证号码、信用卡卡号和预留手机号码。',
            scene: '信用卡激活',
          },
        ],
      },
      {
        id: 1002,
        question: '账户被冻结了怎么办？',
        qaType: '场景 QA',
        followProcess: '账户解冻流程',
        intentType: '负向',
        replies: [
          {
            id: 1,
            replyText: '您好，账户冻结可能是由于安全原因。请您携带有效身份证件前往就近的银行网点办理解冻手续。',
            scene: '当前模板新增',
          },
        ],
      },
      {
        id: 1003,
        question: 'com.是骗子吗',
        qaType: '通用 QA',
        followProcess: '信任建立流程',
        intentType: '负向',
        replies: [
          {
            id: 1,
            replyText: '您好，我们是正规银行机构，不是骗子。我们的客服电话是 95XXX，您可以通过官网或官方 APP 核实我们的身份。',
            scene: '通用话术库',
          },
        ],
      },
      {
        id: 1004,
        question: 'yh.银行营业时间',
        qaType: '行业 QA',
        followProcess: '信息查询流程',
        intentType: '正向',
        replies: [
          {
            id: 1,
            replyText: '您好，我们银行的营业时间是周一至周五 9:00-17:00，周末 9:00-16:00。具体网点营业时间可能有所不同，建议您提前电话确认。',
            scene: '行业知识库',
          },
        ],
      },
    ],
    intentList: [
      {
        id: 1,
        intentName: 'sys.重复',
        intentType: '重复',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
      {
        id: 2,
        intentName: 'sys.肯定',
        intentType: '肯定',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
      {
        id: 3,
        intentName: 'sys.确认',
        intentType: '肯定',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
      {
        id: 4,
        intentName: 'sys.否定',
        intentType: '否定',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
      {
        id: 5,
        intentName: 'sys.中性 - 继续',
        intentType: '中性',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
    ],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您现在方便接听电话吗？', '如果您不方便接听，我们可以稍后再联系您。'],
      emptySemanticsReplies: ['抱歉，我没有听清楚您的问题，请您再说一遍好吗？'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，祝您生活愉快，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['您的输入有误，请重新输入。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['抱歉，当前人工坐席正忙，稍后会有工作人员联系您。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      {
        id: 1,
        uid: 1,
        replyText: '您好，您建行卡内有小额定期存款可以转出，请登录手机银行查看。',
        variableValue: '',
        recordFileName: 'nlg_1',
        audioUrl: '/audio/nlg_1.mp3',
        complianceStatus: '消保通过',
        audioUploadStatus: '已上传',
        source: '主流程',
      },
      {
        id: 2,
        uid: 2,
        replyText: '尊敬的客户您好，这里是建行客服中心，关于您之前咨询的理财产品，我们最近有新活动，年化收益率最高可达 4.5%，有兴趣了解一下吗？',
        variableValue: '{customerName: 张先生}',
        recordFileName: 'nlg_2',
        audioUrl: '/audio/nlg_2.mp3',
        complianceStatus: '消保通过',
        audioUploadStatus: '已上传',
        source: 'QA.你是哪个银行',
      },
      {
        id: 3,
        uid: 3,
        replyText: '您好，请问您现在方便接听电话吗？',
        variableValue: '',
        recordFileName: 'nlg_3',
        audioUrl: '',
        complianceStatus: '未消保',
        audioUploadStatus: '未上传',
        source: '主流程',
      },
      {
        id: 4,
        uid: 4,
        replyText: '抱歉，我没有听清楚您的问题，请您再说一遍好吗？',
        variableValue: '',
        recordFileName: 'nlg_4',
        audioUrl: '/audio/nlg_4.mp3',
        complianceStatus: '消保不通过',
        audioUploadStatus: '已上传',
        source: '语义为空设置',
      },
      {
        id: 5,
        uid: 5,
        replyText: '感谢您的接听，祝您生活愉快，再见！',
        variableValue: '',
        recordFileName: 'nlg_5',
        audioUrl: '/audio/nlg_5.mp3',
        complianceStatus: '消保通过',
        audioUploadStatus: '已上传',
        source: '强制挂断设置',
      },
    ],
    userCategories: [
      {
        id: 1,
        name: '有意向',
        priority: 1,
        isDefault: true,
        enabled: true,
        rules: [
          {
            id: 1,
            expression: '通话意图.肯定=1',
            resultType: '有意向',
            conditions: [
              { id: 1, fieldType: '通话意图', operator: '=', value: '肯定' },
            ],
          },
          {
            id: 2,
            expression: '通话意图.确认=1',
            resultType: '有意向',
            conditions: [
              { id: 2, fieldType: '通话意图', operator: '=', value: '确认' },
            ],
          },
        ],
      },
      {
        id: 2,
        name: '可能有意向',
        priority: 2,
        isDefault: false,
        enabled: true,
        rules: [
          {
            id: 3,
            expression: '通话意图.中性=1',
            resultType: '可能有意向',
            conditions: [
              { id: 3, fieldType: '通话意图', operator: '=', value: '中性' },
            ],
          },
        ],
      },
      {
        id: 3,
        name: '无意向',
        priority: 3,
        isDefault: true,
        enabled: true,
        rules: [
          {
            id: 4,
            expression: '通话意图.否定=1',
            resultType: '无意向',
            conditions: [
              { id: 4, fieldType: '通话意图', operator: '=', value: '否定' },
            ],
          },
          {
            id: 5,
            expression: '通话意图.重复>=1',
            resultType: '无意向',
            conditions: [
              { id: 5, fieldType: '通话意图', operator: '>=', value: '1' },
            ],
          },
        ],
      },
    ],
    systemSettings: {
      intentCustomerPush: true,
      pushIntentRange: ['有意向', '可能有意向'],
      intentRateRange: ['有意向', '可能有意向'],
      followUpFields: ['follow-note', 'add-wechat', 'connect-status', 'request-follow'],
      humanMachineCollaboration: true,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
  {
    id: 2,
    name: '账户回访',
    tags: ['回访', '账户管理'],
    description: '成年版的开卡回访，无需跟进',
    category: '回访',
    line: 'retail',
    acquired: false,
    templateName: '账户回访场景',
    templateType: ['回访', '账户管理'],
    followType: 'manual',
    targetCustomer: '新开立账户的个人客户',
    applicableActivity: '新户回访活动',
    financialProduct: '个人银行账户',
    creator: '李四',
    createTime: '2026-02-10 14:20:00',
    institutions: ['上海银行'],
    processNodes: [
      {
        id: 1,
        type: 'start',
        name: '开始',
        x: 300,
        y: 50,
      },
      {
        id: 2,
        type: 'script',
        name: '开场白',
        x: 300,
        y: 180,
        content: {
          text: '您好，我是 XX 银行的客服代表，请问您是 XXX 先生/女士吗？',
        },
      },
      {
        id: 3,
        type: 'script',
        name: '回访内容',
        x: 300,
        y: 320,
        content: {
          text: '感谢您选择我行，想了解一下您对我们服务的满意度，请问您对我们的服务还满意吗？',
        },
      },
      {
        id: 4,
        type: 'success_end',
        name: '结束',
        x: 300,
        y: 460,
      },
    ],
    connections: [
      { id: 1, sourceNodeId: 1, targetNodeId: 2 },
      { id: 2, sourceNodeId: 2, targetNodeId: 3 },
      { id: 3, sourceNodeId: 3, targetNodeId: 4 },
    ],
    qaList: [
      {
        id: 2001,
        question: '我对服务不满意',
        qaType: '场景 QA',
        followProcess: '投诉处理流程',
        intentType: '负向',
        replies: [
          {
            id: 1,
            replyText: '非常抱歉给您带来不好的体验，请问具体是哪方面让您不满意呢？我们会记录并改进。',
            scene: '当前模板新增',
          },
        ],
      },
      {
        id: 2002,
        question: '我想销户',
        qaType: '场景 QA',
        followProcess: '销户流程',
        intentType: '负向',
        replies: [
          {
            id: 1,
            replyText: '您好，如需销户，请您携带有效身份证件前往就近的银行网点办理。',
            scene: '当前模板新增',
          },
        ],
      },
    ],
    intentList: [
      {
        id: 1,
        intentName: 'sys.重复',
        intentType: '重复',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
      {
        id: 2,
        intentName: 'sys.肯定',
        intentType: '肯定',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
      {
        id: 3,
        intentName: 'sys.否定',
        intentType: '否定',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
    ],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您还在听吗？'],
      emptySemanticsReplies: ['抱歉，我没有听清楚，请您再说一遍。'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，祝您生活愉快，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['您的输入有误。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['抱歉，当前人工坐席正忙。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      {
        id: 1,
        uid: 1,
        replyText: '您好，我是 XX 银行的客服代表，请问您是 XXX 先生/女士吗？',
        variableValue: '',
        recordFileName: 'account_return_1',
        audioUrl: '/audio/account_return_1.mp3',
        complianceStatus: '消保通过',
        audioUploadStatus: '已上传',
        source: '主流程',
      },
      {
        id: 2,
        uid: 2,
        replyText: '感谢您选择我行，想了解一下您对我们服务的满意度。',
        variableValue: '',
        recordFileName: 'account_return_2',
        audioUrl: '/audio/account_return_2.mp3',
        complianceStatus: '消保通过',
        audioUploadStatus: '已上传',
        source: '主流程',
      },
    ],
    userCategories: [
      {
        id: 1,
        name: '满意',
        priority: 1,
        isDefault: false,
        enabled: true,
        rules: [
          {
            id: 1,
            expression: '通话意图。肯定=1',
            resultType: '满意',
            conditions: [
              { id: 1, fieldType: '通话意图', operator: '=', value: '肯定' },
            ],
          },
        ],
      },
      {
        id: 2,
        name: '不满意',
        priority: 2,
        isDefault: true,
        enabled: true,
        rules: [
          {
            id: 2,
            expression: '通话意图。否定=1',
            resultType: '不满意',
            conditions: [
              { id: 2, fieldType: '通话意图', operator: '=', value: '否定' },
            ],
          },
        ],
      },
    ],
    systemSettings: {
      intentCustomerPush: false,
      pushIntentRange: [],
      intentRateRange: [],
      followUpFields: [],
      humanMachineCollaboration: false,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
  {
    id: 3,
    name: '信用卡换卡',
    tags: ['信用卡', '换卡服务'],
    description: '信用卡到期换新卡',
    category: '信用卡',
    line: 'retail',
    acquired: true,
    templateName: '信用卡换卡场景',
    templateType: ['信用卡', '换卡服务'],
    followType: 'sms+manual',
    targetCustomer: '信用卡即将到期的持卡客户',
    applicableActivity: '信用卡到期换卡活动',
    financialProduct: '信用卡产品',
    creator: '王五',
    createTime: '2026-01-20 09:15:00',
    institutions: ['杭州银行', '宁波银行', '上海银行'],
    processNodes: [
      {
        id: 1,
        type: 'start',
        name: '开始',
        x: 300,
        y: 50,
      },
      {
        id: 2,
        type: 'script',
        name: '身份核实',
        x: 300,
        y: 180,
        content: {
          text: '您好，这里是 XX 银行信用卡中心，您的信用卡即将到期，需要为您办理换卡，请问是本人吗？',
        },
      },
      {
        id: 3,
        type: 'script',
        name: '确认换卡',
        x: 300,
        y: 320,
        content: {
          text: '好的，我们将为您免费寄送新卡，请问您的收件地址还是 XXX 吗？',
        },
      },
      {
        id: 4,
        type: 'success_end',
        name: '换卡成功',
        x: 300,
        y: 460,
      },
    ],
    connections: [
      { id: 1, sourceNodeId: 1, targetNodeId: 2 },
      { id: 2, sourceNodeId: 2, targetNodeId: 3 },
      { id: 3, sourceNodeId: 3, targetNodeId: 4 },
    ],
    qaList: [
      {
        id: 3001,
        question: '换卡需要收费吗',
        qaType: '场景 QA',
        followProcess: '费用说明流程',
        intentType: '中性',
        replies: [
          {
            id: 1,
            replyText: '您好，信用卡到期换卡是完全免费的，不会收取任何费用。',
            scene: '当前模板新增',
          },
        ],
      },
      {
        id: 3002,
        question: '新卡多久能收到',
        qaType: '场景 QA',
        followProcess: '物流查询流程',
        intentType: '正向',
        replies: [
          {
            id: 1,
            replyText: '一般情况下，新卡会在 5-7 个工作日内寄送到您的收件地址。',
            scene: '当前模板新增',
          },
        ],
      },
    ],
    intentList: [
      {
        id: 1,
        intentName: 'sys.重复',
        intentType: '重复',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
      {
        id: 2,
        intentName: 'sys.肯定',
        intentType: '肯定',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
      {
        id: 3,
        intentName: 'sys.确认',
        intentType: '肯定',
        priority: 1,
        updateTime: '2025-12-15 16:52:11',
      },
    ],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您还在听吗？'],
      emptySemanticsReplies: ['抱歉，我没有听清楚。'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['输入有误。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['坐席正忙。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      {
        id: 1,
        uid: 1,
        replyText: '您好，这里是 XX 银行信用卡中心，您的信用卡即将到期。',
        variableValue: '',
        recordFileName: 'card_replace_1',
        audioUrl: '/audio/card_replace_1.mp3',
        complianceStatus: '消保通过',
        audioUploadStatus: '已上传',
        source: '主流程',
      },
      {
        id: 2,
        uid: 2,
        replyText: '我们将为您免费寄送新卡。',
        variableValue: '',
        recordFileName: 'card_replace_2',
        audioUrl: '/audio/card_replace_2.mp3',
        complianceStatus: '消保通过',
        audioUploadStatus: '已上传',
        source: '主流程',
      },
    ],
    userCategories: [
      {
        id: 1,
        name: '同意换卡',
        priority: 1,
        isDefault: false,
        enabled: true,
        rules: [
          {
            id: 1,
            expression: '通话意图。肯定=1',
            resultType: '同意换卡',
            conditions: [
              { id: 1, fieldType: '通话意图', operator: '=', value: '肯定' },
            ],
          },
        ],
      },
      {
        id: 2,
        name: '拒绝换卡',
        priority: 2,
        isDefault: true,
        enabled: true,
        rules: [
          {
            id: 2,
            expression: '通话意图。否定=1',
            resultType: '拒绝换卡',
            conditions: [
              { id: 2, fieldType: '通话意图', operator: '=', value: '否定' },
            ],
          },
        ],
      },
    ],
    systemSettings: {
      intentCustomerPush: true,
      pushIntentRange: ['同意换卡'],
      intentRateRange: ['同意换卡'],
      followUpFields: ['follow-note', 'connect-status'],
      humanMachineCollaboration: true,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
  {
    id: 4,
    name: '存款到期续存',
    tags: ['存款', '续存服务'],
    description: '定期存款到期后提醒转存',
    category: '存款',
    line: 'retail',
    acquired: false,
    templateName: '存款到期续存场景',
    templateType: ['存款', '续存服务'],
    followType: 'sms',
    targetCustomer: '定期存款即将到期的客户',
    applicableActivity: '存款续存优惠活动',
    financialProduct: '定期存款产品',
    creator: '赵六',
    createTime: '2026-02-15 16:45:00',
    institutions: ['杭州银行'],
    processNodes: [
      {
        id: 1,
        type: 'start',
        name: '开始',
        x: 300,
        y: 50,
      },
      {
        id: 2,
        type: 'script',
        name: '到期提醒',
        x: 300,
        y: 180,
        content: {
          text: '您好，您的定期存款即将到期，我行推出优惠续存活动，年化利率最高可达 3.5%。',
        },
      },
      {
        id: 3,
        type: 'script',
        name: '确认续存',
        x: 300,
        y: 320,
        content: {
          text: '请问您需要办理续存吗？现在办理可享受优惠利率。',
        },
      },
      {
        id: 4,
        type: 'success_end',
        name: '续存成功',
        x: 300,
        y: 460,
      },
    ],
    connections: [
      { id: 1, sourceNodeId: 1, targetNodeId: 2 },
      { id: 2, sourceNodeId: 2, targetNodeId: 3 },
      { id: 3, sourceNodeId: 3, targetNodeId: 4 },
    ],
    qaList: [
      {
        id: 4001,
        question: '续存利率是多少',
        qaType: '场景 QA',
        followProcess: '利率说明流程',
        intentType: '正向',
        replies: [
          {
            id: 1,
            replyText: '您好，目前续存优惠利率最高可达 3.5%，具体利率根据存期而定。',
            scene: '当前模板新增',
          },
        ],
      },
    ],
    intentList: [
      { id: 1, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' },
      { id: 2, intentName: 'sys.肯定', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' },
    ],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您还在听吗？'],
      emptySemanticsReplies: ['抱歉，我没有听清楚。'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['输入有误。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['坐席正忙。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      {
        id: 1,
        uid: 1,
        replyText: '您好，您的定期存款即将到期，我行推出优惠续存活动。',
        variableValue: '',
        recordFileName: 'deposit_renew_1',
        audioUrl: '/audio/deposit_renew_1.mp3',
        complianceStatus: '消保通过',
        audioUploadStatus: '已上传',
        source: '主流程',
      },
    ],
    userCategories: [
      {
        id: 1,
        name: '同意续存',
        priority: 1,
        isDefault: false,
        enabled: true,
        rules: [
          { id: 1, expression: '通话意图。肯定=1', resultType: '同意续存', conditions: [{ id: 1, fieldType: '通话意图', operator: '=', value: '肯定' }] },
        ],
      },
      {
        id: 2,
        name: '拒绝续存',
        priority: 2,
        isDefault: true,
        enabled: true,
        rules: [
          { id: 2, expression: '通话意图。否定=1', resultType: '拒绝续存', conditions: [{ id: 2, fieldType: '通话意图', operator: '=', value: '否定' }] },
        ],
      },
    ],
    systemSettings: {
      intentCustomerPush: true,
      pushIntentRange: ['同意续存'],
      intentRateRange: ['同意续存'],
      followUpFields: ['follow-note'],
      humanMachineCollaboration: false,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
  {
    id: 5,
    name: '信用卡促活',
    tags: ['信用卡', '促活'],
    description: '用于短信下发后，再进行外呼。',
    category: '信用卡',
    line: 'retail',
    acquired: false,
    templateName: '信用卡促活场景',
    templateType: ['信用卡', '促活'],
    followType: 'sms+manual',
    targetCustomer: '休眠信用卡持卡客户',
    applicableActivity: '信用卡促活活动、消费返现活动',
    financialProduct: '信用卡产品',
    creator: '钱七',
    createTime: '2026-03-01 11:00:00',
    institutions: ['宁波银行'],
    processNodes: [
      { id: 1, type: 'start', name: '开始', x: 300, y: 50 },
      { id: 2, type: 'script', name: '活动介绍', x: 300, y: 180, content: { text: '您好，我行推出信用卡消费返现活动，刷卡满 1000 元返 100 元。' } },
      { id: 3, type: 'success_end', name: '结束', x: 300, y: 320 },
    ],
    connections: [{ id: 1, sourceNodeId: 1, targetNodeId: 2 }, { id: 2, sourceNodeId: 2, targetNodeId: 3 }],
    qaList: [
      {
        id: 5001,
        question: '活动什么时候结束',
        qaType: '场景 QA',
        followProcess: '活动说明流程',
        intentType: '中性',
        replies: [{ id: 1, replyText: '本次活动截止到本月底，请您尽快参与。', scene: '当前模板新增' }],
      },
    ],
    intentList: [{ id: 1, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' }],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您还在听吗？'],
      emptySemanticsReplies: ['抱歉，我没有听清楚。'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['输入有误。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['坐席正忙。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      { id: 1, uid: 1, replyText: '您好，我行推出信用卡消费返现活动。', variableValue: '', recordFileName: 'card_activate_1', audioUrl: '/audio/card_activate_1.mp3', complianceStatus: '消保通过', audioUploadStatus: '已上传', source: '主流程' },
    ],
    userCategories: [
      { id: 1, name: '有意向', priority: 1, isDefault: false, enabled: true, rules: [{ id: 1, expression: '通话意图。肯定=1', resultType: '有意向', conditions: [{ id: 1, fieldType: '通话意图', operator: '=', value: '肯定' }] }] },
      { id: 2, name: '无意向', priority: 2, isDefault: true, enabled: true, rules: [{ id: 2, expression: '通话意图。否定=1', resultType: '无意向', conditions: [{ id: 2, fieldType: '通话意图', operator: '=', value: '否定' }] }] },
    ],
    systemSettings: {
      intentCustomerPush: true,
      pushIntentRange: ['有意向'],
      intentRateRange: ['有意向'],
      followUpFields: ['follow-note', 'add-wechat'],
      humanMachineCollaboration: true,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
  {
    id: 6,
    name: '手机银行签到',
    tags: ['手机银行', '促活'],
    description: '手机银行促活类',
    category: '手机银行',
    line: 'retail',
    acquired: true,
    templateName: '手机银行签到场景',
    templateType: ['手机银行', '促活'],
    followType: 'sms',
    targetCustomer: '手机银行注册用户',
    applicableActivity: '手机银行签到活动、积分奖励活动',
    financialProduct: '手机银行',
    creator: '孙八',
    createTime: '2026-02-20 10:30:00',
    institutions: ['杭州银行', '上海银行'],
    processNodes: [
      { id: 1, type: 'start', name: '开始', x: 300, y: 50 },
      { id: 2, type: 'script', name: '签到提醒', x: 300, y: 180, content: { text: '您好，登录手机银行签到可领取积分，积分可兑换精美礼品。' } },
      { id: 3, type: 'success_end', name: '结束', x: 300, y: 320 },
    ],
    connections: [{ id: 1, sourceNodeId: 1, targetNodeId: 2 }, { id: 2, sourceNodeId: 2, targetNodeId: 3 }],
    qaList: [
      { id: 6001, question: '积分怎么兑换', qaType: '场景 QA', followProcess: '积分兑换流程', intentType: '正向', replies: [{ id: 1, replyText: '您可以在手机银行积分商城中兑换礼品。', scene: '当前模板新增' }] },
    ],
    intentList: [{ id: 1, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' }],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您还在听吗？'],
      emptySemanticsReplies: ['抱歉，我没有听清楚。'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['输入有误。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['坐席正忙。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      { id: 1, uid: 1, replyText: '您好，登录手机银行签到可领取积分。', variableValue: '', recordFileName: 'mobile_checkin_1', audioUrl: '/audio/mobile_checkin_1.mp3', complianceStatus: '消保通过', audioUploadStatus: '已上传', source: '主流程' },
    ],
    userCategories: [
      { id: 1, name: '已签到', priority: 1, isDefault: false, enabled: true, rules: [{ id: 1, expression: '通话意图。肯定=1', resultType: '已签到', conditions: [{ id: 1, fieldType: '通话意图', operator: '=', value: '肯定' }] }] },
      { id: 2, name: '未签到', priority: 2, isDefault: true, enabled: true, rules: [{ id: 2, expression: '通话意图。否定=1', resultType: '未签到', conditions: [{ id: 2, fieldType: '通话意图', operator: '=', value: '否定' }] }] },
    ],
    systemSettings: {
      intentCustomerPush: false,
      pushIntentRange: [],
      intentRateRange: [],
      followUpFields: [],
      humanMachineCollaboration: false,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
  {
    id: 7,
    name: '贷款营销场景',
    tags: ['贷款', '营销'],
    description: '个人消费贷款营销推广',
    category: '贷款',
    line: 'retail',
    acquired: false,
    templateName: '贷款营销场景',
    templateType: ['贷款', '个人消费贷款'],
    followType: 'manual',
    targetCustomer: '有贷款需求的个人客户',
    applicableActivity: '个人消费贷款推广活动',
    financialProduct: '个人消费贷款、信用贷款',
    creator: '周九',
    createTime: '2026-03-05 14:00:00',
    institutions: ['杭州银行', '宁波银行'],
    processNodes: [
      { id: 1, type: 'start', name: '开始', x: 300, y: 50 },
      { id: 2, type: 'script', name: '贷款介绍', x: 300, y: 180, content: { text: '您好，我行推出个人消费贷款，年化利率最低 3.85%，额度最高 50 万。' } },
      { id: 3, type: 'script', name: '意向确认', x: 300, y: 320, content: { text: '请问您有贷款需求吗？' } },
      { id: 4, type: 'success_end', name: '结束', x: 300, y: 460 },
    ],
    connections: [{ id: 1, sourceNodeId: 1, targetNodeId: 2 }, { id: 2, sourceNodeId: 2, targetNodeId: 3 }, { id: 3, sourceNodeId: 3, targetNodeId: 4 }],
    qaList: [
      { id: 7001, question: '贷款需要什么材料', qaType: '场景 QA', followProcess: '材料说明流程', intentType: '正向', replies: [{ id: 1, replyText: '您需要提供身份证、收入证明等材料。', scene: '当前模板新增' }] },
      { id: 7002, question: '多久能审批下来', qaType: '场景 QA', followProcess: '审批流程说明', intentType: '正向', replies: [{ id: 1, replyText: '一般 1-3 个工作日可以完成审批。', scene: '当前模板新增' }] },
    ],
    intentList: [{ id: 1, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' }, { id: 2, intentName: 'sys.肯定', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' }],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您还在听吗？'],
      emptySemanticsReplies: ['抱歉，我没有听清楚。'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['输入有误。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['坐席正忙。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      { id: 1, uid: 1, replyText: '您好，我行推出个人消费贷款，年化利率最低 3.85%。', variableValue: '', recordFileName: 'loan_market_1', audioUrl: '/audio/loan_market_1.mp3', complianceStatus: '消保通过', audioUploadStatus: '已上传', source: '主流程' },
      { id: 2, uid: 2, replyText: '请问您有贷款需求吗？', variableValue: '', recordFileName: 'loan_market_2', audioUrl: '/audio/loan_market_2.mp3', complianceStatus: '消保通过', audioUploadStatus: '已上传', source: '主流程' },
    ],
    userCategories: [
      { id: 1, name: '有意向', priority: 1, isDefault: false, enabled: true, rules: [{ id: 1, expression: '通话意图。肯定=1', resultType: '有意向', conditions: [{ id: 1, fieldType: '通话意图', operator: '=', value: '肯定' }] }] },
      { id: 2, name: '无意向', priority: 2, isDefault: true, enabled: true, rules: [{ id: 2, expression: '通话意图。否定=1', resultType: '无意向', conditions: [{ id: 2, fieldType: '通话意图', operator: '=', value: '否定' }] }] },
    ],
    systemSettings: {
      intentCustomerPush: true,
      pushIntentRange: ['有意向'],
      intentRateRange: ['有意向'],
      followUpFields: ['follow-note', 'connect-status', 'request-follow'],
      humanMachineCollaboration: true,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
  {
    id: 8,
    name: '企业开户通知',
    tags: ['对公业务', '开户通知'],
    description: '企业账户开户进度通知',
    category: '对公业务',
    line: 'corporate',
    acquired: false,
    templateName: '企业开户通知场景',
    templateType: ['对公业务', '开户通知'],
    followType: 'sms',
    targetCustomer: '申请开立企业账户的客户',
    applicableActivity: '企业开户服务',
    financialProduct: '企业银行账户',
    creator: '吴十',
    createTime: '2026-03-08 09:30:00',
    institutions: ['上海银行'],
    processNodes: [
      { id: 1, type: 'start', name: '开始', x: 300, y: 50 },
      { id: 2, type: 'script', name: '开户通知', x: 300, y: 180, content: { text: '您好，您的企业账户开户申请已受理，请在 3 个工作日内携带相关材料到网点办理。' } },
      { id: 3, type: 'success_end', name: '结束', x: 300, y: 320 },
    ],
    connections: [{ id: 1, sourceNodeId: 1, targetNodeId: 2 }, { id: 2, sourceNodeId: 2, targetNodeId: 3 }],
    qaList: [
      { id: 8001, question: '需要带什么材料', qaType: '场景 QA', followProcess: '材料说明流程', intentType: '中性', replies: [{ id: 1, replyText: '请携带营业执照、法人身份证、公章等材料。', scene: '当前模板新增' }] },
    ],
    intentList: [{ id: 1, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' }],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您还在听吗？'],
      emptySemanticsReplies: ['抱歉，我没有听清楚。'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['输入有误。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['坐席正忙。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      { id: 1, uid: 1, replyText: '您好，您的企业账户开户申请已受理。', variableValue: '', recordFileName: 'corp_account_1', audioUrl: '/audio/corp_account_1.mp3', complianceStatus: '消保通过', audioUploadStatus: '已上传', source: '主流程' },
    ],
    userCategories: [
      { id: 1, name: '已知晓', priority: 1, isDefault: false, enabled: true, rules: [{ id: 1, expression: '通话意图。肯定=1', resultType: '已知晓', conditions: [{ id: 1, fieldType: '通话意图', operator: '=', value: '肯定' }] }] },
      { id: 2, name: '未知晓', priority: 2, isDefault: true, enabled: true, rules: [{ id: 2, expression: '通话意图。否定=1', resultType: '未知晓', conditions: [{ id: 2, fieldType: '通话意图', operator: '=', value: '否定' }] }] },
    ],
    systemSettings: {
      intentCustomerPush: false,
      pushIntentRange: [],
      intentRateRange: [],
      followUpFields: [],
      humanMachineCollaboration: false,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
  {
    id: 9,
    name: '身份核验场景',
    tags: ['回访', '身份核验'],
    description: '客户身份信息核验确认',
    category: '回访',
    line: 'operation',
    acquired: false,
    templateName: '身份核验场景',
    templateType: ['回访', '身份核验'],
    followType: 'manual',
    targetCustomer: '需要进行身份核验的客户',
    applicableActivity: '身份信息核验活动',
    financialProduct: '银行账户',
    creator: '郑十一',
    createTime: '2026-03-10 15:20:00',
    institutions: ['杭州银行', '宁波银行', '上海银行'],
    processNodes: [
      { id: 1, type: 'start', name: '开始', x: 300, y: 50 },
      { id: 2, type: 'script', name: '身份核实', x: 300, y: 180, content: { text: '您好，为了保障您的账户安全，需要核实一下您的身份信息，请问您的身份证号码后四位是多少？' } },
      { id: 3, type: 'verify', name: '验证身份', x: 300, y: 320, content: { text: '好的，正在为您核实，请稍等。' } },
      { id: 4, type: 'success_end', name: '验证成功', x: 300, y: 460 },
    ],
    connections: [{ id: 1, sourceNodeId: 1, targetNodeId: 2 }, { id: 2, sourceNodeId: 2, targetNodeId: 3 }, { id: 3, sourceNodeId: 3, targetNodeId: 4 }],
    qaList: [
      { id: 9001, question: '为什么要核实身份', qaType: '场景 QA', followProcess: '安全说明流程', intentType: '中性', replies: [{ id: 1, replyText: '为了保障您的账户资金安全，我们需要核实您的身份信息。', scene: '当前模板新增' }] },
    ],
    intentList: [{ id: 1, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' }, { id: 2, intentName: 'sys.肯定', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' }],
    fallbackData: {
      silenceTimeout: 10000,
      silenceReplies: ['您好，请问您还在听吗？'],
      emptySemanticsReplies: ['抱歉，我没有听清楚。'],
      sameIntentRepeatMode: 'continuous',
      sameIntentRepeatCount: 2,
      sameProcessRepeatMode: 'continuous',
      sameProcessRepeatCount: 1,
      callTimeout: 300,
      hangupReplies: ['感谢您的接听，再见！'],
      keyInputTimeout: 10,
      keyErrorReplies: ['输入有误。'],
      keyErrorRepeatMode: 'continuous',
      keyErrorCount: 3,
      transferBusyReplies: ['坐席正忙。'],
      voiceBreakTimeout: 500,
      asrInitTimeout: 0,
    },
    scriptList: [
      { id: 1, uid: 1, replyText: '您好，为了保障您的账户安全，需要核实一下您的身份信息。', variableValue: '', recordFileName: 'identity_verify_1', audioUrl: '/audio/identity_verify_1.mp3', complianceStatus: '消保通过', audioUploadStatus: '已上传', source: '主流程' },
      { id: 2, uid: 2, replyText: '好的，正在为您核实，请稍等。', variableValue: '', recordFileName: 'identity_verify_2', audioUrl: '/audio/identity_verify_2.mp3', complianceStatus: '消保通过', audioUploadStatus: '已上传', source: '身份核实' },
    ],
    userCategories: [
      { id: 1, name: '验证通过', priority: 1, isDefault: false, enabled: true, rules: [{ id: 1, expression: '通话意图。肯定=1', resultType: '验证通过', conditions: [{ id: 1, fieldType: '通话意图', operator: '=', value: '肯定' }] }] },
      { id: 2, name: '验证失败', priority: 2, isDefault: true, enabled: true, rules: [{ id: 2, expression: '通话意图。否定=1', resultType: '验证失败', conditions: [{ id: 2, fieldType: '通话意图', operator: '=', value: '否定' }] }] },
    ],
    systemSettings: {
      intentCustomerPush: false,
      pushIntentRange: [],
      intentRateRange: [],
      followUpFields: [],
      humanMachineCollaboration: false,
      collaborationMode: 'transfer',
      transferCondition: 'trigger',
      collaborationStrategy: 'random-free',
    },
  },
]);

// 计算属性：过滤后的场景列表
const filteredSceneList = computed<SceneShopItem[]>(() => {
  let result = sceneShopList.value;
  
  // 按分类过滤
  if (selectedShopCategory.value !== '全部') {
    // 检查是否匹配子项
    const matchedCategory = shopMenuCategories.find(cat => 
      cat.items.includes(selectedShopCategory.value)
    );
    if (matchedCategory) {
      result = result.filter(item => item.category === matchedCategory.name);
    }
  }
  
  // 按条线过滤
  if (selectedLine.value) {
    result = result.filter(item => item.line === selectedLine.value);
  }
  
  // 按关键词过滤
  if (searchKeyword.value) {
    result = result.filter(item => 
      item.name.toLowerCase().includes(searchKeyword.value.toLowerCase())
    );
  }
  
  return result;
});

/**
 * 打开场景小店
 */
const handleOpenSceneShop = () => {
  console.log('打开场景小店');
  sceneShopVisible.value = true;
};

/**
 * 关闭场景小店
 */
const handleCloseSceneShop = () => {
  sceneShopVisible.value = false;
  handleSceneShopReset();
};

/**
 * 场景小店分类点击
 */
const handleShopCategoryClick = (category: string) => {
  selectedShopCategory.value = category;
  console.log('选择分类:', category);
};

/**
 * 切换场景小店分类展开/收起
 */
const toggleShopCategory = (index: number) => {
  shopMenuCategories[index].expanded = !shopMenuCategories[index].expanded;
};

/**
 * 场景小店搜索
 */
const handleSceneShopSearch = () => {
  console.log('场景小店搜索:', {
    keyword: searchKeyword.value,
    line: selectedLine.value,
    category: selectedShopCategory.value,
  });
  currentPage.value = 1;
};

/**
 * 场景小店重置
 */
const handleSceneShopReset = () => {
  searchKeyword.value = '';
  selectedLine.value = '';
  selectedShopCategory.value = '全部';
  currentPage.value = 1;
};

/**
 * 获取场景
 */
const handleGetScene = (scene: SceneShopItem) => {
  console.log('获取场景:', scene.name);
  // 更新获取状态
  scene.acquired = true;
  // TODO: 实现获取场景逻辑
};

/**
 * 模板检测
 */
const handleTemplateCheck = (scene: SceneShopItem) => {
  console.log('模板检测:', scene.name);
  // TODO: 实现模板检测逻辑
};

// ==================== 场景详情相关 ====================

// 场景详情弹窗可见性
const sceneDetailVisible = ref<boolean>(false);

// 当前查看的场景详情
const currentSceneDetail = ref<SceneShopItem | null>(null);

// 详情弹窗中激活的标签页
const detailActiveTabKey = ref<string>('basic');

// 画布缩放比例
const canvasZoom = ref<number>(100);

// 画布引用
const canvasRef = ref<HTMLElement | null>(null);

// QA 库搜索和筛选
const qaTypeFilter = ref<string>('all');
const qaSearchKeyword = ref<string>('');

// QA 库表格列配置
const qaReplyColumns = [
  {
    title: '序号',
    key: 'index',
    width: 60,
  },
  {
    title: '回复内容',
    dataIndex: 'replyText',
    key: 'replyText',
    ellipsis: true,
  },
  {
    title: '来源场景',
    dataIndex: 'scene',
    key: 'scene',
    width: 150,
  },
];

// 意图库搜索和筛选
const intentMenuFilter = ref<string>('all');
const intentSearchKeyword = ref<string>('');
const intentTypeFilter = ref<string>('');

// 意图库表格列配置
const intentColumns = [
  {
    title: 'ID',
    dataIndex: 'id',
    key: 'id',
    width: 80,
  },
  {
    title: '意图名称',
    dataIndex: 'intentName',
    key: 'intentName',
    width: 200,
  },
  {
    title: '意图类型',
    dataIndex: 'intentType',
    key: 'intentType',
    width: 120,
  },
  {
    title: '优先级',
    dataIndex: 'priority',
    key: 'priority',
    width: 100,
  },
  {
    title: '更新时间',
    dataIndex: 'updateTime',
    key: 'updateTime',
    width: 180,
  },
];

// 话术管理子 tab
const scriptSubTabKey = ref<string>('compliance');

// 话术搜索
const scriptSearchKeyword = ref<string>('');

// 变量搜索关键词
const variableSearchKeyword = ref<string>('');

// 变量列表数据（模拟数据）
const variableList = ref([
  { id: 1, variableName: 'customerName', variableValue: '张先生' },
  { id: 2, variableName: 'cardNo', variableValue: '****1234' },
  { id: 3, variableName: 'loanAmount', variableValue: '50 万' },
  { id: 4, variableName: 'points', variableValue: '10000' },
  { id: 5, variableName: 'productRate', variableValue: '4.5%' },
]);

// 变量表格列配置（仅查看，无操作列）
const variableColumns = [
  {
    title: '变量名',
    dataIndex: 'variableName',
    key: 'variableName',
    width: 200,
  },
  {
    title: '变量值',
    dataIndex: 'variableValue',
    key: 'variableValue',
    width: 400,
  },
];

// 用户分类选中的 ID
const selectedUserCategoryId = ref<number>(1);

// 话术表格列配置
const scriptColumns = [
  {
    title: 'uid',
    dataIndex: 'uid',
    key: 'uid',
    width: 70,
    fixed: 'left',
  },
  {
    title: '话术来源',
    dataIndex: 'source',
    key: 'source',
    width: 120,
  },
  {
    title: '话术文本',
    dataIndex: 'replyText',
    key: 'replyText',
    width: 350,
    ellipsis: true,
  },
  {
    title: '变量值',
    dataIndex: 'variableValue',
    key: 'variableValue',
    width: 100,
  },
  {
    title: '消保状态',
    dataIndex: 'complianceStatus',
    key: 'complianceStatus',
    width: 100,
  },
];

// 话术录音表格列配置
const scriptAudioColumns = [
  {
    title: 'uid',
    dataIndex: 'uid',
    key: 'uid',
    width: 70,
    fixed: 'left',
  },
  {
    title: '话术文本',
    dataIndex: 'replyText',
    key: 'replyText',
    width: 300,
    ellipsis: true,
  },
  {
    title: '录音文件名',
    dataIndex: 'recordFileName',
    key: 'recordFileName',
    width: 150,
  },
  {
    title: '录音上传状态',
    dataIndex: 'audioUploadStatus',
    key: 'audioUploadStatus',
    width: 100,
  },
  {
    title: '话术录音',
    key: 'audio',
    width: 150,
  },
];

/**
 * 打开场景详情
 */
const handleOpenSceneDetail = (scene: SceneShopItem) => {
  console.log('打开场景详情:', scene.name);
  currentSceneDetail.value = scene;
  detailActiveTabKey.value = 'basic';
  canvasZoom.value = 100;
  qaTypeFilter.value = 'all';
  qaSearchKeyword.value = '';
  intentMenuFilter.value = 'all';
  intentSearchKeyword.value = '';
  intentTypeFilter.value = '';
  scriptSubTabKey.value = 'compliance';
  scriptSearchKeyword.value = '';
  // 重置场景语音表单
  voiceForm.asrResource = 'sibichi';
  voiceForm.ttsResource = 'sibichi';
  voiceForm.voiceGenerateType = 'human';
  voiceForm.playbackRule = 'default';
  voiceForm.ttsVoiceName = '';
  voiceForm.ttsVoiceId = '';
  voiceForm.volume = 50;
  voiceForm.speed = 1.0;
  voiceForm.pitch = 1.0;
  sceneDetailVisible.value = true;
};

/**
 * 关闭场景详情
 */
const handleCloseSceneDetail = () => {
  sceneDetailVisible.value = false;
  currentSceneDetail.value = null;
};

/**
 * 获取条线文本
 */
const getLineText = (line?: string) => {
  const lineMap: Record<string, string> = {
    retail: '零售金融',
    corporate: '公司金融',
    operation: '运营管理',
  };
  return line ? lineMap[line] || line : '未分配';
};

/**
 * 获取跟进方式文本
 */
const getFollowTypeText = (followType?: string) => {
  const followTypeMap: Record<string, string> = {
    'sms+manual': '短信 + 人工',
    sms: '短信',
    manual: '人工',
    ai: 'AI 自动',
  };
  return followType ? followTypeMap[followType] || followType : '未设置';
};

/**
 * 获取标签页名称
 */
const getTabName = (key: string) => {
  const tabMap: Record<string, string> = {
    basic: '基本信息',
    process: '主流程设置',
    qa: 'QA 库',
    intent: '意图库',
    fallback: '流程兜底设置',
    script: '话术管理',
    'scene-voice': '场景语音',
    'user-classify': '用户分类',
    'system-settings': '场景系统设置',
    sms: '场景短信',
  };
  return tabMap[key] || '';
};

/**
 * 切换标签页
 */
const handleTabChange = (key: string) => {
  detailActiveTabKey.value = key;
};

/**
 * 画布缩放控制
 */
const handleZoomIn = () => {
  canvasZoom.value = Math.min(canvasZoom.value + 10, 200);
};

const handleZoomOut = () => {
  canvasZoom.value = Math.max(canvasZoom.value - 10, 50);
};

const handleResetZoom = () => {
  canvasZoom.value = 100;
};

/**
 * 画布点击事件
 */
const handleCanvasClick = () => {
  // 清空节点选择
};

/**
 * 获取节点图标
 */
const getNodeIcon = (type: string) => {
  const iconMap: Record<string, any> = {
    start: PlayCircleOutlined,
    script: MessageOutlined,
    success_end: CheckCircleOutlined,
    fail_end: CloseOutlined,
    transfer: CustomerServiceOutlined,
    verify: SafetyCertificateOutlined,
  };
  return iconMap[type] || PlayCircleOutlined;
};

/**
 * 获取连接线路径
 */
const getConnectionPath = (conn: any) => {
  const sourceNode = currentSceneDetail.value?.processNodes?.find((n: any) => n.id === conn.sourceNodeId);
  const targetNode = currentSceneDetail.value?.processNodes?.find((n: any) => n.id === conn.targetNodeId);
  
  if (!sourceNode || !targetNode) return '';
  
  const NODE_WIDTH = 200;
  const NODE_HEIGHT = 100;
  
  const startX = sourceNode.x + NODE_WIDTH / 2;
  const startY = sourceNode.y + NODE_HEIGHT;
  const endX = targetNode.x + NODE_WIDTH / 2;
  const endY = targetNode.y;
  
  // 贝塞尔曲线路径
  const controlPoint1Y = startY + Math.abs(endY - startY) / 2;
  const controlPoint2Y = endY - Math.abs(endY - startY) / 2;
  
  return `M ${startX} ${startY} C ${startX} ${controlPoint1Y}, ${endX} ${controlPoint2Y}, ${endX} ${endY}`;
};

/**
 * 获取 QA 类型颜色
 */
const getQaTypeColor = (qaType: string) => {
  const colorMap: Record<string, string> = {
    '场景 QA': 'blue',
    '行业 QA': 'green',
    '通用 QA': 'purple',
  };
  return colorMap[qaType] || 'default';
};

/**
 * QA 搜索
 */
const handleQaSearch = () => {
  console.log('QA 搜索:', {
    type: qaTypeFilter.value,
    keyword: qaSearchKeyword.value,
  });
};

/**
 * QA 重置
 */
const handleQaReset = () => {
  qaTypeFilter.value = 'all';
  qaSearchKeyword.value = '';
};

/**
 * 计算过滤后的 QA 列表
 */
const filteredQaList = computed<QaItem[]>(() => {
  const qaList = currentSceneDetail.value?.qaList || [];
  
  let result = qaList;
  
  // 按类型过滤
  if (qaTypeFilter.value !== 'all') {
    result = result.filter(qa => qa.qaType === qaTypeFilter.value);
  }
  
  // 按关键词过滤
  if (qaSearchKeyword.value) {
    result = result.filter(qa =>
      qa.question.toLowerCase().includes(qaSearchKeyword.value.toLowerCase())
    );
  }
  
  return result;
});

/**
 * 获取意图类型颜色
 */
const getIntentTypeColor = (intentType: string) => {
  const colorMap: Record<string, string> = {
    '肯定': 'green',
    '否定': 'red',
    '中性': 'blue',
    '重复': 'orange',
  };
  return colorMap[intentType] || 'default';
};

/**
 * 意图搜索
 */
const handleIntentSearch = () => {
  console.log('意图搜索:', {
    menuFilter: intentMenuFilter.value,
    keyword: intentSearchKeyword.value,
    typeFilter: intentTypeFilter.value,
  });
};

/**
 * 意图重置
 */
const handleIntentReset = () => {
  intentMenuFilter.value = 'all';
  intentSearchKeyword.value = '';
  intentTypeFilter.value = '';
};

/**
 * 计算过滤后的意图列表
 */
const filteredIntentList = computed<IntentItem[]>(() => {
  const intentList = currentSceneDetail.value?.intentList || [];
  
  let result = intentList;
  
  // 按类型过滤
  if (intentTypeFilter.value) {
    result = result.filter(intent => intent.intentType === intentTypeFilter.value);
  }
  
  // 按关键词过滤
  if (intentSearchKeyword.value) {
    result = result.filter(intent =>
      intent.intentName.toLowerCase().includes(intentSearchKeyword.value.toLowerCase())
    );
  }
  
  return result;
});

/**
 * 获取重复模式文本
 */
const getRepeatModeText = (mode?: string) => {
  const modeMap: Record<string, string> = {
    continuous: '连续触发',
    cumulative: '累计触发',
  };
  return mode ? modeMap[mode] || mode : '连续触发';
};

/**
 * 获取消保状态颜色
 */
const getComplianceStatusColor = (status?: string) => {
  const colorMap: Record<string, string> = {
    '消保通过': 'green',
    '消保不通过': 'red',
    '未消保': 'default',
  };
  return status ? colorMap[status] : 'default';
};

/**
 * 话术搜索
 */
const handleScriptSearch = () => {
  console.log('话术搜索:', {
    keyword: scriptSearchKeyword.value,
    subTab: scriptSubTabKey.value,
  });
};

/**
 * 话术重置
 */
const handleScriptReset = () => {
  scriptSearchKeyword.value = '';
  variableSearchKeyword.value = '';
};

/**
 * 变量搜索
 */
const handleVariableSearch = () => {
  console.log('搜索变量:', variableSearchKeyword.value);
};

/**
 * 播放音频
 */
const handlePlayAudio = (record: ScriptItem) => {
  console.log('播放音频:', record.recordFileName);
  // TODO: 实现音频播放逻辑
};

/**
 * 计算过滤后的话术列表
 */
const filteredScriptList = computed<ScriptItem[]>(() => {
  const scriptList = currentSceneDetail.value?.scriptList || [];
  
  let result = scriptList;
  
  // 按关键词过滤
  if (scriptSearchKeyword.value) {
    result = result.filter(script =>
      script.replyText.toLowerCase().includes(scriptSearchKeyword.value.toLowerCase())
    );
  }
  
  return result;
});

/**
 * 计算过滤后的变量列表
 */
const filteredVariableList = computed(() => {
  let result = variableList.value;
  
  // 按关键词过滤
  if (variableSearchKeyword.value) {
    result = result.filter(variable =>
      variable.variableName.toLowerCase().includes(variableSearchKeyword.value.toLowerCase())
    );
  }

  return result;
});

/**
 * 获取当前选中的用户分类规则
 */
const getCurrentUserCategoryRules = computed<CategoryRule[]>(() => {
  const userCategories = currentSceneDetail.value?.userCategories || [];
  const currentCategory = userCategories.find(cat => cat.id === selectedUserCategoryId.value);
  return currentCategory?.rules || [];
});

/**
 * 获取用户分类标签颜色
 */
const getUserCategoryColor = (category?: UserCategory) => {
  if (!category) return 'default';
  if (!category.enabled) return 'default';
  if (category.isDefault) return 'blue';
  return 'green';
};

/**
 * 获取跟进字段文本
 */
const getFollowUpFields = (fields?: string[]) => {
  if (!fields || fields.length === 0) return ['无'];
  const fieldMap: Record<string, string> = {
    'follow-note': '跟进备注',
    'add-wechat': '是否成功添加企微',
    'wechat-name': '微信名',
    'follow-continue': '客户跟进 - 持续跟进',
    'willing-transfer': '是否愿意调户',
    'appoint-date': '预约日期',
    'connect-status': '接通状态',
    'online-handled': '已线上办理',
    'has-balance': '活期是否有余额',
    'huaxia-product': '华夏是否购买过产品',
    'request-follow': '要求再次跟进',
    'request-sms': '要求发送短信',
    'other-channel-time': '其他渠道资金到账时间',
    'other-channel-amount': '其他渠道资金到账金额',
    'add-enterprise': '添加企微',
    'has-money-no-trust': '有资金但不信任',
    'other-business': '其他业务需求',
    'go-branch': '去网点处理非外呼业务',
    'visit-time': '到访时间',
    'demand': '需求',
    'wechat-status': '加微情况',
    'card-intent': '办卡意向',
    'handle-method': '办理方式',
    'deal-amount': '成交金额',
    'come-branch': '来网点',
    'customer-归属': '客户归属情况',
  };
  return fields.map(f => fieldMap[f] || f);
};

/**
 * 获取协同方式文本
 */
const getCollaborationModeText = (mode?: string) => {
  const modeMap: Record<string, string> = {
    'active-intervention': '主动介入',
    'transfer': '转人工',
    'both': '主动介入 + 转人工',
  };
  return mode ? modeMap[mode] || mode : '未设置';
};

/**
 * 获取转人工条件文本
 */
const getTransferConditionText = (condition?: string) => {
  const conditionMap: Record<string, string> = {
    'auto-transfer': '接通自动转接',
    'after-intro': '听完开场白自动转接',
    'trigger': '触发话术/QA 转接',
  };
  return condition ? conditionMap[condition] || condition : '未设置';
};

/**
 * 获取协同策略文本
 */
const getCollaborationStrategyText = (strategy?: string) => {
  const strategyMap: Record<string, string> = {
    'random-free': '随机空闲转接',
    'distribution': '按分发策略转接',
    'external-skill': '转接给外部技能组',
  };
  return strategy ? strategyMap[strategy] || strategy : '未设置';
};

/**
 * 是否有转人工话术
 */
const hasTransferScript = computed(() => {
  // TODO: 检查话术中是否配置了转人工
  return false;
});

// ==================== 场景语音相关 ====================
// 语音设置表单数据
const voiceForm = reactive({
  // 语音服务设置
  asrResource: 'sibichi', // 语音识别资源：aliyun-阿里公有云，sibichi-思必驰，moxiang-摸象
  ttsResource: 'sibichi', // 语音合成资源：aliyun-阿里公有云，sibichi-思必驰，moxiang-摸象

  // 语音生成方式
  voiceGenerateType: 'human', // 语音生成方式：human-真人录音，tts-语音合成

  // 录音播放规则
  playbackRule: 'default', // 录音播放规则：default-统一使用默认录音包，agent-匹配管户坐席录音包

  // 语音合成配置
  ttsVoiceName: '', // 合成音色名称
  ttsVoiceId: '', // 合成音色 ID
  volume: 50, // 音量 0-100
  speed: 1.0, // 语速 0.5-2.0
  pitch: 1.0, // 语调 0.5-2.0
});

// ==================== 场景短信相关 ====================
// 短信模版名称筛选
const smsTemplateNameFilter = ref('');

// 短信内容筛选
const smsContentFilter = ref('');

// 短信列表数据（模拟数据）
const smsList = ref([
  {
    id: 125,
    smsName: '挂机短信',
    smsCode: 'SMS122123',
    smsContent: '这是挂机短信',
    modifyTime: '2026-03-11 16:22:37',
  },
  {
    id: 126,
    smsName: '开场白介绍',
    smsCode: 'SMS002',
    smsContent: '您好，这里是${sys.bank}，来电是想邀请您参加我们最新的活动，您可以登录我们官网进查看活动详情。',
    modifyTime: '2024-12-31 14:26:04',
  },
]);

// 短信分页
const smsPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 2,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`,
  pageSizeOptions: ['10', '20', '50'],
  locale: {
    items_per_page: '条/页',
    jump_to: '跳转至',
    page: '页',
  },
});

// 短信总数
const smsTotal = ref(2);

// 短信表格列配置（仅查看，无操作列）
const smsColumns = [
  {
    title: '短信 ID',
    dataIndex: 'id',
    key: 'id',
    width: 80,
  },
  {
    title: '短信名称',
    dataIndex: 'smsName',
    key: 'smsName',
    width: 120,
  },
  {
    title: '短信 CODE',
    dataIndex: 'smsCode',
    key: 'smsCode',
    width: 120,
  },
  {
    title: '短信内容',
    dataIndex: 'smsContent',
    key: 'smsContent',
    width: 300,
    ellipsis: true,
  },
  {
    title: '最后一次修改时间',
    dataIndex: 'modifyTime',
    key: 'modifyTime',
    width: 160,
    sorter: true,
  },
];

// 短信搜索
const handleSmsSearch = () => {
  console.log('短信搜索:', {
    nameFilter: smsTemplateNameFilter.value,
    contentFilter: smsContentFilter.value,
  });
};

// 短信重置
const handleSmsReset = () => {
  smsTemplateNameFilter.value = '';
  smsContentFilter.value = '';
};

// 短信表格变化
const handleSmsTableChange = (pagination: any) => {
  smsPagination.current = pagination.current;
  smsPagination.pageSize = pagination.pageSize;
  smsPagination.total = pagination.total;
};

// 短信分页变化
const handleSmsPageChange = (page: number, pageSize: number) => {
  console.log('短信分页变化:', page, pageSize);
};

// 短信每页条数变化
const handleSmsPageSizeChange = (current: number, size: number) => {
  console.log('短信每页条数变化:', current, size);
};
</script>

<style scoped>
/* 场景管理容器 */
.scene-management {
  padding: 0;
}

/* 顶部工具栏 - 右上角按钮 */
.top-toolbar {
  display: flex;
  justify-content: flex-end;
  margin-top: 10px;
  margin-bottom: -10px;
  padding: 0 24px;
}

.toolbar-actions {
  display: flex;
  gap: 12px;
}

/* 标签页样式 */
.scene-tabs {
  background: #fff;
  padding: 0px 24px;
}

.scene-tabs :deep(.ant-tabs-nav) {
  margin-bottom: 16px;
}

.scene-tabs :deep(.ant-tabs-tab) {
  font-size: 15px;
  font-weight: 500;
}

/* 场景小店按钮高亮样式 */
.scene-shop-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  border: none !important;
  position: relative;
  overflow: hidden;
  animation: shop-btn-glow 2s ease-in-out infinite;
  color: #fff !important;
  font-weight: 600;
  padding: 4px 16px;
  height: 36px;
}

.scene-shop-btn:hover {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%) !important;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4) !important;
}

@keyframes shop-btn-glow {
  0%, 100% {
    box-shadow: 0 2px 10px rgba(102, 126, 234, 0.3);
  }
  50% {
    box-shadow: 0 4px 20px rgba(102, 126, 234, 0.5);
  }
}

/* 搜索区域 */
.search-area {
  padding: 16px;
  margin-bottom: 16px;
}

/* 工具栏区域 */
.toolbar-area {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 0 4px;
}

.toolbar-left {
  display: flex;
  align-items: center;
}

.total-info {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
}

.toolbar-right {
  display: flex;
  align-items: center;
}

/* 场景列表 */
.scene-list {
  margin-bottom: 24px;
}

/* 每个场景卡片行 - 独占一行 */
.scene-card-row {
  margin-bottom: 16px;
}

.scene-card-row:last-child {
  margin-bottom: 0;
}

/* 场景卡片 */
.scene-card {
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 0px;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
}

.scene-card:hover {
  border-color: #1890ff;
  box-shadow: 0 4px 12px rgba(24, 144, 255, 0.15);
}

/* 卡片头部 */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  background: #e6f7ff;
  border-radius: 8px 8px 0 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 0;
}

.scene-title {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.title-indicator {
  width: 4px;
  height: 18px;
  background: #1890ff;
  border-radius: 2px;
  flex-shrink: 0;
}

.title-text {
  font-size: 16px;
  font-weight: 600;
  color: #262626;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.header-right {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 12px;
}

/* 启用开关包装器 */
.enable-switch-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-left: 8px;
  border-left: 1px solid #d9d9d9;
}

.switch-label {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
}

/* 右上角启用开关和发布按钮样式 */
.header-btn {
  height: 28px;
  font-weight: 600;
}

/* 发布至场景小店按钮样式 */
.header-btn.publish-shop-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  box-shadow: 0 2px 6px rgba(102, 126, 234, 0.3);
  transition: all 0.3s;
}

.header-btn.publish-shop-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 3px 10px rgba(102, 126, 234, 0.5);
}

/* 从场景小店下架按钮样式 */
.header-btn.unpublish-shop-btn {
  font-weight: 600;
  color: #8c8c8c;
  border-color: #d9d9d9;
}

.header-btn.unpublish-shop-btn:hover {
  color: #595959;
  border-color: #8c8c8c;
}

/* 卡片内容 */
.card-body {
  flex: 1;
  margin-left: 24px;
  margin-bottom: 12px;

}

.body-wrapper {
  display: flex;
  gap: 24px;
}

.body-left {
  flex: 1;
  min-width: 0;
}

.info-grid {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px 24px;
}

.info-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.info-item .label {
  color: #8c8c8c;
  flex-shrink: 0;
  white-space: nowrap;
  font-size: 14px;
  text-align: left;
}

.info-item .value {
  color: #262626;
  word-break: break-word;
  font-size: 14px;
  text-align: left;
}

.body-right {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  margin-right: 12px;
}

.action-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px 12px;
  align-content: center;
}

.action-link {
  font-size: 14px;
  color: #1890ff;
  cursor: pointer;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
  text-align: center;
  background: transparent;
}

.action-link:hover {
  color: #40a9ff;
}

.action-link.danger {
  color: #ff4d4f;
}

.action-link.danger:hover {
  color: #ff7875;
}

.update-link {
  color: #1890ff;
  font-size: 14px;
  margin-left: 4px;
  cursor: pointer;
}

.update-link:hover {
  color: #40a9ff;
}

/* 卡片底部 */
.card-footer {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 16px;
  padding-top: 12px;
  padding-bottom: 12px;
  margin-left: 24px;
  border-top: 1px solid #f0f0f0;
}

.footer-link {
  font-size: 14px;
  color: #1890ff;
  cursor: pointer;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
  background: transparent;
}

.footer-link.blue {
  color: #1890ff;
  background: transparent;
}

.footer-link.blue:hover {
  color: #40a9ff;
}

/* 空状态 */
.scene-tabs :deep(.ant-empty) {
  padding: 48px 0;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .body-wrapper {
    flex-direction: column;
  }

  .body-right {
    width: 100%;
  }

  .action-grid {
    width: 100%;
    min-width: auto;
  }

  .info-row {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .card-header {
    flex-direction: column;
    gap: 8px;
  }

  .header-right {
    width: 100%;
    text-align: right;
  }

  .card-footer {
    flex-direction: column;
    align-items: flex-start;
  }

  .card-footer .footer-link {
    width: 100%;
    text-align: center;
  }
}

/* ==================== 场景小店弹窗样式 ==================== */
.scene-shop-modal {
  :deep(.ant-modal-body) {
    padding: 0;
  }
}

.scene-shop-container {
  display: flex;
  min-height: 600px;
  max-height: 70vh;
}

.scene-shop-modal .sidebar {
  width: 220px;
  border-right: 1px solid #f0f0f0;
  background-color: #fff;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
}

/* 场景小店左侧菜单 */
.scene-shop-modal .left-menu {
  flex: 1;
  overflow-y: auto;
  padding: 0;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  margin: 12px;
  height: calc(70vh - 144px);
}

/* 全部选项 */
.scene-shop-modal .menu-all-item {
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 500;
  color: #333;
  cursor: pointer;
  transition: all 0.3s;
  border-bottom: 1px solid #f0f0f0;
}

.scene-shop-modal .menu-all-item:hover {
  background: #e6f7ff;
  color: #1890ff;
}

.scene-shop-modal .menu-all-item.active {
  background: #e6f7ff;
  color: #1890ff;
}

.scene-shop-modal .menu-category {
  border-bottom: 1px solid #f0f0f0;
}

.scene-shop-modal .menu-category:last-child {
  border-bottom: none;
}

.scene-shop-modal .menu-category-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 12px;
  cursor: pointer;
  transition: background 0.3s;
}

.scene-shop-modal .menu-category-title:hover {
  background: #f5f5f5;
}

.scene-shop-modal .category-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.scene-shop-modal .menu-arrow-down {
  transform: rotate(180deg);
  transition: transform 0.3s;
  color: #999;
}

.scene-shop-modal .menu-sub-items {
  background: #fafafa;
  padding: 8px 0;
}

.scene-shop-modal .menu-sub-item {
  padding: 12px 12px 12px 24px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s;
}

.scene-shop-modal .menu-sub-item:hover {
  background: #e6f7ff;
  color: #1890ff;
}

.scene-shop-modal .menu-sub-item.active {
  background: #e6f7ff;
  color: #1890ff;
  font-weight: 500;
}

.scene-shop-modal .content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.scene-shop-modal .search-bar {
  padding: 16px;
  border-bottom: 1px solid #f0f0f0;
  background-color: #fff;
}

.scene-shop-modal .search-row {
  display: flex;
  gap: 12px;
  align-items: center;
}

.scene-shop-modal .search-input {
  width: 300px;
}

.scene-shop-modal .line-select {
  width: 150px;
}

.scene-shop-modal .scene-shop-list {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background-color: #fafafa;
}

.scene-shop-modal .scene-shop-card {
  height: 100%;
  display: flex;
  flex-direction: column;
  border-radius: 8px;
  transition: all 0.3s;
}

.scene-shop-modal .scene-shop-card :deep(.ant-card-body) {
  display: flex;
  flex-direction: column;
  flex: 1;
  padding: 16px;
}

.scene-shop-modal .scene-shop-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.scene-shop-modal .scene-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  flex-shrink: 0;
}

.scene-shop-modal .scene-name {
  font-weight: 600;
  font-size: 15px;
  color: #1f1f1f;
  flex: 1;
}

.scene-shop-modal .scene-tags {
  margin-bottom: 8px;
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  flex-shrink: 0;
}

.scene-shop-modal .scene-description {
  flex: 1;
  color: #666;
  font-size: 13px;
  line-height: 1.6;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  margin-bottom: 16px;
  min-height: 60px;
}

.scene-shop-modal .scene-actions {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
  margin-top: auto;
  flex-shrink: 0;
}

.scene-shop-modal .scene-actions .acquired-text {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #52c41a;
  font-size: 14px;
  font-weight: 500;
  cursor: default;
}

.scene-shop-modal .scene-actions .get-scene-link {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #1677ff;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
}

.scene-shop-modal .scene-actions .get-scene-link:hover {
  color: #40a9ff;
  background-color: #e6f7ff;
}

.scene-shop-modal .pagination-container {
  padding: 16px;
  border-top: 1px solid #f0f0f0;
  background-color: #fff;
  display: flex;
  justify-content: flex-end;
}

/* ==================== 场景详情弹窗样式 ==================== */
.scene-detail-modal {
  :deep(.ant-modal-body) {
    padding: 0;
  }
}

.scene-detail-container {
  max-height: 70vh;
  overflow-y: auto;
}

.detail-tabs-section {
  padding: 0 24px;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
}

.detail-content {
  padding: 24px;
  background: #fafafa;
  min-height: 300px;
}

/* 主流程画布样式 */
.process-content {
  padding: 0;
  overflow: hidden;
}

.process-canvas-wrapper {
  position: relative;
  height: 600px;
  overflow: auto;
  background: #f5f5f5;
}

.canvas-toolbar {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.toolbar-left,
.toolbar-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.zoom-text {
  font-size: 13px;
  color: #595959;
  min-width: 70px;
}

.process-canvas {
  position: relative;
  min-width: 100%;
  min-height: 100%;
  overflow: auto;
}

.canvas-content {
  position: relative;
  min-width: 2000px;
  min-height: 1500px;
  transition: transform 0.3s ease;
}

/* 连接线层 */
.connection-layer {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 1;
}

.connection-layer .connection-hit {
  fill: none;
  stroke: transparent;
  stroke-width: 20;
  cursor: pointer;
  pointer-events: stroke;
}

.connection-layer .connection-line {
  fill: none;
  stroke: #91d5ff;
  stroke-width: 2;
  marker-end: url(#arrowhead);
  pointer-events: none;
  transition: all 0.3s;
}

/* 流程节点 */
.process-node {
  position: absolute;
  width: 200px;
  height: 100px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 2;
  cursor: move;
  transition: box-shadow 0.3s, transform 0.2s;
  user-select: none;
}

.process-node:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

/* 节点类型样式 */
.process-node.node-type-start {
  border: 2px solid #52c41a;
}
.process-node.node-type-start .node-header {
  background: #f6ffed;
  color: #52c41a;
}

.process-node.node-type-script {
  border: 2px solid #1890ff;
}
.process-node.node-type-script .node-header {
  background: #e6f7ff;
  color: #1890ff;
}

.process-node.node-type-success_end {
  border: 2px solid #52c41a;
}
.process-node.node-type-success_end .node-header {
  background: #f6ffed;
  color: #52c41a;
}

.process-node.node-type-fail_end {
  border: 2px solid #ff4d4f;
}
.process-node.node-type-fail_end .node-header {
  background: #fff1f0;
  color: #ff4d4f;
}

.process-node.node-type-transfer {
  border: 2px solid #722ed1;
}
.process-node.node-type-transfer .node-header {
  background: #f9f0ff;
  color: #722ed1;
}

.process-node.node-type-verify {
  border: 2px solid #faad14;
}
.process-node.node-type-verify .node-header {
  background: #fff7e6;
  color: #faad14;
}

/* 节点头部 */
.node-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  border-radius: 6px 6px 0 0;
  font-weight: 500;
  font-size: 14px;
}

.node-header .anticon {
  font-size: 16px;
}

.node-title {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 节点内容 */
.node-content {
  padding: 12px;
  min-height: 50px;
}

.node-desc {
  font-size: 13px;
  color: #595959;
  line-height: 1.6;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 连接点 */
.node-connector {
  position: absolute;
  width: 12px;
  height: 12px;
  background: #fff;
  border: 2px solid #1890ff;
  border-radius: 50%;
  cursor: crosshair;
  transition: all 0.2s;
  z-index: 3;
}

.node-connector:hover {
  background: #1890ff;
  transform: scale(1.3);
}

.node-connector-out {
  left: 50%;
  transform: translateX(-50%);
  bottom: -6px;
}

.node-connector-in {
  left: 50%;
  transform: translateX(-50%);
  top: -6px;
}

/* ==================== QA 库样式 ==================== */
.qa-content {
  padding: 0;
  overflow: hidden;
}

.qa-scroll-wrapper {
  flex: 1;
  overflow: auto;
  background: #f5f5f5;
  position: relative;
  min-height: 500px;
}

.qa-toolbar {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.toolbar-left,
.toolbar-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* QA 卡片列表 */
.qa-list {
  padding: 16px;
}

.qa-card {
  background: #fff;
  border-radius: 8px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: box-shadow 0.3s;
}

.qa-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.qa-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.qa-id {
  font-size: 12px;
  color: #8c8c8c;
}

.qa-question {
  font-size: 15px;
  font-weight: 600;
  color: #262626;
}

.qa-process {
  font-size: 13px;
  color: #595959;
}

/* 回复表格 */
.reply-table-wrapper {
  padding: 16px;
}

.reply-text {
  color: #262626;
  font-size: 13px;
  line-height: 1.6;
}

.scene-tag {
  color: #1890ff;
  font-size: 12px;
}

/* ==================== 意图库样式 ==================== */
.intent-content {
  padding: 0;
  overflow: hidden;
}

.intent-scroll-wrapper {
  flex: 1;
  overflow: auto;
  background: #f5f5f5;
  position: relative;
  min-height: 500px;
}

.intent-toolbar {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.intent-table-wrapper {
  padding: 16px;
  background: #fff;
  margin: 16px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* ==================== 流程兜底设置样式 ==================== */
.fallback-content {
  padding: 0;
  overflow: hidden;
}

.fallback-form-wrapper {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.form-section {
  margin-bottom: 24px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  overflow: hidden;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #fafafa;
  border-bottom: 1px solid #f0f0f0;
  font-weight: 600;
  font-size: 15px;
  color: #262626;
}

.title-bar {
  width: 4px;
  height: 16px;
  background: #1890ff;
  border-radius: 2px;
}

.section-content {
  padding: 16px 24px;
}

.fallback-item {
  margin-bottom: 16px;
  display: flex;
  align-items: flex-start;
  gap: 12px;
  flex-wrap: wrap;
}

.fallback-item:last-child {
  margin-bottom: 0;
}

.fallback-label {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
  min-width: 140px;
}

.fallback-value {
  font-size: 14px;
  color: #262626;
  flex: 1;
}

.fallback-reply-list {
  width: 100%;
  margin-top: 8px;
}

.fallback-reply-item {
  display: flex;
  gap: 8px;
  padding: 12px 16px;
  background: #f5f5f5;
  border-radius: 4px;
  margin-bottom: 8px;
}

.fallback-reply-item:last-child {
  margin-bottom: 0;
}

.reply-index {
  font-size: 13px;
  color: #8c8c8c;
  min-width: 24px;
}

.reply-text {
  font-size: 14px;
  color: #262626;
  line-height: 1.6;
  flex: 1;
}

/* ==================== 话术管理样式 ==================== */
.script-content {
  padding: 0;
  overflow: hidden;
}

.script-scroll-wrapper {
  flex: 1;
  overflow: auto;
  background: #f5f5f5;
  position: relative;
  min-height: 500px;
}

.script-sub-tabs {
  background: #fff;
  padding: 0 16px;
  border-bottom: 1px solid #f0f0f0;
}

.script-sub-content {
  padding: 16px;
}

.script-toolbar-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 12px 16px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.script-toolbar-left,
.script-toolbar-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.script-list {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
}

.script-table-wrapper {
  padding: 16px;
}

.script-reply-text {
  color: #262626;
  font-size: 13px;
  line-height: 1.6;
  display: block;
  max-width: 350px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.no-audio-text {
  color: #8c8c8c;
  font-size: 13px;
}

/* 话术变量样式 */
.variable-name {
  font-size: 14px;
  color: #262626;
  font-weight: 500;
  font-family: monospace;
}

.variable-value-text {
  color: #595959;
  font-size: 13px;
  line-height: 1.6;
  display: block;
}

/* ==================== 用户分类样式 ==================== */
.user-classify-content {
  padding: 0;
  overflow: hidden;
}

.user-classify-wrapper {
  display: flex;
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  min-height: 500px;
}

.classify-sidebar {
  width: 240px;
  border-right: 1px solid #f0f0f0;
  padding: 16px;
  background: #fafafa;
}

.sidebar-title {
  font-size: 15px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #d9d9d9;
}

.category-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  margin-bottom: 8px;
  background: #fff;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
  border: 1px solid #f0f0f0;
}

.category-item:hover {
  background: #e6f7ff;
  border-color: #1890ff;
}

.category-item.active {
  background: #e6f7ff;
  border-color: #1890ff;
}

.category-name {
  font-size: 14px;
  color: #262626;
  font-weight: 500;
}

.category-item-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.classify-main-content {
  flex: 1;
  padding: 24px;
  overflow: auto;
}

.default-rule-alert-wrapper {
  margin-bottom: 20px;
}

.default-rule-alert {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  background: #fffbe6;
  border: 1px solid #ffe58f;
  border-radius: 4px;
  font-size: 14px;
  color: #595959;
}

.rule-list-container {
  min-height: 300px;
}

.rule-item {
  margin-bottom: 16px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  overflow: hidden;
  background: #fff;
}

.rule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #fafafa;
  border-bottom: 1px solid #f0f0f0;
}

.rule-index {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
}

.rule-content {
  padding: 16px;
}

.condition-display-list {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.condition-display-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #f5f5f5;
  border-radius: 4px;
}

.condition-field {
  font-size: 13px;
  color: #262626;
  font-weight: 500;
}

.condition-operator {
  font-size: 13px;
  color: #1890ff;
  font-weight: 500;
}

.condition-value {
  font-size: 13px;
  color: #595959;
}

.condition-connector {
  font-size: 13px;
  color: #faad14;
  font-weight: 500;
}

/* ==================== 场景系统设置样式 ==================== */
.system-settings-content {
  overflow: auto;
  min-height: 400px;
}

.system-settings-wrapper {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  min-height: 400px;
}

.settings-section {
  margin-bottom: 24px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  overflow: hidden;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #fafafa;
  border-bottom: 1px solid #f0f0f0;
  font-weight: 600;
  font-size: 15px;
  color: #262626;
}

.title-bar {
  width: 4px;
  height: 16px;
  background: #1890ff;
  border-radius: 2px;
}

.section-content {
  padding: 24px;
}

.settings-item {
  margin-bottom: 20px;
  display: flex;
  align-items: flex-start;
  gap: 12px;
  flex-wrap: wrap;
}

.settings-item:last-child {
  margin-bottom: 0;
}

.settings-label {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
  min-width: 140px;
}

.settings-value {
  font-size: 14px;
  color: #262626;
  flex: 1;
}

.settings-value-inline {
  font-size: 14px;
  color: #262626;
  margin-left: 8px;
}

.settings-tip {
  width: 100%;
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 4px;
  line-height: 1.5;
}

.follow-up-fields {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.field-tag {
  display: inline-block;
  padding: 4px 12px;
  background: #f5f5f5;
  border-radius: 4px;
  font-size: 13px;
  color: #262626;
}

.success-text {
  color: #52c41a;
  font-weight: 500;
}

.error-text {
  color: #ff4d4f;
  font-weight: 500;
}

/* ==================== 场景短信样式 ==================== */
.sms-content {
  padding: 0;
  overflow: hidden;
}

.sms-scroll-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;
  width: 100%;
}

/* 顶部操作区 */
.sms-toolbar-section {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-shrink: 0;
  width: 100%;
}

.sms-toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.sms-toolbar-right {
  display: flex;
  align-items: center;
}

/* 短信列表 */
.sms-list {
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  flex: 1;
  overflow: hidden;
}

.sms-table-wrapper {
  flex: 1;
  overflow: auto;
  padding: 16px 24px;
}

.sms-table-wrapper :deep(.ant-table) {
  font-size: 13px;
}

.sms-table-wrapper :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
}

.sms-name {
  font-size: 14px;
  color: #262626;
  font-weight: 500;
}

.sms-code {
  font-size: 13px;
  color: #595959;
  font-family: monospace;
}

.sms-content-text {
  display: block;
  white-space: normal;
  line-height: 1.6;
  color: #333;
}

.modify-time {
  font-size: 13px;
  color: #8c8c8c;
}

/* 分页区域 */
.sms-pagination {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 16px;
}

.sms-pagination .total-text {
  font-size: 14px;
  color: #595959;
}

/* 短信滚动条样式 */
.sms-list::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.sms-list::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 4px;
}

.sms-list::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 4px;
}

.sms-list::-webkit-scrollbar-thumb:hover {
  background: #999;
}

/* ==================== 场景语音样式 ==================== */
.scene-voice-content {
  padding: 0;
  overflow: hidden;
}

.scene-voice-wrapper {
  height: 100%;
  overflow-y: auto;
  padding: 24px;
}

/* 语音设置表单 */
.voice-settings-form {
  max-width: 900px;
  margin: 0 auto;
}

/* 设置区块 */
.settings-section {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  margin-bottom: 24px;
}

.section-header {
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 500;
  color: #262626;
}

.title-bar {
  width: 4px;
  height: 16px;
  background: #1890ff;
  border-radius: 2px;
}

.section-content {
  padding: 24px;
}

/* 设置项 */
.setting-item {
  display: flex;
  align-items: flex-start;
  padding: 16px 0;
  border-bottom: 1px solid #f5f5f5;
}

.setting-item:last-child {
  border-bottom: none;
}

.setting-label {
  width: 200px;
  flex-shrink: 0;
  font-size: 14px;
  color: #262626;
  line-height: 32px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.setting-control {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 16px;
}

/* 滑块数值显示 */
.slider-value {
  min-width: 60px;
  margin-left: 16px;
  font-size: 14px;
  color: #595959;
  font-family: monospace;
}

/* 滚动条样式 */
.scene-voice-wrapper::-webkit-scrollbar {
  width: 8px;
}

.scene-voice-wrapper::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 4px;
}

.scene-voice-wrapper::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 4px;
}

.scene-voice-wrapper::-webkit-scrollbar-thumb:hover {
  background: #999;
}
</style>
