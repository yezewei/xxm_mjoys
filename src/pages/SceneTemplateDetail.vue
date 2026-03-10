<template>
  <div class="scene-template-detail">
    <!-- 顶部标签页 -->
    <div class="tabs-section">
      <a-tabs v-model:activeKey="activeTabKey" @change="handleTabChange">
        <a-tab-pane key="basic" tab="基本信息" />
        <a-tab-pane key="process" tab="主流程设置" />
        <a-tab-pane key="qa" tab="QA 库" />
        <a-tab-pane key="intent" tab="意图库" />
        <a-tab-pane key="user-classify" tab="用户分类" />
        <a-tab-pane key="fallback" tab="流程兜底设置" />
      </a-tabs>
    </div>

    <!-- 基本信息内容区域 -->
    <div v-if="activeTabKey === 'basic'" class="basic-content">
      <div class="basic-form-wrapper">
        <a-descriptions bordered :column="2" size="large">
          <a-descriptions-item label="模板名称" :span="1">
            {{ basicForm.templateName }}
          </a-descriptions-item>
          <a-descriptions-item label="模板类型" :span="1">
            {{ templateTypeText }}
          </a-descriptions-item>
          <a-descriptions-item label="标签" :span="1">
            <a-tag v-for="tag in basicForm.tags" :key="tag" color="blue">
              {{ tag }}
            </a-tag>
          </a-descriptions-item>
          <a-descriptions-item label="跟进方式" :span="1">
            {{ followTypeText }}
          </a-descriptions-item>
          <a-descriptions-item label="模板描述" :span="2">
            {{ basicForm.description || '暂无描述' }}
          </a-descriptions-item>
          <a-descriptions-item label="适用客群" :span="2">
            {{ basicForm.targetCustomer || '暂无' }}
          </a-descriptions-item>
          <a-descriptions-item label="适用活动" :span="2">
            {{ basicForm.applicableActivity || '暂无' }}
          </a-descriptions-item>
          <a-descriptions-item label="金融产品" :span="2">
            {{ basicForm.financialProduct || '暂无' }}
          </a-descriptions-item>
        </a-descriptions>
      </div>
    </div>

    <!-- QA 库内容区域 -->
    <div v-else-if="activeTabKey === 'qa'" class="qa-content">
      <div class="qa-scroll-wrapper">
        <!-- 顶部操作区 -->
        <div class="toolbar-section">
        <div class="toolbar-left">
          <a-space>
            <a-select
              v-model:value="qaTypeFilter"
              placeholder="全部"
              style="width: 150px"
              allow-clear
              @change="handleQaTypeChange"
            >
              <a-select-option value="all">全部</a-select-option>
              <a-select-option value="scene">场景 QA</a-select-option>
              <a-select-option value="industry">行业 QA</a-select-option>
              <a-select-option value="common">通用 QA</a-select-option>
            </a-select>
            <a-input
              v-model:value="searchKeyword"
              placeholder="请输入问题关键词搜索"
              style="width: 280px"
              @press-enter="handleSearch"
            >
              <template #prefix>
                <search-outlined />
              </template>
            </a-input>
            <a-button type="primary" @click="handleSearch">搜索</a-button>
            <a-button @click="handleReset">重置</a-button>
          </a-space>
        </div>
        <div class="toolbar-right">
          <a-space>
            <a-button type="primary" @click="handleCreateQa">
              <plus-outlined />
              新建场景 QA
            </a-button>
            <a-dropdown trigger="click">
              <a-button @click="handleReferenceQa">
                <link-outlined />
                引用通用/行业 QA
              </a-button>
            </a-dropdown>
            <a-button @click="handleExceptionCheck">
              <warning-outlined />
              异常检测
            </a-button>
          </a-space>
        </div>
      </div>

          <!-- QA 卡片列表 -->
          <div class="qa-list">
            <div
              v-for="qa in qaList"
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
                <div class="header-right">
                  <a-button type="link" size="small" @click="handleAddReply(qa)">
                    <plus-outlined />
                    新增回复
                  </a-button>
                </div>
              </div>

              <!-- 回复列表表格 -->
              <div class="reply-table-wrapper">
                <a-table
                  :columns="replyColumns"
                  :data-source="qa.replies"
                  :pagination="false"
                  row-key="id"
                  size="small"
                  :scroll="{ x: 1000 }"
                >
                  <template #bodyCell="{ column, record, index }">
                    <template v-if="column.key === 'index'">
                      <span>{{ index + 1 }}</span>
                    </template>
                    <template v-if="column.key === 'replyText'">
                      <span class="reply-text">{{ record.replyText }}</span>
                    </template>
                    <template v-if="column.key === 'scene'">
                      <span class="scene-text">{{ record.scene }}</span>
                    </template>
                    <template v-if="column.key === 'action'">
                      <a-space>
                        <a class="action-link" @click="handleEditReply(record)">编辑</a>
                        <a-popconfirm
                          title="确定删除该回复？"
                          ok-text="确定"
                          cancel-text="取消"
                          @confirm="handleDeleteReply(record, qa)"
                        >
                          <a class="action-link delete-link">删除</a>
                        </a-popconfirm>
                      </a-space>
                    </template>
                  </template>
                </a-table>
              </div>
            </div>

            <!-- 空状态 -->
            <a-empty v-if="qaList.length === 0" description="暂无 QA 数据" />
          </div>

          <!-- 分页 -->
          <div class="pagination-section">
            <a-pagination
              v-model:current="currentPage"
              v-model:page-size="pageSize"
              :total="total"
              show-size-changer
              show-quick-jumper
              :show-total="(total: number) => `共 ${total} 条`"
              :page-size-options="['10', '20', '50']"
              @change="handlePageChange"
              @show-size-change="handlePageSizeChange"
            />
          </div>
      </div>
    </div>

    <!-- 流程兜底设置内容区域 -->
    <div v-else-if="activeTabKey === 'fallback'" class="fallback-content">
      <div class="fallback-form-wrapper">
        <a-form
          ref="fallbackFormRef"
          :model="fallbackForm"
          :rules="fallbackRules"
          layout="vertical"
        >
          <!-- 静音超时设置 -->
          <div class="form-section">
            <div class="section-title">
              <div class="title-bar"></div>
              <span>静音超时设置</span>
            </div>
            <div class="section-content">
              <a-row :gutter="[24, 24]">
                <a-col :span="16">
                  <a-form-item label="静音超时时长" name="silenceTimeout">
                    <a-input-number
                      v-model:value="fallbackForm.silenceTimeout"
                      style="width: 100%"
                      :min="8000"
                      :step="1000"
                    />
                    <template #addonAfter>毫秒</template>
                  </a-form-item>
                  <div class="form-tip">静音超时时长最短不低于 8000 毫秒，1000 毫秒=1 秒。</div>
                </a-col>
              </a-row>
              <a-form-item label="静音超时回复" name="silenceReplies" :validate-status="silenceRepliesStatus" :help="silenceRepliesHelp">
                <div class="reply-input-group">
                  <div
                    v-for="(_reply, index) in fallbackForm.silenceReplies"
                    :key="index"
                    class="reply-input-item"
                  >
                    <a-textarea
                      v-model:value="fallbackForm.silenceReplies[index]"
                      :rows="2"
                      placeholder="请输入回复内容"
                    />
                    <div class="reply-actions">
                      <a-button type="text" size="small" @click="handleMoveUpSilenceReply(index)" :disabled="index === 0">
                        <up-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleMoveDownSilenceReply(index)" :disabled="index === fallbackForm.silenceReplies.length - 1">
                        <down-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleDeleteSilenceReply(index)" :disabled="fallbackForm.silenceReplies.length === 1">
                        <delete-outlined />
                      </a-button>
                    </div>
                  </div>
                  <a class="add-reply-link" @click="handleAddSilenceReply">
                    <plus-outlined />
                    新增超时回复
                  </a>
                </div>
              </a-form-item>
            </div>
          </div>

          <!-- 语义为空设置 -->
          <div class="form-section">
            <div class="section-title">
              <div class="title-bar"></div>
              <span>语义为空设置</span>
            </div>
            <div class="section-content">
              <a-form-item label="语义为空回复" name="emptySemanticsReplies" :validate-status="emptySemanticsRepliesStatus" :help="emptySemanticsRepliesHelp">
                <div class="reply-input-group">
                  <div
                    v-for="(_reply, index) in fallbackForm.emptySemanticsReplies"
                    :key="index"
                    class="reply-input-item"
                  >
                    <a-textarea
                      v-model:value="fallbackForm.emptySemanticsReplies[index]"
                      :rows="2"
                      placeholder="请输入回复内容"
                    />
                    <div class="reply-actions">
                      <a-button type="text" size="small" @click="handleMoveUpEmptySemanticsReply(index)" :disabled="index === 0">
                        <up-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleMoveDownEmptySemanticsReply(index)" :disabled="index === fallbackForm.emptySemanticsReplies.length - 1">
                        <down-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleDeleteEmptySemanticsReply(index)" :disabled="fallbackForm.emptySemanticsReplies.length === 1">
                        <delete-outlined />
                      </a-button>
                    </div>
                  </div>
                  <a class="add-reply-link" @click="handleAddEmptySemanticsReply">
                    <plus-outlined />
                    新增语义为空回复
                  </a>
                </div>
              </a-form-item>
            </div>
          </div>

          <!-- 重复策略设置 -->
          <div class="form-section">
            <div class="section-title">
              <div class="title-bar"></div>
              <span>重复策略设置</span>
            </div>
            <div class="section-content">
              <a-row :gutter="[24, 24]">
                <a-col :span="16">
                  <a-form-item label="同一意图重复命中" name="sameIntentRepeat">
                    <a-space>
                      <a-select v-model:value="fallbackForm.sameIntentRepeatMode" style="width: 120px">
                        <a-select-option value="continuous">连续触发</a-select-option>
                        <a-select-option value="cumulative">累计触发</a-select-option>
                      </a-select>
                      <a-input-number v-model:value="fallbackForm.sameIntentRepeatCount" :min="1" :max="10" style="width: 100px" />
                      <span>则跳转到当前流程的下一流程</span>
                    </a-space>
                  </a-form-item>
                </a-col>
              </a-row>
              <a-row :gutter="[24, 24]">
                <a-col :span="16">
                  <a-form-item label="同一流程重复次数" name="sameProcessRepeat">
                    <a-space>
                      <a-select v-model:value="fallbackForm.sameProcessRepeatMode" style="width: 120px">
                        <a-select-option value="continuous">连续触发</a-select-option>
                        <a-select-option value="cumulative">累计触发</a-select-option>
                      </a-select>
                      <a-input-number v-model:value="fallbackForm.sameProcessRepeatCount" :min="1" :max="10" style="width: 100px" />
                      <span>则跳转到当前流程的下一流程</span>
                    </a-space>
                  </a-form-item>
                </a-col>
              </a-row>
            </div>
          </div>

          <!-- 强制挂断设置 -->
          <div class="form-section">
            <div class="section-title">
              <div class="title-bar"></div>
              <span>强制挂断设置</span>
            </div>
            <div class="section-content">
              <a-row :gutter="[24, 24]">
                <a-col :span="16">
                  <a-form-item label="通话超过总时长挂断" name="callTimeout">
                    <a-space>
                      <span>通话时长</span>
                      <a-input-number v-model:value="fallbackForm.callTimeout" :min="60" :max="3600" style="width: 150px" />
                      <span>秒，强制挂断</span>
                    </a-space>
                  </a-form-item>
                </a-col>
              </a-row>
              <a-form-item label="强制挂断回复">
                <div class="reply-input-group">
                  <div
                    v-for="(_reply, index) in fallbackForm.hangupReplies"
                    :key="index"
                    class="reply-input-item"
                  >
                    <a-textarea
                      v-model:value="fallbackForm.hangupReplies[index]"
                      :rows="2"
                      placeholder="请输入回复内容"
                    />
                    <div class="reply-actions">
                      <a-button type="text" size="small" @click="handleMoveUpHangupReply(index)" :disabled="index === 0">
                        <up-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleMoveDownHangupReply(index)" :disabled="index === fallbackForm.hangupReplies.length - 1">
                        <down-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleDeleteHangupReply(index)" :disabled="fallbackForm.hangupReplies.length === 1">
                        <delete-outlined />
                      </a-button>
                    </div>
                  </div>
                  <a class="add-reply-link" @click="handleAddHangupReply">
                    <plus-outlined />
                    新增挂断回复
                  </a>
                </div>
              </a-form-item>
            </div>
          </div>

          <!-- 按键行为设置 -->
          <div class="form-section">
            <div class="section-title">
              <div class="title-bar"></div>
              <span>按键行为设置</span>
            </div>
            <div class="section-content">
              <a-row :gutter="[24, 24]">
                <a-col :span="16">
                  <a-form-item label="按键输入等待时长" name="keyInputTimeout">
                    <a-space>
                      <span>等待时长超过</span>
                      <a-input-number v-model:value="fallbackForm.keyInputTimeout" :min="5" :max="60" style="width: 100px" />
                      <span>秒，重拨上一节点的回复话术</span>
                    </a-space>
                  </a-form-item>
                </a-col>
              </a-row>
              <a-form-item label="按键错误回复">
                <div class="reply-input-group">
                  <div
                    v-for="(_reply, index) in fallbackForm.keyErrorReplies"
                    :key="index"
                    class="reply-input-item"
                  >
                    <a-textarea
                      v-model:value="fallbackForm.keyErrorReplies[index]"
                      :rows="2"
                      placeholder="请输入回复内容"
                    />
                    <div class="reply-actions">
                      <a-button type="text" size="small" @click="handleMoveUpKeyErrorReply(index)" :disabled="index === 0">
                        <up-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleMoveDownKeyErrorReply(index)" :disabled="index === fallbackForm.keyErrorReplies.length - 1">
                        <down-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleDeleteKeyErrorReply(index)" :disabled="fallbackForm.keyErrorReplies.length === 1">
                        <delete-outlined />
                      </a-button>
                    </div>
                  </div>
                  <a v-if="fallbackForm.keyErrorReplies.length === 0" class="add-reply-link" @click="handleAddKeyErrorReply">
                    <plus-outlined />
                    新增按键错误回复
                  </a>
                  <a v-else class="add-reply-link" @click="handleAddKeyErrorReply">
                    <plus-outlined />
                    新增按键错误回复
                  </a>
                </div>
              </a-form-item>
              <a-row :gutter="[24, 24]">
                <a-col :span="16">
                  <a-form-item label="按键错误次数" name="keyErrorCount">
                    <a-space>
                      <a-select v-model:value="fallbackForm.keyErrorRepeatMode" style="width: 120px">
                        <a-select-option value="continuous">连续触发</a-select-option>
                        <a-select-option value="cumulative">累计触发</a-select-option>
                      </a-select>
                      <a-input-number v-model:value="fallbackForm.keyErrorCount" :min="1" :max="10" style="width: 100px" />
                      <span>则触发强制挂断回复并挂断</span>
                    </a-space>
                  </a-form-item>
                </a-col>
              </a-row>
            </div>
          </div>

          <!-- 其他设置 -->
          <div class="form-section">
            <div class="section-title">
              <div class="title-bar"></div>
              <span>其他设置</span>
            </div>
            <div class="section-content">
              <a-form-item label="转人工坐席忙回复">
                <div class="reply-input-group">
                  <div
                    v-for="(_reply, index) in fallbackForm.transferBusyReplies"
                    :key="index"
                    class="reply-input-item"
                  >
                    <a-textarea
                      v-model:value="fallbackForm.transferBusyReplies[index]"
                      :rows="2"
                      placeholder="请输入回复内容"
                    />
                    <div class="reply-actions">
                      <a-button type="text" size="small" @click="handleMoveUpTransferBusyReply(index)" :disabled="index === 0">
                        <up-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleMoveDownTransferBusyReply(index)" :disabled="index === fallbackForm.transferBusyReplies.length - 1">
                        <down-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleDeleteTransferBusyReply(index)" :disabled="fallbackForm.transferBusyReplies.length === 1">
                        <delete-outlined />
                      </a-button>
                    </div>
                  </div>
                  <a v-if="fallbackForm.transferBusyReplies.length === 0" class="add-reply-link" @click="handleAddTransferBusyReply">
                    <plus-outlined />
                    新增转忙回复
                  </a>
                  <a v-else class="add-reply-link" @click="handleAddTransferBusyReply">
                    <plus-outlined />
                    新增转忙回复
                  </a>
                </div>
              </a-form-item>
              <a-row :gutter="[24, 24]">
                <a-col :span="16">
                  <a-form-item label="语音断句时长设置" name="voiceBreakTimeout">
                    <a-input-number
                      v-model:value="fallbackForm.voiceBreakTimeout"
                      style="width: 100%"
                      :min="0"
                      :step="100"
                    />
                    <template #addonAfter>毫秒，后回复</template>
                  </a-form-item>
                </a-col>
              </a-row>
              <a-row :gutter="[24, 24]">
                <a-col :span="16">
                  <a-form-item label="接通后 ASR 识别设置" name="asrInitTimeout">
                    <a-input-number
                      v-model:value="fallbackForm.asrInitTimeout"
                      style="width: 100%"
                      :min="0"
                      :step="100"
                    />
                    <template #addonAfter>毫秒，后回复</template>
                  </a-form-item>
                </a-col>
              </a-row>
            </div>
          </div>
        </a-form>

        <!-- 底部按钮 -->
        <div class="form-footer">
          <a-button @click="handleResetFallback">
            <reload-outlined />
            重置
          </a-button>
          <a-button type="primary" @click="handleSaveFallback">
            <save-outlined />
            保存
          </a-button>
        </div>
      </div>
    </div>

    <!-- 意图库内容区域 -->
    <div v-else-if="activeTabKey === 'intent'" class="intent-content">
      <div class="intent-wrapper">
        <!-- 左侧菜单 -->
        <div class="intent-sidebar">
          <div
            v-for="menu in intentMenus"
            :key="menu.key"
            :class="['menu-item', { active: selectedIntentMenu === menu.key }]"
            @click="handleSelectIntentMenu(menu.key)"
          >
            {{ menu.name }}
          </div>
        </div>

        <!-- 右侧内容区 -->
        <div class="intent-main-content">
          <!-- 顶部操作栏 -->
          <div class="intent-toolbar">
            <div class="toolbar-left">
              <a-space>
                <a-input
                  v-model:value="intentSearchKeyword"
                  placeholder="请输入意图名称"
                  style="width: 240px"
                  @press-enter="handleIntentSearch"
                >
                  <template #prefix>
                    <search-outlined />
                  </template>
                </a-input>
                <a-select
                  v-model:value="intentTypeFilter"
                  placeholder="请选择意图类型"
                  style="width: 200px"
                  allow-clear
                >
                  <a-select-option value="肯定">肯定</a-select-option>
                  <a-select-option value="否定">否定</a-select-option>
                  <a-select-option value="中性">中性</a-select-option>
                  <a-select-option value="重复">重复</a-select-option>
                </a-select>
                <a-button type="primary" @click="handleIntentSearch">搜索</a-button>
                <a-button @click="handleIntentReset">重置</a-button>
              </a-space>
            </div>
            <div class="toolbar-right">
              <a-space>
                <a-button type="primary" ghost @click="handleCreateIntent">
                  新建场景意图
                </a-button>
                <a-button type="primary" ghost @click="handleReferenceIntent">
                  引用通用/行业意图
                </a-button>
              </a-space>
            </div>
          </div>

          <!-- 数据表格 -->
          <div class="intent-table-wrapper">
            <a-table
              :columns="intentColumns"
              :data-source="intentList"
              :pagination="intentPagination"
              row-key="id"
              size="middle"
              @change="handleIntentTableChange"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'action'">
                  <a-space>
                    <a class="action-link" @click="handleCorpusManage(record)">语料管理</a>
                    <a class="action-link" @click="handleEditIntent(record)">编辑</a>
                    <a-popconfirm
                      title="确定删除该意图？"
                      ok-text="确定"
                      cancel-text="取消"
                      @confirm="handleDeleteIntent(record)"
                    >
                      <a class="action-link delete-link">删除</a>
                    </a-popconfirm>
                  </a-space>
                </template>
              </template>
            </a-table>
          </div>
        </div>
      </div>
    </div>

    <!-- 用户分类内容区域 -->
    <div v-else-if="activeTabKey === 'user-classify'" class="user-classify-content">
      <div class="user-classify-wrapper">
        <!-- 左侧分类列表 -->
        <div class="classify-sidebar">
          <div class="sidebar-title">用户分类</div>
          <div
            v-for="category in userCategories"
            :key="category.id"
            :class="['category-item', { active: selectedCategoryId === category.id }]"
            @click="handleSelectCategory(category.id)"
          >
            <span class="category-name">{{ category.name }}</span>
            <a-button type="text" size="small" @click.stop="handleEditCategory(category)">
              <edit-outlined />
            </a-button>
          </div>
          <div class="add-category-btn" @click="handleAddCategory">
            <plus-outlined />
            添加分类
          </div>
        </div>

        <!-- 右侧规则配置区 -->
        <div class="classify-main-content">
          <!-- 顶部默认规则提示 -->
          <div class="default-rule-alert">
            <exclamation-circle-outlined style="margin-right: 8px; color: #faad14;" />
            默认规则：通话意图"反向>=1"、"静音=全程"、"否定=全程"，标记客户为无意向；该规则优先级最高
          </div>

          <!-- 规则列表区域 -->
          <div class="rule-list-container">
            <a-empty v-if="currentCategoryRules.length === 0" description="暂无数据" />
            <div v-else class="rule-list">
              <div
                v-for="(rule, index) in currentCategoryRules"
                :key="rule.id"
                class="rule-item"
              >
                <div class="rule-expression">
                  <span class="rule-index">{{ index + 1 }}.</span>
                  <span class="expression-text">{{ rule.expression }}</span>
                </div>
                <div class="rule-actions">
                  <a-button type="link" size="small" @click="handleEditRule(rule)">
                    <edit-outlined />
                    编辑
                  </a-button>
                  <a-popconfirm
                    title="确定删除该规则？"
                    ok-text="确定"
                    cancel-text="取消"
                    @confirm="handleDeleteRule(rule)"
                  >
                    <a-button type="link" size="small" danger>
                      <delete-outlined />
                      删除
                    </a-button>
                  </a-popconfirm>
                </div>
              </div>
            </div>
          </div>

          <!-- 新增表达式按钮 -->
          <div class="add-rule-btn-wrapper">
            <a-button @click="handleAddRule">
              <plus-outlined />
              新增表达式
            </a-button>
          </div>
        </div>
      </div>

      <!-- 顶部保存按钮 -->
      <div class="save-btn-wrapper">
        <a-button type="primary" @click="handleSaveClassify">
          <save-outlined />
          保存
        </a-button>
      </div>
    </div>

    <!-- 主流程设置内容区域 -->
    <div v-else-if="activeTabKey === 'process'" class="process-content">
      <div class="process-wrapper">
        <!-- 左侧节点工具箱 -->
        <div class="process-sidebar">
          <div class="sidebar-title">节点工具箱</div>
          <div class="node-toolbox">
            <div
              v-for="nodeType in nodeTypes"
              :key="nodeType.type"
              class="toolbox-node"
              :class="['node-type-' + nodeType.type]"
              draggable="true"
              @dragstart="handleNodeDragStart($event, nodeType)"
            >
              <component :is="nodeType.icon" />
              <span>{{ nodeType.label }}</span>
            </div>
          </div>
          <div class="sidebar-tip">
            <info-circle-outlined />
            <span>拖拽节点到画布区域添加节点</span>
          </div>
        </div>

        <!-- 右侧流程图画布 -->
        <div class="process-canvas-wrapper">
          <!-- 画布工具栏 -->
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
            <div class="toolbar-right">
              <a-space>
                <a-button size="small" @click="handleAutoLayout">
                  <layout-outlined />
                  自动布局
                </a-button>
                <a-button type="primary" size="small" @click="handleSaveProcess">
                  <save-outlined />
                  保存流程
                </a-button>
              </a-space>
            </div>
          </div>

          <!-- 画布区域 -->
          <div
            ref="canvasRef"
            class="process-canvas"
            @dragover="handleCanvasDragOver"
            @drop="handleCanvasDrop"
            @click="handleCanvasClick"
          >
            <div class="canvas-content" :style="{ transform: `scale(${canvasZoom / 100})`, transformOrigin: 'top left' }">
              <!-- SVG 连接线层 -->
              <svg class="connection-layer" :style="{ width: canvasSize.width + 'px', height: canvasSize.height + 'px' }">
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
                  <marker
                    id="arrowhead-selected"
                    markerWidth="10"
                    markerHeight="7"
                    refX="9"
                    refY="3.5"
                    orient="auto"
                  >
                    <polygon points="0 0, 10 3.5, 0 7" fill="#1890ff" />
                  </marker>
                </defs>
                <g v-for="connection in connections" :key="connection.id">
                  <!-- 连接线（粗线用于点击检测） -->
                  <path
                    :d="getConnectionPath(connection)"
                    class="connection-hit"
                    :class="{ 'connection-selected': selectedConnection?.id === connection.id }"
                    @click.stop="handleConnectionClick($event, connection)"
                    @dblclick.stop="handleConnectionEdit(connection)"
                  />
                  <!-- 连接线（细线用于显示） -->
                  <path
                    :d="getConnectionPath(connection)"
                    class="connection-line"
                    :class="{ 'connection-selected': selectedConnection?.id === connection.id }"
                    @click.stop="handleConnectionClick($event, connection)"
                    @dblclick.stop="handleConnectionEdit(connection)"
                  />
                  <!-- 删除按钮 -->
                  <g
                    v-if="selectedConnection?.id === connection.id"
                    @click.stop="handleDeleteConnection(connection)"
                    class="connection-delete"
                  >
                    <circle :cx="getConnectionMidpoint(connection).x" :cy="getConnectionMidpoint(connection).y - 12" r="10" fill="#ff4d4f" />
                    <text
                      :x="getConnectionMidpoint(connection).x"
                      :y="getConnectionMidpoint(connection).y - 8"
                      fill="#fff"
                      font-size="12"
                      text-anchor="middle"
                    >×</text>
                  </g>
                </g>
              </svg>

              <!-- 节点层 -->
              <div
                v-for="node in processNodes"
                :key="node.id"
                class="process-node"
                :class="['node-type-' + node.type, { 'node-selected': selectedNode?.id === node.id }]"
                :style="{ left: node.x + 'px', top: node.y + 'px' }"
                @click.stop="handleNodeClick($event, node)"
                @mousedown="handleNodeMouseDown($event, node)"
                @dblclick.stop="openNodeEditModal(node)"
              >
                <!-- 节点头部 -->
                <div class="node-header">
                  <component :is="getNodeIcon(node.type)" />
                  <span class="node-title">{{ node.name }}</span>
                  <div class="node-actions">
                    <a-button
                      type="text"
                      size="small"
                      class="node-action-btn"
                      @click.stop="openNodeEditModal(node)"
                    >
                      <edit-outlined />
                    </a-button>
                    <a-button
                      v-if="node.type !== 'start' && node.type !== 'end'"
                      type="text"
                      size="small"
                      class="node-action-btn"
                      @click.stop="handleDeleteNode(node)"
                    >
                      <close-outlined />
                    </a-button>
                  </div>
                </div>
                <!-- 节点内容 -->
                <div class="node-content">
                  <template v-if="node.type === 'start'">
                    <span class="node-desc">流程起点</span>
                  </template>
                  <template v-else-if="node.type === 'script'">
                    <span class="node-desc">{{ node.content?.text || '暂无话术内容' }}</span>
                  </template>
                  <template v-else-if="node.type === 'condition'">
                    <span class="node-desc">{{ node.content?.condition || '暂无条件' }}</span>
                    <div class="condition-branches">
                      <div class="branch-item branch-yes">
                        <check-circle-outlined />
                        <span>是</span>
                      </div>
                      <div class="branch-item branch-no">
                        <close-circle-outlined />
                        <span>否</span>
                      </div>
                    </div>
                  </template>
                  <template v-else-if="node.type === 'end'">
                    <span class="node-desc">流程终点</span>
                  </template>
                </div>
                <!-- 连接点（输出） -->
                <div
                  v-if="node.type !== 'end'"
                  class="node-connector node-connector-out"
                  :style="getConnectorPosition(node, 'out')"
                  @mousedown.stop="handleConnectorMouseDown($event, node)"
                ></div>
                <!-- 连接点（输入） -->
                <div
                  v-if="node.type !== 'start'"
                  class="node-connector node-connector-in"
                  :style="getConnectorPosition(node, 'in')"
                ></div>
              </div>

              <!-- 拖拽连线 -->
              <svg v-if="isDrawingConnection" class="temp-connection-layer" :style="{ width: canvasSize.width + 'px', height: canvasSize.height + 'px' }">
                <path
                  :d="getTempConnectionPath()"
                  class="temp-connection-line"
                  fill="none"
                />
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 其他标签页内容占位 -->
    <div v-else class="other-tab-placeholder">
      <a-empty :description="`这里是${getTabName(activeTabKey)}内容`" />
    </div>

    <!-- 节点编辑弹窗 -->
    <a-modal
      v-model:open="nodeEditModalVisible"
      :title="editingNode?.type === 'start' ? '开始节点设置' : 
                editingNode?.type === 'script' ? '话术节点设置' :
                editingNode?.type === 'condition' ? '条件节点设置' : '结束节点设置'"
      width="600px"
      :footer="null"
      @cancel="handleNodeEditCancel"
    >
      <a-form
        ref="nodeEditFormRef"
        :model="nodeEditForm"
        :rules="nodeEditRules"
        layout="vertical"
      >
        <a-form-item label="节点名称" name="name">
          <a-input v-model:value="nodeEditForm.name" placeholder="请输入节点名称" />
        </a-form-item>
        
        <a-form-item v-if="editingNode?.type === 'script'" label="话术内容" name="text">
          <a-textarea
            v-model:value="nodeEditForm.text"
            placeholder="请输入话术回复内容"
            :rows="6"
          />
          <a class="ai-generate-btn" style="margin-top: 8px; display: inline-flex;" @click="handleAiGenerateNodeContent">
            <thunderbolt-outlined />
            AI 生成
          </a>
        </a-form-item>
        
        <a-form-item v-if="editingNode?.type === 'condition'" label="条件表达式" name="condition">
          <a-textarea
            v-model:value="nodeEditForm.condition"
            placeholder="例如：intent = '肯定' 或 score > 0.8"
            :rows="3"
          />
          <div class="form-tip" style="margin-top: 8px;">
            支持的条件：intent（意图）、score（置信度）、keyword（关键词）等
          </div>
        </a-form-item>
        
        <a-form-item v-if="editingNode?.type === 'condition'" label="分支设置">
          <a-space direction="vertical" style="width: 100%">
            <div class="branch-setting">
              <a-input
                v-model:value="nodeEditForm.yesNextNode"
                placeholder="选择'是'分支的下一个节点"
                disabled
              >
                <template #addonAfter>
                  <search-outlined style="cursor: pointer" />
                </template>
              </a-input>
              <span class="branch-label">→ 是分支</span>
            </div>
            <div class="branch-setting">
              <a-input
                v-model:value="nodeEditForm.noNextNode"
                placeholder="选择'否'分支的下一个节点"
                disabled
              >
                <template #addonAfter>
                  <search-outlined style="cursor: pointer" />
                </template>
              </a-input>
              <span class="branch-label">→ 否分支</span>
            </div>
          </a-space>
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleNodeEditCancel">取消</a-button>
        <a-button type="primary" @click="handleNodeEditSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 连接线编辑弹窗 -->
    <a-modal
      v-model:open="connectionEditModalVisible"
      title="连接线设置"
      width="500px"
      :footer="null"
      @cancel="handleConnectionEditCancel"
    >
      <a-form
        ref="connectionEditFormRef"
        :model="connectionEditForm"
        layout="vertical"
      >
        <a-form-item label="条件表达式">
          <a-textarea
            v-model:value="connectionEditForm.condition"
            placeholder="例如：intent = '肯定'"
            :rows="4"
          />
          <div class="form-tip" style="margin-top: 8px;">
            当满足此条件时，流程将沿着此连接线继续
          </div>
        </a-form-item>
        <a-form-item label="连接线说明">
          <a-input
            v-model:value="connectionEditForm.label"
            placeholder="例如：用户确认、条件满足等"
          />
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleConnectionEditCancel">取消</a-button>
        <a-button type="primary" @click="handleConnectionEditSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 新建 QA 弹窗 -->
    <a-modal
      v-model:open="createQaModalVisible"
      title="新建场景 QA"
      width="700px"
      :footer="null"
      @cancel="handleCreateQaCancel"
    >
      <a-form
        ref="createQaFormRef"
        :model="createQaForm"
        :rules="createQaRules"
        layout="vertical"
      >
        <a-form-item label="QA 名称" name="question">
          <a-input v-model:value="createQaForm.question" placeholder="请输入 QA 名称" />
        </a-form-item>
        <a-divider style="margin: 16px 0" />
        <div style="margin-bottom: 12px; font-weight: 500;">
          QA 回复
          <span style="color: #ff4d4f; font-weight: normal; font-size: 12px; margin-left: 8px;">（至少添加一条回复）</span>
          <a-button type="link" size="small" @click="handleAddNewReply" style="padding-left: 8px;">
            <plus-outlined />
            新增回复
          </a-button>
        </div>
        <div class="reply-input-list">
          <div
            v-for="(reply, index) in createQaForm.replies"
            :key="index"
            class="reply-input-item"
          >
            <div class="reply-input-content">
              <a-textarea
                v-model:value="reply.replyText"
                placeholder="请输入回复文本"
                :rows="3"
              />
              <div class="reply-actions">
                <a class="ai-generate-btn" @click="handleAiGenerateReply(index)">
                  <sparkles-outlined />
                  AI 生成
                </a>
                <a class="delete-reply-btn" @click="handleDeleteReplyInput(index)">
                  <delete-outlined />
                  删除
                </a>
              </div>
            </div>
          </div>
          <a-empty v-if="createQaForm.replies.length === 0" description="请添加回复内容" style="padding: 20px 0;" />
        </div>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleCreateQaCancel">取消</a-button>
        <a-button type="primary" @click="handleCreateQaSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 编辑回复弹窗 -->
    <a-modal
      v-model:open="editReplyModalVisible"
      title="编辑回复"
      width="600px"
      :footer="null"
      @cancel="handleEditReplyCancel"
    >
      <a-form
        ref="editReplyFormRef"
        :model="editReplyForm"
        :rules="editReplyRules"
        layout="vertical"
      >
        <a-form-item label="回复文本" name="replyText">
          <div class="textarea-with-action">
            <a-textarea
              v-model:value="editReplyForm.replyText"
              placeholder="请输入回复文本"
              :rows="6"
            />
            <a class="ai-generate-btn" @click="handleAiGenerateEditReply">
              <sparkles-outlined />
              AI 生成
            </a>
          </div>
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleEditReplyCancel">取消</a-button>
        <a-button type="primary" @click="handleEditReplySubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 新增回复弹窗 -->
    <a-modal
      v-model:open="addReplyModalVisible"
      title="新增回复"
      width="600px"
      :footer="null"
      @cancel="handleAddReplyCancel"
    >
      <a-form
        ref="addReplyFormRef"
        :model="addReplyForm"
        :rules="addReplyRules"
        layout="vertical"
      >
        <a-form-item label="回复文本" name="replyText">
          <div class="textarea-with-action">
            <a-textarea
              v-model:value="addReplyForm.replyText"
              placeholder="请输入回复文本"
              :rows="6"
            />
            <a class="ai-generate-btn" @click="handleAiGenerateAddReply">
              <sparkles-outlined />
              AI 生成
            </a>
          </div>
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleAddReplyCancel">取消</a-button>
        <a-button type="primary" @click="handleAddReplySubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 引用 QA 弹窗 -->
    <a-modal
      v-model:open="referenceQaModalVisible"
      title="引用 QA"
      width="900px"
      :footer="null"
      @cancel="handleReferenceQaCancel"
    >
      <div class="reference-qa-container">
        <!-- 右侧内容区 -->
        <div class="reference-right-content">
          <!-- 搜索区 -->
          <div class="reference-search-bar">
            <a-space>
              <a-select
                v-model:value="referenceQaType"
                placeholder="QA 类型"
                style="width: 150px"
                allow-clear
              >
                <a-select-option value="all">全部</a-select-option>
                <a-select-option value="industry">行业 QA</a-select-option>
                <a-select-option value="common">通用 QA</a-select-option>
              </a-select>
              <a-input
                v-model:value="referenceSearchKeyword"
                placeholder="请输入"
                style="width: 280px"
                @press-enter="handleReferenceSearch"
              >
                <template #prefix>
                  <search-outlined />
                </template>
              </a-input>
              <a-button type="primary" @click="handleReferenceSearch">搜索</a-button>
              <a-button @click="handleReferenceSearchReset">重置</a-button>
            </a-space>
          </div>

          <!-- 表格 -->
          <div class="reference-table-wrapper">
            <a-table
              :columns="referenceColumns"
              :data-source="referenceQaList"
              :pagination="false"
              row-key="id"
              size="small"
              :row-selection="{ selectedRowKeys: selectedReferenceRowKeys, onChange: onReferenceSelectionChange }"
              :scroll="{ y: 400 }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'qaName'">
                  <span>{{ record.qaName }}</span>
                </template>
              </template>
            </a-table>
          </div>

          <!-- 分页 -->
          <div class="reference-pagination">
            <span class="total-text">共{{ referenceTotal }}记录</span>
            <a-checkbox v-model:checked="referenceSelectAll" @change="onReferenceSelectAll">全选</a-checkbox>
            <a-pagination
              v-model:current="referenceCurrent"
              v-model:page-size="referencePageSize"
              :total="referenceTotal"
              show-size-changer
              show-quick-jumper
              :page-size-options="['10', '20', '50']"
              :locale="{
                items_per_page: '条/页',
                jump_to: '跳转至',
                page: '页',
              }"
              @change="handleReferencePageChange"
              @show-size-change="handleReferencePageSizeChange"
            />
          </div>
        </div>
      </div>

      <!-- 底部按钮 -->
      <div class="modal-footer">
        <span class="selected-count">已选择{{ selectedReferenceRowKeys.length }}条 QA</span>
        <a-button @click="handleReferenceQaCancel">关闭</a-button>
        <a-button type="primary" @click="handleReferenceQaImport">导入</a-button>
      </div>
    </a-modal>

  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import type { FormInstance, Rule } from 'ant-design-vue/es/form';
import { message } from 'ant-design-vue';
import {
  SearchOutlined,
  PlusOutlined,
  LinkOutlined,
  WarningOutlined,
  DeleteOutlined,
  EditOutlined,
  SaveOutlined,
  ExclamationCircleOutlined,
  ReloadOutlined,
  UpOutlined,
  DownOutlined,
  CloseOutlined,
  InfoCircleOutlined,
  ZoomInOutlined,
  ZoomOutOutlined,
  FullscreenOutlined,
  LayoutOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  PlayCircleOutlined,
  MessageOutlined,
  BranchesOutlined,
  StopOutlined,
  ThunderboltOutlined,
} from '@ant-design/icons-vue';

// ==================== 接口定义 ====================

interface ReplyItem {
  id: number;
  replyText: string;
  scene: string;
}

interface QaItem {
  id: number;
  question: string;
  qaType: '场景 QA' | '行业 QA' | '通用 QA';
  followProcess: string;
  intentType: '正向' | '负向';
  description: string;
  replies: ReplyItem[];
}

// ==================== 流程图相关接口 ====================

// 节点类型
type NodeType = 'start' | 'script' | 'condition' | 'end';

// 流程节点
interface ProcessNode {
  id: number;
  type: NodeType;
  name: string;
  x: number;
  y: number;
  content?: {
    text?: string;        // 话术节点的内容
    condition?: string;   // 条件节点的条件表达式
    yesNextNode?: number; // 是分支的下一个节点 ID
    noNextNode?: number;  // 否分支的下一个节点 ID
  };
}

// 连接线
interface Connection {
  id: number;
  sourceNodeId: number;
  targetNodeId: number;
  condition?: string; // 连接线的条件表达式
  label?: string;     // 连接线标签
}

// 节点类型定义
interface NodeTypeDef {
  type: NodeType;
  label: string;
  icon: any;
}

// ==================== 响应式数据 ====================

// 标签页
const activeTabKey = ref('basic');

// 基本信息相关（模拟数据）
const basicForm = reactive({
  templateName: '信用卡激活模板',
  templateType: ['信用卡', '信用卡激活'] as string[],
  tags: ['信用卡', '激活流程', '高频场景'] as string[],
  followType: 'sms+manual',
  description: '适用于信用卡新卡激活场景，包含完整的激活流程指引和常见问题解答',
  targetCustomer: '持有未激活信用卡的新客户，包括个人客户和企业客户',
  applicableActivity: '2026 年信用卡开卡礼活动、首刷礼活动、新户专享理财活动',
  financialProduct: '信用卡产品：标准金卡、白金卡、钻石卡；关联产品：消费分期、账单分期、现金分期',
});

// 计算属性：模板类型文本
const templateTypeText = computed(() => {
  if (!basicForm.templateType || basicForm.templateType.length === 0) {
    return '暂无';
  }
  return basicForm.templateType.join(' / ');
});

// 计算属性：跟进方式文本
const followTypeText = computed(() => {
  const typeMap: Record<string, string> = {
    'all': '全部',
    'sms': '短信跟进',
    'manual': '人工跟进',
    'sms+manual': '短信 + 人工跟进',
  };
  return typeMap[basicForm.followType] || '暂无';
});

// 筛选相关
const qaTypeFilter = ref('all');

// 搜索相关
const searchKeyword = ref('');

// 分页相关
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(12);

// QA 列表数据（模拟数据）
const qaList = ref<QaItem[]>([
  {
    id: 1001,
    question: '如何办理信用卡激活？',
    qaType: '场景 QA',
    followProcess: '信用卡激活流程',
    intentType: '正向',
    description: '用户咨询信用卡激活的具体操作步骤',
    replies: [
      {
        id: 1,
        replyText: '您好，办理信用卡激活非常简单。您可以通过以下几种方式进行激活：1. 拨打信用卡背面的客服热线，按照语音提示操作；2. 登录手机银行 APP，在信用卡页面点击激活；3. 前往就近的银行网点，由工作人员协助激活。请问您想选择哪种方式呢？',
        scene: '当前模板新增',
      },
      {
        id: 2,
        replyText: '激活信用卡需要您提供以下信息：身份证号码、信用卡卡号、预留手机号码。请确保您提供的信息与办卡时填写的信息一致。',
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
    description: '用户账户被冻结后的处理流程',
    replies: [
      {
        id: 3,
        replyText: '您好，账户被冻结可能是由于以下原因：1. 多次输入错误密码；2. 账户存在异常交易；3. 长时间未使用。请您先不要着急，我们可以帮您核实具体原因并指导您进行解冻操作。',
        scene: '账户回访',
      },
    ],
  },
  {
    id: 1003,
    question: '存款到期后如何续存？',
    qaType: '行业 QA',
    followProcess: '存款续存流程',
    intentType: '正向',
    description: '存款到期后的续存操作指引',
    replies: [
      {
        id: 4,
        replyText: '您的存款即将到期，我们提供多种续存方式供您选择：1. 自动转存：到期后自动按原期限和当日挂牌利率转存；2. 手动续存：您可前往网点或通过手机银行选择新的存款产品。建议您提前联系我们，我们可以为您推荐更优惠的续存方案。',
        scene: '存款到期续存',
      },
      {
        id: 5,
        replyText: '目前我行推出的大额存单产品利率较基准上浮 45%，期限灵活，起点金额 20 万元。如果您有续存需求，我可以为您详细介绍。',
        scene: '当前模板新增',
      },
    ],
  },
  {
    id: 1004,
    question: '如何申请个人贷款？',
    qaType: '场景 QA',
    followProcess: '个人贷款申请流程',
    intentType: '正向',
    description: '用户咨询个人信用贷款申请条件和流程',
    replies: [
      {
        id: 6,
        replyText: '您好，申请个人贷款需要满足以下条件：1. 年满 18 周岁，具有完全民事行为能力；2. 有稳定的工作和收入来源；3. 信用记录良好。您可以携带身份证、收入证明等材料前往网点办理，也可以通过手机银行在线申请。',
        scene: '个人信用贷款',
      },
      {
        id: 7,
        replyText: '目前我行个人信用贷款年化利率最低 3.85%，最高可贷 30 万元，期限最长 3 年。审批通过后，资金实时到账，支持随借随还，按日计息。',
        scene: '当前模板新增',
      },
    ],
  },
  {
    id: 1005,
    question: '手机银行如何绑定银行卡？',
    qaType: '通用 QA',
    followProcess: '手机银行绑卡流程',
    intentType: '正向',
    description: '用户咨询手机银行绑定银行卡的操作方法',
    replies: [
      {
        id: 8,
        replyText: '您好，绑定银行卡的步骤如下：1. 登录手机银行 APP；2. 点击"我的"页面；3. 选择"银行卡管理"；4. 点击"添加银行卡"；5. 输入卡号、预留手机号等信息完成验证。整个过程大约需要 2-3 分钟。',
        scene: '手机银行开通',
      },
    ],
  },
  {
    id: 1006,
    question: '如何查询账户余额？',
    qaType: '通用 QA',
    followProcess: '余额查询流程',
    intentType: '正向',
    description: '用户查询账户余额的多种方式',
    replies: [
      {
        id: 9,
        replyText: '您可以通过以下方式查询余额：1. 手机银行：登录后点击"账户管理"即可查看；2. 网上银行：登录个人网银查询；3. 电话银行：拨打客服热线按语音提示操作；4. 网点查询：携带身份证前往就近网点。',
        scene: '当前模板新增',
      },
      {
        id: 10,
        replyText: '建议您开通手机银行余额变动提醒服务，账户资金变动会实时推送短信通知，方便您随时掌握账户动态。',
        scene: '手机银行促活',
      },
    ],
  },
]);

// ==================== 流程图相关数据 ====================

// 节点类型配置
const nodeTypes: NodeTypeDef[] = [
  { type: 'start', label: '开始节点', icon: PlayCircleOutlined },
  { type: 'script', label: '话术节点', icon: MessageOutlined },
  { type: 'condition', label: '条件节点', icon: BranchesOutlined },
  { type: 'end', label: '结束节点', icon: StopOutlined },
];

// 画布引用
const canvasRef = ref<HTMLElement | null>(null);

// 流程节点数据（模拟数据）
const processNodes = ref<ProcessNode[]>([
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
    type: 'condition',
    name: '是否方便',
    x: 300,
    y: 320,
    content: {
      condition: "intent = '肯定'",
      yesNextNode: 4,
      noNextNode: 5,
    },
  },
  {
    id: 4,
    type: 'script',
    name: '介绍产品',
    x: 150,
    y: 450,
    content: {
      text: '太好了！我们银行最近推出了一款高收益的理财产品，年化收益率最高可达 4.5%，您有兴趣了解一下吗？',
    },
  },
  {
    id: 5,
    type: 'script',
    name: '预约回访',
    x: 450,
    y: 450,
    content: {
      text: '不好意思打扰您了，那请问您什么时间方便呢？我们可以稍后再联系您。',
    },
  },
  {
    id: 6,
    type: 'end',
    name: '结束',
    x: 300,
    y: 600,
  },
]);

// 连接线数据（模拟数据）
const connections = ref<Connection[]>([
  { id: 1, sourceNodeId: 1, targetNodeId: 2 },
  { id: 2, sourceNodeId: 2, targetNodeId: 3 },
  { id: 3, sourceNodeId: 3, targetNodeId: 4, condition: '是', label: '是' },
  { id: 4, sourceNodeId: 3, targetNodeId: 5, condition: '否', label: '否' },
  { id: 5, sourceNodeId: 4, targetNodeId: 6 },
  { id: 6, sourceNodeId: 5, targetNodeId: 6 },
]);

// 画布缩放
const canvasZoom = ref(100);

// 画布尺寸
const canvasSize = reactive({
  width: 2000,
  height: 1500,
});

// 选中的节点
const selectedNode = ref<ProcessNode | null>(null);

// 选中的连接线
const selectedConnection = ref<Connection | null>(null);

// 正在编辑的节点
const editingNode = ref<ProcessNode | null>(null);

// 节点编辑表单
const nodeEditModalVisible = ref(false);
const nodeEditFormRef = ref<FormInstance>();
const nodeEditForm = reactive({
  name: '',
  text: '',
  condition: '',
  yesNextNode: '',
  noNextNode: '',
});

const nodeEditRules: Record<string, Rule[]> = {
  name: [{ required: true, message: '请输入节点名称', trigger: 'blur' }],
  text: [{ required: true, message: '请输入话术内容', trigger: 'blur' }],
  condition: [{ required: true, message: '请输入条件表达式', trigger: 'blur' }],
};

// 连接线编辑表单
const connectionEditModalVisible = ref(false);
const connectionEditFormRef = ref<FormInstance>();
const connectionEditForm = reactive({
  condition: '',
  label: '',
});

// 拖拽连线状态
const isDrawingConnection = ref(false);
const drawingSourceNode = ref<ProcessNode | null>(null);
const tempMousePosition = reactive({ x: 0, y: 0 });

// 节点拖拽状态
const isDraggingNode = ref(false);
const draggingNode = ref<ProcessNode | null>(null);
const dragOffset = reactive({ x: 0, y: 0 });

// ==================== 意图库相关数据 ====================

// 意图库接口
interface IntentItem {
  id: number;
  intentName: string;
  intentType: string;
  priority: number;
  updateTime: string;
}

// 左侧菜单配置
const intentMenus = [
  { key: 'all', name: '全部' },
  { key: 'scene', name: '当前场景意图' },
  { key: 'industry', name: '内置行业意图' },
  { key: 'common', name: '内置通用意图' },
];

// 当前选中的菜单
const selectedIntentMenu = ref('all');

// 搜索相关
const intentSearchKeyword = ref('');
const intentTypeFilter = ref('');

// 分页相关
const intentPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 7,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共${total}记录`,
  pageSizeOptions: ['10', '20', '50'],
});

// 意图列表数据（模拟数据）
const intentList = ref<IntentItem[]>([
  { id: 7, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 6, intentName: 'sys.肯定', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 5, intentName: 'sys.确认', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 4, intentName: 'sys.指定业务', intentType: '肯定', priority: 2, updateTime: '2025-12-15 16:52:11' },
  { id: 3, intentName: 'sys.否定', intentType: '否定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 2, intentName: 'sys.中性 - 继续', intentType: '中性', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 1, intentName: 'sys.不太了解', intentType: '中性', priority: 1, updateTime: '2025-12-15 16:52:11' },
]);

// 意图表格列配置
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
    title: '修改时间',
    dataIndex: 'updateTime',
    key: 'updateTime',
    width: 180,
  },
  {
    title: '操作',
    key: 'action',
    width: 200,
    fixed: 'right' as const,
  },
];

// ==================== 流程兜底设置相关数据 ====================

// 流程兜底设置表单数据
const fallbackFormRef = ref<FormInstance>();

const fallbackForm = reactive({
  // 静音超时设置
  silenceTimeout: 10000,
  silenceReplies: ['您好，上海建行温馨提示：您建行卡内有小额定期存款可以转出，请登录手机银行查看。'] as string[],
  // 语义为空设置
  emptySemanticsReplies: ['您好，上海建行温馨提示：您建行卡内有小额定期存款可以转出，请登录手机银行查看。'] as string[],
  // 重复策略设置
  sameIntentRepeatMode: 'continuous',
  sameIntentRepeatCount: 2,
  sameProcessRepeatMode: 'continuous',
  sameProcessRepeatCount: 1,
  // 强制挂断设置
  callTimeout: 300,
  hangupReplies: ['您好，上海建行温馨提示：您建行卡内有小额定期存款可以转出，请登录手机银行查看。'] as string[],
  // 按键行为设置
  keyInputTimeout: 10,
  keyErrorReplies: [] as string[],
  keyErrorRepeatMode: 'continuous',
  keyErrorCount: 3,
  // 其他设置
  transferBusyReplies: [] as string[],
  voiceBreakTimeout: 500,
  asrInitTimeout: 0,
});

// 计算属性：静音超时回复验证状态
const silenceRepliesStatus = computed(() => {
  if (fallbackForm.silenceReplies.length === 0) return 'error';
  if (fallbackForm.silenceReplies.some(r => !r || r.trim() === '')) return 'error';
  return '';
});

// 计算属性：静音超时回复帮助文本
const silenceRepliesHelp = computed(() => {
  if (fallbackForm.silenceReplies.length === 0) return '请至少添加一条回复';
  if (fallbackForm.silenceReplies.some(r => !r || r.trim() === '')) return '请填写所有回复内容';
  return '';
});

// 计算属性：语义为空回复验证状态
const emptySemanticsRepliesStatus = computed(() => {
  if (fallbackForm.emptySemanticsReplies.length === 0) return 'error';
  if (fallbackForm.emptySemanticsReplies.some(r => !r || r.trim() === '')) return 'error';
  return '';
});

// 计算属性：语义为空回复帮助文本
const emptySemanticsRepliesHelp = computed(() => {
  if (fallbackForm.emptySemanticsReplies.length === 0) return '请至少添加一条回复';
  if (fallbackForm.emptySemanticsReplies.some(r => !r || r.trim() === '')) return '请填写所有回复内容';
  return '';
});

// 流程兜底设置表单验证规则
const fallbackRules: Record<string, Rule[]> = {
  silenceTimeout: [{ required: true, message: '请输入静音超时时长', trigger: 'blur' }],
  callTimeout: [{ required: true, message: '请输入通话超时时长', trigger: 'blur' }],
  keyInputTimeout: [{ required: true, message: '请输入按键等待时长', trigger: 'blur' }],
  voiceBreakTimeout: [{ required: true, message: '请输入语音断句时长', trigger: 'blur' }],
  asrInitTimeout: [{ required: true, message: '请输入 ASR 识别设置', trigger: 'blur' }],
};

// ==================== 用户分类相关数据 ====================

// 用户分类接口
interface UserCategory {
  id: number;
  name: string;
  rules: CategoryRule[];
}

interface CategoryRule {
  id: number;
  expression: string;
}

// 用户分类列表
const userCategories = ref<UserCategory[]>([
  {
    id: 1,
    name: '有意向',
    rules: [],
  },
  {
    id: 2,
    name: '可能有意向',
    rules: [],
  },
  {
    id: 3,
    name: '无意向',
    rules: [],
  },
]);

// 当前选中的分类 ID
const selectedCategoryId = ref<number>(1);

// 计算属性：当前分类的规则列表
const currentCategoryRules = computed(() => {
  const category = userCategories.value.find(c => c.id === selectedCategoryId.value);
  return category ? category.rules : [];
});

// 回复表格列配置
const replyColumns = computed(() => [
  {
    title: '序号',
    dataIndex: 'id',
    key: 'index',
    width: 60,
    customRender: ({ index }: { index: number }) => index + 1,
  },
  {
    title: '回复文本',
    dataIndex: 'replyText',
    key: 'replyText',
    width: 600,
    ellipsis: false,
  },
  {
    title: '场景',
    dataIndex: 'scene',
    key: 'scene',
    width: 150,
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    fixed: 'right' as const,
  },
]);

// ==================== 弹窗相关 ====================

// 新建 QA 弹窗
const createQaModalVisible = ref(false);
const createQaFormRef = ref<FormInstance>();
const createQaForm = reactive({
  question: '',
  replies: [] as { replyText: string }[],
});

const createQaRules: Record<string, Rule[]> = {
  question: [{ required: true, message: '请输入 QA 名称', trigger: 'blur' }],
};

// 编辑回复弹窗
const editReplyModalVisible = ref(false);
const editReplyFormRef = ref<FormInstance>();
const editReplyForm = reactive({
  id: 0,
  replyText: '',
  scene: '',
});
const currentEditQa = ref<QaItem | null>(null);

const editReplyRules: Record<string, Rule[]> = {
  replyText: [{ required: true, message: '请输入回复文本', trigger: 'blur' }],
};

// 新增回复弹窗
const addReplyModalVisible = ref(false);
const addReplyFormRef = ref<FormInstance>();
const addReplyForm = reactive({
  replyText: '',
});
const currentAddQa = ref<QaItem | null>(null);

const addReplyRules: Record<string, Rule[]> = {
  replyText: [{ required: true, message: '请输入回复文本', trigger: 'blur' }],
};

// ==================== 方法定义 ====================

// ==================== 流程图相关方法 ====================

// 获取节点图标
const getNodeIcon = (type: NodeType) => {
  const iconMap: Record<NodeType, any> = {
    start: PlayCircleOutlined,
    script: MessageOutlined,
    condition: BranchesOutlined,
    end: StopOutlined,
  };
  return iconMap[type];
};

// 获取连接点位置
const getConnectorPosition = (node: ProcessNode, direction: 'in' | 'out') => {
  const nodeWidth = 200;
  const nodeHeight = node.type === 'condition' ? 120 : 80;
  
  if (direction === 'out') {
    return {
      left: (nodeWidth / 2 - 6) + 'px',
      top: nodeHeight + 'px',
    };
  } else {
    return {
      left: (nodeWidth / 2 - 6) + 'px',
      top: '-6px',
    };
  }
};

// 获取连接线路径（贝塞尔曲线）
const getConnectionPath = (connection: Connection) => {
  const sourceNode = processNodes.value.find(n => n.id === connection.sourceNodeId);
  const targetNode = processNodes.value.find(n => n.id === connection.targetNodeId);
  
  if (!sourceNode || !targetNode) return '';
  
  const nodeWidth = 200;
  const sourceNodeHeight = sourceNode.type === 'condition' ? 120 : 80;
  
  const startX = sourceNode.x + nodeWidth / 2;
  const startY = sourceNode.y + sourceNodeHeight;
  const endX = targetNode.x + nodeWidth / 2;
  const endY = targetNode.y;
  
  // 计算控制点
  const controlY1 = startY + Math.abs(endY - startY) / 2;
  const controlY2 = endY - Math.abs(endY - startY) / 2;
  
  return `M ${startX} ${startY} C ${startX} ${controlY1}, ${endX} ${controlY2}, ${endX} ${endY}`;
};

// 获取连接线中点（用于显示删除按钮）
const getConnectionMidpoint = (connection: Connection) => {
  const sourceNode = processNodes.value.find(n => n.id === connection.sourceNodeId);
  const targetNode = processNodes.value.find(n => n.id === connection.targetNodeId);
  
  if (!sourceNode || !targetNode) return { x: 0, y: 0 };
  
  const nodeWidth = 200;
  const sourceNodeHeight = sourceNode.type === 'condition' ? 120 : 80;
  
  const startX = sourceNode.x + nodeWidth / 2;
  const startY = sourceNode.y + sourceNodeHeight;
  const endX = targetNode.x + nodeWidth / 2;
  const endY = targetNode.y;
  
  return {
    x: (startX + endX) / 2,
    y: (startY + endY) / 2,
  };
};

// 获取临时连接线路径（拖拽连线时）
const getTempConnectionPath = () => {
  if (!drawingSourceNode.value) return '';
  
  const nodeWidth = 200;
  const sourceNodeHeight = drawingSourceNode.value.type === 'condition' ? 120 : 80;
  
  const startX = drawingSourceNode.value.x + nodeWidth / 2;
  const startY = drawingSourceNode.value.y + sourceNodeHeight;
  const endX = tempMousePosition.x;
  const endY = tempMousePosition.y;
  
  const controlY1 = startY + Math.abs(endY - startY) / 2;
  const controlY2 = endY - Math.abs(endY - startY) / 2;
  
  return `M ${startX} ${startY} C ${startX} ${controlY1}, ${endX} ${controlY2}, ${endX} ${endY}`;
};

// 节点拖拽开始（从工具箱）
const handleNodeDragStart = (event: DragEvent, nodeType: NodeTypeDef) => {
  event.dataTransfer?.setData('nodeType', nodeType.type);
  event.dataTransfer?.setData('effectAllowed', 'copy');
};

// 画布拖拽经过
const handleCanvasDragOver = (event: DragEvent) => {
  event.preventDefault();
  event.dataTransfer!.dropEffect = 'copy';
};

// 画布放置节点
const handleCanvasDrop = (event: DragEvent) => {
  event.preventDefault();
  
  const nodeType = event.dataTransfer?.getData('nodeType') as NodeType;
  if (!nodeType || !canvasRef.value) return;
  
  const rect = canvasRef.value.getBoundingClientRect();
  const scale = canvasZoom.value / 100;
  const x = (event.clientX - rect.left) / scale - 100;
  const y = (event.clientY - rect.top) / scale - 40;
  
  const newNode: ProcessNode = {
    id: Date.now(),
    type: nodeType,
    name: getNodeDefaultName(nodeType),
    x: Math.max(0, x),
    y: Math.max(0, y),
    content: {},
  };
  
  processNodes.value.push(newNode);
  
  // 自动连接到上一个节点
  if (nodeType !== 'start') {
    const nonEndNodes = processNodes.value.filter(n => n.type !== 'end' && n.id !== newNode.id);
    if (nonEndNodes.length > 0) {
      const lastNode = nonEndNodes[nonEndNodes.length - 1];
      connections.value.push({
        id: Date.now() + 1,
        sourceNodeId: lastNode.id,
        targetNodeId: newNode.id,
      });
    }
  }

  const nodeTypeNames: Record<NodeType, string> = {
    start: '开始',
    script: '话术',
    condition: '条件',
    end: '结束',
  };
  message.success(`已添加${nodeTypeNames[nodeType]}节点`);
};

// 获取节点默认名称
const getNodeDefaultName = (type: NodeType) => {
  const nameMap: Record<NodeType, string> = {
    start: '开始',
    script: '话术节点',
    condition: '条件判断',
    end: '结束',
  };
  return nameMap[type];
};

// 画布点击
const handleCanvasClick = () => {
  selectedNode.value = null;
  selectedConnection.value = null;
};

// 节点点击
const handleNodeClick = (event: MouseEvent, node: ProcessNode) => {
  event.stopPropagation();
  selectedNode.value = node;
  selectedConnection.value = null;
};

// 节点鼠标按下（开始拖拽）
const handleNodeMouseDown = (event: MouseEvent, node: ProcessNode) => {
  if (event.button !== 0) return; // 只响应左键
  
  event.stopPropagation();
  isDraggingNode.value = true;
  draggingNode.value = node;
  dragOffset.x = event.clientX - node.x;
  dragOffset.y = event.clientY - node.y;
  
  // 添加全局鼠标事件监听
  document.addEventListener('mousemove', handleNodeDragMove);
  document.addEventListener('mouseup', handleNodeDragUp);
};

// 节点拖拽移动
const handleNodeDragMove = (event: MouseEvent) => {
  if (!isDraggingNode.value || !draggingNode.value) return;
  
  const scale = canvasZoom.value / 100;
  const newX = (event.clientX - dragOffset.x) / scale;
  const newY = (event.clientY - dragOffset.y) / scale;
  
  draggingNode.value.x = Math.max(0, newX);
  draggingNode.value.y = Math.max(0, newY);
};

// 节点拖拽结束
const handleNodeDragUp = () => {
  isDraggingNode.value = false;
  draggingNode.value = null;
  document.removeEventListener('mousemove', handleNodeDragMove);
  document.removeEventListener('mouseup', handleNodeDragUp);
};

// 连接点鼠标按下（开始连线）
const handleConnectorMouseDown = (event: MouseEvent, node: ProcessNode) => {
  if (event.button !== 0) return;
  
  event.stopPropagation();
  isDrawingConnection.value = true;
  drawingSourceNode.value = node;
  
  const rect = canvasRef.value?.getBoundingClientRect();
  if (rect) {
    const scale = canvasZoom.value / 100;
    tempMousePosition.x = (event.clientX - rect.left) / scale;
    tempMousePosition.y = (event.clientY - rect.top) / scale;
  }
  
  // 添加全局鼠标事件监听
  document.addEventListener('mousemove', handleConnectionDragMove);
  document.addEventListener('mouseup', handleConnectionDragUp);
};

// 连接线拖拽移动
const handleConnectionDragMove = (event: MouseEvent) => {
  if (!isDrawingConnection.value || !canvasRef.value) return;
  
  const rect = canvasRef.value.getBoundingClientRect();
  const scale = canvasZoom.value / 100;
  tempMousePosition.x = (event.clientX - rect.left) / scale;
  tempMousePosition.y = (event.clientY - rect.top) / scale;
};

// 连接线拖拽结束
const handleConnectionDragUp = (event: MouseEvent) => {
  if (!isDrawingConnection.value || !drawingSourceNode.value) {
    document.removeEventListener('mousemove', handleConnectionDragMove);
    document.removeEventListener('mouseup', handleConnectionDragUp);
    return;
  }
  
  // 检查是否放置在目标节点上
  const rect = canvasRef.value?.getBoundingClientRect();
  if (rect) {
    const scale = canvasZoom.value / 100;
    const mouseX = (event.clientX - rect.left) / scale;
    const mouseY = (event.clientY - rect.top) / scale;
    
    // 查找目标节点
    const targetNode = processNodes.value.find(node => {
      const nodeWidth = 200;
      const nodeHeight = node.type === 'condition' ? 120 : 80;
      return (
        mouseX >= node.x &&
        mouseX <= node.x + nodeWidth &&
        mouseY >= node.y &&
        mouseY <= node.y + nodeHeight &&
        node.id !== drawingSourceNode.value!.id
      );
    });
    
    if (targetNode && targetNode.type !== 'start') {
      // 检查是否已存在连接
      const exists = connections.value.some(
        c => c.sourceNodeId === drawingSourceNode.value!.id && c.targetNodeId === targetNode.id
      );
      
      if (!exists) {
        connections.value.push({
          id: Date.now(),
          sourceNodeId: drawingSourceNode.value.id,
          targetNodeId: targetNode.id,
        });
        message.success('已创建连接');
      }
    }
  }
  
  isDrawingConnection.value = false;
  drawingSourceNode.value = null;
  document.removeEventListener('mousemove', handleConnectionDragMove);
  document.removeEventListener('mouseup', handleConnectionDragUp);
};

// 连接线点击
const handleConnectionClick = (event: MouseEvent, connection: Connection) => {
  event.stopPropagation();
  selectedConnection.value = connection;
  selectedNode.value = null;
};

// 删除连接线
const handleDeleteConnection = (connection: Connection) => {
  const index = connections.value.findIndex(c => c.id === connection.id);
  if (index !== -1) {
    connections.value.splice(index, 1);
    selectedConnection.value = null;
    message.success('已删除连接线');
  }
};

// 删除节点
const handleDeleteNode = (node: ProcessNode) => {
  // 删除相关连接
  connections.value = connections.value.filter(
    c => c.sourceNodeId !== node.id && c.targetNodeId !== node.id
  );
  
  // 删除节点
  const index = processNodes.value.findIndex(n => n.id === node.id);
  if (index !== -1) {
    processNodes.value.splice(index, 1);
    selectedNode.value = null;
    message.success('已删除节点');
  }
};

// 打开节点编辑弹窗
const openNodeEditModal = (node: ProcessNode) => {
  editingNode.value = node;
  nodeEditForm.name = node.name;
  nodeEditForm.text = node.content?.text || '';
  nodeEditForm.condition = node.content?.condition || '';
  nodeEditForm.yesNextNode = node.content?.yesNextNode?.toString() || '';
  nodeEditForm.noNextNode = node.content?.noNextNode?.toString() || '';
  nodeEditModalVisible.value = true;
};

// 取消节点编辑
const handleNodeEditCancel = () => {
  nodeEditModalVisible.value = false;
  editingNode.value = null;
  nodeEditFormRef.value?.resetFields();
};

// 提交节点编辑
const handleNodeEditSubmit = async () => {
  try {
    await nodeEditFormRef.value?.validate();
    if (editingNode.value) {
      editingNode.value.name = nodeEditForm.name;
      if (!editingNode.value.content) {
        editingNode.value.content = {};
      }
      if (editingNode.value.type === 'script') {
        editingNode.value.content.text = nodeEditForm.text;
      } else if (editingNode.value.type === 'condition') {
        editingNode.value.content.condition = nodeEditForm.condition;
      }
      message.success('保存成功');
      nodeEditModalVisible.value = false;
      editingNode.value = null;
    }
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// AI 生成节点内容
const handleAiGenerateNodeContent = () => {
  message.loading('AI 正在生成内容...', 1.5);
  setTimeout(() => {
    nodeEditForm.text = '这是 AI 生成的话术内容示例。您可以根据实际需求调整或重新生成。';
    message.success('AI 生成成功');
  }, 1500);
};

// 打开连接线编辑弹窗
const handleConnectionEdit = (connection: Connection) => {
  selectedConnection.value = connection;
  connectionEditForm.condition = connection.condition || '';
  connectionEditForm.label = connection.label || '';
  connectionEditModalVisible.value = true;
};

// 取消连接线编辑
const handleConnectionEditCancel = () => {
  connectionEditModalVisible.value = false;
  connectionEditFormRef.value?.resetFields();
};

// 提交连接线编辑
const handleConnectionEditSubmit = () => {
  if (selectedConnection.value) {
    selectedConnection.value.condition = connectionEditForm.condition;
    selectedConnection.value.label = connectionEditForm.label;
    message.success('保存成功');
    connectionEditModalVisible.value = false;
  }
};

// 画布缩放
const handleZoomIn = () => {
  canvasZoom.value = Math.min(canvasZoom.value + 10, 200);
};

const handleZoomOut = () => {
  canvasZoom.value = Math.max(canvasZoom.value - 10, 50);
};

const handleResetZoom = () => {
  canvasZoom.value = 100;
};

// 自动布局
const handleAutoLayout = () => {
  // 简单的垂直布局
  const startY = 50;
  const gapY = 130;
  const centerX = 300;
  
  processNodes.value.forEach((node, index) => {
    node.x = centerX;
    node.y = startY + index * gapY;
  });
  
  message.success('已自动布局');
};

// 保存流程
const handleSaveProcess = () => {
  console.log('保存流程:', {
    nodes: processNodes.value,
    connections: connections.value,
  });
  message.success('流程保存成功');
};

// 获取 QA 类型颜色
const getQaTypeColor = (qaType: string) => {
  const colorMap: Record<string, string> = {
    '场景 QA': 'blue',
    '行业 QA': 'purple',
    '通用 QA': 'green',
  };
  return colorMap[qaType] || 'default';
};

// 获取标签页名称
const getTabName = (key: string) => {
  const tabMap: Record<string, string> = {
    basic: '基本信息',
    process: '主流程设置',
    intent: '意图库',
    'user-classify': '用户分类',
    fallback: '流程兜底设置',
  };
  return tabMap[key] || '';
};

// 标签页切换
const handleTabChange = (key: string) => {
  console.log('切换标签页:', key);
  // TODO: 实现标签页切换逻辑
};

// QA 类型筛选
const handleQaTypeChange = (value: string) => {
  console.log('选择 QA 类型:', value);
  // TODO: 实现筛选逻辑
  if (value !== 'all') {
    const typeMap: Record<string, string> = {
      scene: '场景 QA',
      industry: '行业 QA',
      common: '通用 QA',
    };
    message.info(`筛选：${typeMap[value]}`);
  }
};

// 搜索
const handleSearch = () => {
  console.log('搜索关键词:', searchKeyword.value);
  // TODO: 实现搜索逻辑
  message.info(`搜索：${searchKeyword.value}`);
};

// 重置
const handleReset = () => {
  searchKeyword.value = '';
  console.log('重置搜索');
  // TODO: 实现重置逻辑
  message.success('已重置搜索条件');
};

// 分页变化
const handlePageChange = (page: number) => {
  console.log('页码变化:', page);
  // TODO: 实现分页加载逻辑
};

// 每页条数变化
const handlePageSizeChange = (_current: number, size: number) => {
  console.log('每页条数变化:', size);
  // TODO: 实现分页大小变化逻辑
};

// 新建 QA
const handleCreateQa = () => {
  createQaModalVisible.value = true;
};

// 取消新建 QA
const handleCreateQaCancel = () => {
  createQaModalVisible.value = false;
  createQaFormRef.value?.resetFields();
  createQaForm.question = '';
  createQaForm.replies = [];
};

// 新增回复输入框
const handleAddNewReply = () => {
  createQaForm.replies.push({ replyText: '' });
};

// 删除回复输入框
const handleDeleteReplyInput = (index: number) => {
  createQaForm.replies.splice(index, 1);
};

// AI 生成回复（新建 QA 列表中的回复）
const handleAiGenerateReply = (index: number) => {
  console.log('AI 生成回复，索引:', index);
  // TODO: 调用 AI 接口生成回复
  message.loading('AI 正在生成回复...', 1.5);
  setTimeout(() => {
    createQaForm.replies[index].replyText = '这是 AI 生成的回复内容示例。您可以根据实际需求调整或重新生成。';
    message.success('AI 生成成功');
  }, 1500);
};

// AI 生成回复（编辑回复弹窗）
const handleAiGenerateEditReply = () => {
  console.log('AI 生成编辑回复');
  // TODO: 调用 AI 接口生成回复
  message.loading('AI 正在生成回复...', 1.5);
  setTimeout(() => {
    editReplyForm.replyText = '这是 AI 生成的回复内容示例。您可以根据实际需求调整或重新生成。';
    message.success('AI 生成成功');
  }, 1500);
};

// AI 生成回复（新增回复弹窗）
const handleAiGenerateAddReply = () => {
  console.log('AI 生成新增回复');
  // TODO: 调用 AI 接口生成回复
  message.loading('AI 正在生成回复...', 1.5);
  setTimeout(() => {
    addReplyForm.replyText = '这是 AI 生成的回复内容示例。您可以根据实际需求调整或重新生成。';
    message.success('AI 生成成功');
  }, 1500);
};

// ==================== 引用 QA 相关 ====================

// 引用 QA 弹窗
const referenceQaModalVisible = ref(false);
const referenceQaType = ref('all');
const referenceSearchKeyword = ref('');
const referenceSelectAll = ref(false);
const selectedReferenceRowKeys = ref<number[]>([]);
const referenceCurrent = ref(1);
const referencePageSize = ref(10);
const referenceTotal = ref(88);

// 表格列配置
const referenceColumns = [
  {
    title: 'ID',
    dataIndex: 'id',
    key: 'id',
    width: 100,
  },
  {
    title: 'QA 名称',
    dataIndex: 'qaName',
    key: 'qaName',
    width: 400,
  },
  {
    title: '相似问数量',
    dataIndex: 'similarCount',
    key: 'similarCount',
    width: 120,
  },
];

// 模拟数据
const referenceQaList = ref([
  { id: 118337, qaName: 'com.是骗子吗', similarCount: 150 },
  { id: 118338, qaName: 'com.是正规的吗', similarCount: 150 },
  { id: 118341, qaName: 'com.为什么不是官方电话', similarCount: 150 },
  { id: 118342, qaName: 'yh.叫什么名字', similarCount: 150 },
  { id: 118343, qaName: 'com.在忙', similarCount: 150 },
  { id: 118344, qaName: 'yh.银行地址', similarCount: 150 },
  { id: 118345, qaName: 'yh.你加我微信吧', similarCount: 150 },
  { id: 118346, qaName: 'yh.你发个短信给我', similarCount: 150 },
  { id: 118347, qaName: 'yh.是机器人吗', similarCount: 150 },
  { id: 118348, qaName: 'com.打很多次了', similarCount: 150 },
]);

// 引用 QA 相关方法（弹窗中的）
const handleReferenceQa = () => {
  referenceQaModalVisible.value = true;
  selectedReferenceRowKeys.value = [];
  referenceSelectAll.value = false;
};

const handleReferenceQaCancel = () => {
  referenceQaModalVisible.value = false;
  selectedReferenceRowKeys.value = [];
  referenceSelectAll.value = false;
};

const handleReferenceSearch = () => {
  console.log('搜索:', referenceSearchKeyword.value);
};

const handleReferenceSearchReset = () => {
  referenceSearchKeyword.value = '';
};

const onReferenceSelectionChange = (selectedRowKeys: number[]) => {
  selectedReferenceRowKeys.value = selectedRowKeys;
  referenceSelectAll.value = selectedRowKeys.length === referenceQaList.value.length;
};

const onReferenceSelectAll = (e: Event) => {
  const checked = (e.target as HTMLInputElement).checked;
  if (checked) {
    selectedReferenceRowKeys.value = referenceQaList.value.map(item => item.id);
  } else {
    selectedReferenceRowKeys.value = [];
  }
};

const handleReferencePageChange = (page: number) => {
  console.log('页码变化:', page);
};

const handleReferencePageSizeChange = (_current: number, size: number) => {
  console.log('每页条数变化:', size);
};

const handleReferenceQaImport = () => {
  console.log('导入选中的 QA:', selectedReferenceRowKeys.value);
  message.success(`已导入${selectedReferenceRowKeys.value.length}条 QA`);
  referenceQaModalVisible.value = false;
  selectedReferenceRowKeys.value = [];
};

// 提交新建 QA
const handleCreateQaSubmit = async () => {
  try {
    await createQaFormRef.value?.validate();
    if (createQaForm.replies.length === 0) {
      message.error('请至少添加一条回复');
      return;
    }
    // 检查所有回复是否都填写了
    const emptyReplies = createQaForm.replies.filter(r => !r.replyText || r.replyText.trim() === '');
    if (emptyReplies.length > 0) {
      message.error('请填写所有回复内容');
      return;
    }
    console.log('新建 QA 表单数据:', createQaForm);
    // TODO: 实现新建 QA 保存逻辑
    message.success('新建 QA 成功');
    createQaModalVisible.value = false;
    createQaFormRef.value?.resetFields();
    createQaForm.question = '';
    createQaForm.replies = [];
  } catch (error) {
    console.log('表单验证失败:', error);
  }
};

// 引用 QA（QA 列表中的）
// 注：此函数暂未使用，保留用于后续功能扩展

// 异常检测
const handleExceptionCheck = () => {
  // 模拟检测后显示无异常提示
  message.success('QA 配置无异常');
};

// ==================== 意图库相关方法 ====================

// 选择菜单
const handleSelectIntentMenu = (key: string) => {
  selectedIntentMenu.value = key;
  console.log('选择意图菜单:', key);
  // TODO: 根据菜单筛选数据
};

// 搜索
const handleIntentSearch = () => {
  console.log('搜索意图:', intentSearchKeyword.value, intentTypeFilter.value);
  message.info(`搜索：${intentSearchKeyword.value || '全部'} ${intentTypeFilter.value || ''}`);
  // TODO: 实现搜索逻辑
};

// 重置
const handleIntentReset = () => {
  intentSearchKeyword.value = '';
  intentTypeFilter.value = '';
  console.log('重置意图搜索');
  message.success('已重置搜索条件');
};

// 表格变化（分页、排序等）
const handleIntentTableChange = (pagination: any) => {
  intentPagination.current = pagination.current;
  intentPagination.pageSize = pagination.pageSize;
  console.log('意图表格变化:', pagination);
  // TODO: 实现数据加载
};

// 新建场景意图
const handleCreateIntent = () => {
  console.log('新建场景意图');
  message.info('新建场景意图');
  // TODO: 实现新建意图弹窗
};

// 引用通用/行业意图
const handleReferenceIntent = () => {
  console.log('引用通用/行业意图');
  message.info('引用通用/行业意图');
  // TODO: 实现引用意图弹窗
};

// 语料管理
const handleCorpusManage = (record: IntentItem) => {
  console.log('语料管理:', record);
  message.info(`语料管理：${record.intentName}`);
  // TODO: 实现语料管理弹窗
};

// 编辑意图
const handleEditIntent = (record: IntentItem) => {
  console.log('编辑意图:', record);
  message.info(`编辑意图：${record.intentName}`);
  // TODO: 实现编辑意图弹窗
};

// 删除意图
const handleDeleteIntent = (record: IntentItem) => {
  console.log('删除意图:', record);
  const index = intentList.value.findIndex(item => item.id === record.id);
  if (index !== -1) {
    intentList.value.splice(index, 1);
  }
  message.success('删除意图成功');
};

// ==================== 用户分类相关方法 ====================

// 选择分类
const handleSelectCategory = (id: number) => {
  selectedCategoryId.value = id;
};

// 编辑分类
const handleEditCategory = (category: UserCategory) => {
  console.log('编辑分类:', category);
  message.info(`编辑分类：${category.name}`);
  // TODO: 实现编辑分类弹窗
};

// 添加分类
const handleAddCategory = () => {
  console.log('添加分类');
  message.info('添加新分类');
  // TODO: 实现添加分类弹窗
};

// 新增规则表达式
const handleAddRule = () => {
  console.log('新增表达式');
  message.info('新增规则表达式');
  // TODO: 实现新增规则弹窗
};

// 编辑规则
const handleEditRule = (rule: CategoryRule) => {
  console.log('编辑规则:', rule);
  message.info(`编辑规则：${rule.expression}`);
  // TODO: 实现编辑规则弹窗
};

// 删除规则
const handleDeleteRule = (rule: CategoryRule) => {
  console.log('删除规则:', rule);
  const category = userCategories.value.find(c => c.id === selectedCategoryId.value);
  if (category) {
    const ruleIndex = category.rules.findIndex(r => r.id === rule.id);
    if (ruleIndex !== -1) {
      category.rules.splice(ruleIndex, 1);
    }
  }
  message.success('删除规则成功');
};

// 保存用户分类配置
const handleSaveClassify = () => {
  console.log('保存用户分类:', userCategories.value);
  message.success('保存成功');
  // TODO: 实现保存接口调用
};

// ==================== 流程兜底设置相关方法 ====================

// 删除静音超时回复（至少保留一个）
const handleDeleteSilenceReply = (index: number) => {
  if (fallbackForm.silenceReplies.length > 1) {
    fallbackForm.silenceReplies.splice(index, 1);
  } else {
    message.warning('至少保留一条回复');
  }
};

// 添加静音超时回复
const handleAddSilenceReply = () => {
  fallbackForm.silenceReplies.push('');
};

// 上移静音超时回复
const handleMoveUpSilenceReply = (index: number) => {
  if (index > 0) {
    [fallbackForm.silenceReplies[index - 1], fallbackForm.silenceReplies[index]] = 
    [fallbackForm.silenceReplies[index], fallbackForm.silenceReplies[index - 1]];
  }
};

// 下移静音超时回复
const handleMoveDownSilenceReply = (index: number) => {
  if (index < fallbackForm.silenceReplies.length - 1) {
    [fallbackForm.silenceReplies[index], fallbackForm.silenceReplies[index + 1]] = 
    [fallbackForm.silenceReplies[index + 1], fallbackForm.silenceReplies[index]];
  }
};

// 删除语义为空回复（至少保留一个）
const handleDeleteEmptySemanticsReply = (index: number) => {
  if (fallbackForm.emptySemanticsReplies.length > 1) {
    fallbackForm.emptySemanticsReplies.splice(index, 1);
  } else {
    message.warning('至少保留一条回复');
  }
};

// 添加语义为空回复
const handleAddEmptySemanticsReply = () => {
  fallbackForm.emptySemanticsReplies.push('');
};

// 上移语义为空回复
const handleMoveUpEmptySemanticsReply = (index: number) => {
  if (index > 0) {
    [fallbackForm.emptySemanticsReplies[index - 1], fallbackForm.emptySemanticsReplies[index]] = 
    [fallbackForm.emptySemanticsReplies[index], fallbackForm.emptySemanticsReplies[index - 1]];
  }
};

// 下移语义为空回复
const handleMoveDownEmptySemanticsReply = (index: number) => {
  if (index < fallbackForm.emptySemanticsReplies.length - 1) {
    [fallbackForm.emptySemanticsReplies[index], fallbackForm.emptySemanticsReplies[index + 1]] = 
    [fallbackForm.emptySemanticsReplies[index + 1], fallbackForm.emptySemanticsReplies[index]];
  }
};

// 删除强制挂断回复
const handleDeleteHangupReply = (index: number) => {
  fallbackForm.hangupReplies.splice(index, 1);
};

// 添加强制挂断回复
const handleAddHangupReply = () => {
  fallbackForm.hangupReplies.push('');
};

// 上移强制挂断回复
const handleMoveUpHangupReply = (index: number) => {
  if (index > 0) {
    [fallbackForm.hangupReplies[index - 1], fallbackForm.hangupReplies[index]] = 
    [fallbackForm.hangupReplies[index], fallbackForm.hangupReplies[index - 1]];
  }
};

// 下移强制挂断回复
const handleMoveDownHangupReply = (index: number) => {
  if (index < fallbackForm.hangupReplies.length - 1) {
    [fallbackForm.hangupReplies[index], fallbackForm.hangupReplies[index + 1]] = 
    [fallbackForm.hangupReplies[index + 1], fallbackForm.hangupReplies[index]];
  }
};

// 删除按键错误回复
const handleDeleteKeyErrorReply = (index: number) => {
  fallbackForm.keyErrorReplies.splice(index, 1);
};

// 添加按键错误回复
const handleAddKeyErrorReply = () => {
  fallbackForm.keyErrorReplies.push('');
};

// 上移按键错误回复
const handleMoveUpKeyErrorReply = (index: number) => {
  if (index > 0) {
    [fallbackForm.keyErrorReplies[index - 1], fallbackForm.keyErrorReplies[index]] = 
    [fallbackForm.keyErrorReplies[index], fallbackForm.keyErrorReplies[index - 1]];
  }
};

// 下移按键错误回复
const handleMoveDownKeyErrorReply = (index: number) => {
  if (index < fallbackForm.keyErrorReplies.length - 1) {
    [fallbackForm.keyErrorReplies[index], fallbackForm.keyErrorReplies[index + 1]] = 
    [fallbackForm.keyErrorReplies[index + 1], fallbackForm.keyErrorReplies[index]];
  }
};

// 删除转人工坐席忙回复
const handleDeleteTransferBusyReply = (index: number) => {
  fallbackForm.transferBusyReplies.splice(index, 1);
};

// 添加转人工坐席忙回复
const handleAddTransferBusyReply = () => {
  fallbackForm.transferBusyReplies.push('');
};

// 上移转人工坐席忙回复
const handleMoveUpTransferBusyReply = (index: number) => {
  if (index > 0) {
    [fallbackForm.transferBusyReplies[index - 1], fallbackForm.transferBusyReplies[index]] = 
    [fallbackForm.transferBusyReplies[index], fallbackForm.transferBusyReplies[index - 1]];
  }
};

// 下移转人工坐席忙回复
const handleMoveDownTransferBusyReply = (index: number) => {
  if (index < fallbackForm.transferBusyReplies.length - 1) {
    [fallbackForm.transferBusyReplies[index], fallbackForm.transferBusyReplies[index + 1]] = 
    [fallbackForm.transferBusyReplies[index + 1], fallbackForm.transferBusyReplies[index]];
  }
};

// 重置流程兜底设置
const handleResetFallback = () => {
  fallbackFormRef.value?.resetFields();
  message.success('已重置表单');
};

// 保存流程兜底设置
const handleSaveFallback = async () => {
  try {
    // 验证必填字段
    await fallbackFormRef.value?.validate();
    
    // 验证静音超时回复
    if (fallbackForm.silenceReplies.length === 0 || fallbackForm.silenceReplies.some(r => !r || r.trim() === '')) {
      message.error('请填写完整的静音超时回复，至少一条');
      return;
    }
    
    // 验证语义为空回复
    if (fallbackForm.emptySemanticsReplies.length === 0 || fallbackForm.emptySemanticsReplies.some(r => !r || r.trim() === '')) {
      message.error('请填写完整的语义为空回复，至少一条');
      return;
    }
    
    console.log('流程兜底设置表单数据:', fallbackForm);
    // TODO: 实现保存逻辑
    message.success('保存成功');
  } catch (error) {
    console.log('表单验证失败:', error);
  }
};

// 新增回复
const handleAddReply = (qa: QaItem) => {
  currentAddQa.value = qa;
  addReplyForm.replyText = '';
  addReplyModalVisible.value = true;
};

// 取消新增回复
const handleAddReplyCancel = () => {
  addReplyModalVisible.value = false;
  addReplyFormRef.value?.resetFields();
  currentAddQa.value = null;
};

// 提交新增回复
const handleAddReplySubmit = async () => {
  try {
    await addReplyFormRef.value?.validate();
    console.log('新增回复表单数据:', addReplyForm);
    console.log('所属 QA:', currentAddQa.value);
    // TODO: 实现新增回复保存逻辑
    if (currentAddQa.value) {
      const newReply: ReplyItem = {
        id: Date.now(),
        replyText: addReplyForm.replyText,
        scene: '当前模板新增',
      };
      currentAddQa.value.replies.push(newReply);
    }
    message.success('新增回复成功');
    addReplyModalVisible.value = false;
    addReplyFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 编辑回复
const handleEditReply = (reply: ReplyItem) => {
  editReplyForm.id = reply.id;
  editReplyForm.replyText = reply.replyText;
  editReplyModalVisible.value = true;
};

// 取消编辑回复
const handleEditReplyCancel = () => {
  editReplyModalVisible.value = false;
  editReplyFormRef.value?.resetFields();
};

// 提交编辑回复
const handleEditReplySubmit = async () => {
  try {
    await editReplyFormRef.value?.validate();
    console.log('编辑回复表单数据:', editReplyForm);
    // TODO: 实现编辑回复保存逻辑
    if (currentEditQa.value) {
      const replyIndex = currentEditQa.value.replies.findIndex(r => r.id === editReplyForm.id);
      if (replyIndex !== -1) {
        currentEditQa.value.replies[replyIndex] = {
          id: editReplyForm.id,
          replyText: editReplyForm.replyText,
          scene: editReplyForm.scene,
        };
      }
    }
    message.success('编辑回复成功');
    editReplyModalVisible.value = false;
    editReplyFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 删除回复
const handleDeleteReply = (reply: ReplyItem, qa: QaItem) => {
  console.log('删除回复:', reply);
  // TODO: 实现删除回复逻辑
  const replyIndex = qa.replies.findIndex(r => r.id === reply.id);
  if (replyIndex !== -1) {
    qa.replies.splice(replyIndex, 1);
  }
  message.success('删除回复成功');
};

// 初始化
onMounted(() => {
  console.log('SceneTemplateDetail 组件已挂载');
  // TODO: 加载初始数据
});
</script>

<style scoped>
.scene-template-detail {
  height: 100%;
  background: #f0f2f5;
  padding: 16px;
}

/* 标签页区域 */
.tabs-section {
  background: #fff;
  padding: 16px 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.tabs-section :deep(.ant-tabs-nav) {
  margin: 0;
}

/* 基本信息内容区域 */
.basic-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
}

.basic-form-wrapper {
  flex: 1;
  overflow-y: auto;
  background: #fff;
  padding: 24px;
  margin: 0 24px 24px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.basic-form-wrapper :deep(.ant-descriptions-bordered .ant-descriptions-item-label) {
  background: #fafafa;
  font-weight: 500;
  width: 120px;
}

.basic-form-wrapper :deep(.ant-descriptions-item-label) {
  color: #262626;
}

.basic-form-wrapper :deep(.ant-descriptions-item-content) {
  color: #595959;
}

/* QA 库内容区域 */
.qa-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
}

.qa-scroll-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  min-height: 0;
  padding: 0 24px 24px 24px;
}

/* 顶部操作区 */
.toolbar-section {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-shrink: 0;
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.toolbar-right {
  display: flex;
  align-items: center;
}

/* QA 卡片列表 */
.qa-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.qa-card {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  overflow: visible;
}

/* 卡片头部 */
.qa-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.qa-id {
  font-size: 12px;
  color: #8c8c8c;
}

.qa-question {
  font-size: 15px;
  font-weight: 500;
  color: #262626;
}

.qa-process {
  font-size: 14px;
  color: #595959;
}

/* 回复表格区域 */
.reply-table-wrapper {
  padding: 16px 20px;
}

.reply-table-wrapper :deep(.ant-table) {
  font-size: 13px;
}

.reply-table-wrapper :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
}

.reply-text {
  display: block;
  white-space: normal;
  line-height: 1.6;
  color: #333;
}

.scene-text {
  color: #1890ff;
}

.action-link {
  color: #1890ff;
  cursor: pointer;
  text-decoration: none;
}

.action-link:hover {
  color: #40a9ff;
}

.delete-link {
  color: #ff4d4f;
}

.delete-link:hover {
  color: #ff7875;
}

/* 分页区域 */
.pagination-section {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: flex-end;
}

/* 其他标签页占位 */
.other-tab-placeholder {
  height: calc(100% - 80px);
  background: #fff;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

/* 意图库内容区域 */
.intent-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
  padding: 0 24px 24px 24px;
}

.intent-wrapper {
  flex: 1;
  display: flex;
  gap: 16px;
  overflow: hidden;
}

/* 左侧菜单 */
.intent-sidebar {
  width: 180px;
  background: #fff;
  border-radius: 4px;
  padding: 12px 0;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.intent-sidebar .menu-item {
  padding: 12px 24px;
  font-size: 14px;
  color: #595959;
  cursor: pointer;
  transition: all 0.3s;
  border-left: 3px solid transparent;
}

.intent-sidebar .menu-item:hover {
  background: #f5f5f5;
}

.intent-sidebar .menu-item.active {
  background: #e6f7ff;
  color: #1890ff;
  border-left-color: #1890ff;
  font-weight: 500;
}

/* 右侧内容区 */
.intent-main-content {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  padding: 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 顶部操作栏 */
.intent-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.toolbar-left,
.toolbar-right {
  display: flex;
  align-items: center;
}

/* 表格区域 */
.intent-table-wrapper {
  flex: 1;
  overflow: auto;
}

.intent-table-wrapper :deep(.ant-table) {
  font-size: 14px;
}

.intent-table-wrapper :deep(.ant-table-thead > tr > th) {
  background: #69c0ff;
  color: #fff;
  font-weight: 500;
}

.intent-table-wrapper :deep(.ant-table-tbody > tr:hover) {
  background: #e6f7ff;
}

/* 用户分类内容区域 */
.user-classify-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
  padding: 0 24px 24px 24px;
}

.user-classify-wrapper {
  flex: 1;
  display: flex;
  gap: 16px;
  overflow: hidden;
}

/* 左侧分类列表 */
.classify-sidebar {
  width: 220px;
  background: #fff;
  border-radius: 4px;
  padding: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.sidebar-title {
  font-size: 15px;
  font-weight: 500;
  color: #262626;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.category-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  margin-bottom: 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
}

.category-item:hover {
  background: #f5f5f5;
}

.category-item.active {
  background: #e6f7ff;
  color: #1890ff;
}

.category-name {
  font-size: 14px;
  color: #595959;
}

.category-item.active .category-name {
  color: #1890ff;
  font-weight: 500;
}

.add-category-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px;
  margin-top: 16px;
  color: #1890ff;
  font-size: 14px;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.3s;
}

.add-category-btn:hover {
  background: #e6f7ff;
}

/* 右侧规则配置区 */
.classify-main-content {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  padding: 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.default-rule-alert {
  padding: 12px 16px;
  background: #fff1f0;
  border: 1px solid #ffccc7;
  border-radius: 4px;
  color: #d4380d;
  font-size: 14px;
  margin-bottom: 16px;
}

.rule-list-container {
  flex: 1;
  overflow-y: auto;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 16px;
  margin-bottom: 16px;
}

.rule-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.rule-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #fafafa;
  border-radius: 4px;
  border: 1px solid #e8e8e8;
}

.rule-expression {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.rule-index {
  font-size: 14px;
  color: #8c8c8c;
  min-width: 24px;
}

.expression-text {
  font-size: 14px;
  color: #262626;
  font-family: 'Courier New', monospace;
}

.rule-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.add-rule-btn-wrapper {
  display: flex;
  justify-content: flex-start;
}

.save-btn-wrapper {
  display: flex;
  justify-content: flex-end;
  padding-top: 16px;
}

/* 弹窗底部按钮区 */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 24px;
}

/* 回复输入列表 */
.reply-input-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 400px;
  overflow-y: auto;
  margin-top: 12px;
}

.reply-input-item {
  padding: 12px;
  background: #fafafa;
  border-radius: 4px;
  border: 1px solid #e8e8e8;
}

.reply-input-content {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.reply-input-content .ant-textarea {
  flex: 1;
}

.reply-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex-shrink: 0;
  padding-top: 8px;
}

.ai-generate-btn {
  color: #722ed1;
  font-size: 13px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  border-radius: 4px;
  background: #f9f0ff;
  transition: all 0.3s;
}

.ai-generate-btn:hover {
  background: #f3e5f5;
  color: #9254de;
}

.delete-reply-btn {
  color: #ff4d4f;
  font-size: 13px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  border-radius: 4px;
  transition: all 0.3s;
}

.delete-reply-btn:hover {
  color: #ff7875;
  background: #fff1f0;
}

/* 文本框带操作按钮 */
.textarea-with-action {
  position: relative;
}

.textarea-with-action .ai-generate-btn {
  position: absolute;
  right: 12px;
  bottom: 12px;
  z-index: 1;
}

/* 引用 QA 弹窗 */
.reference-qa-container {
  display: flex;
  height: 500px;
}

.reference-right-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 0;
}

.reference-search-bar {
  padding: 12px 0;
}

.reference-table-wrapper {
  flex: 1;
  overflow: hidden;
}

.reference-table-wrapper .ant-table-wrapper {
  height: 100%;
}

.reference-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-top: 1px solid #f0f0f0;
}

.total-text {
  color: #666;
  font-size: 14px;
}

.selected-count {
  color: #1890ff;
  font-size: 14px;
  margin-right: 16px;
}

/* 滚动条样式 */
.qa-list::-webkit-scrollbar {
  width: 6px;
}

.qa-list::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.qa-list::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.qa-list::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* 流程兜底设置样式 */
.fallback-content {
  height: calc(100vh - 120px);
  overflow: hidden;
  background: #f5f5f5;
  padding: 0 24px 24px 24px;
}

.fallback-form-wrapper {
  height: 100%;
  overflow-y: auto;
  background: #fff;
  padding: 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.form-section {
  margin-bottom: 32px;
  padding-bottom: 24px;
  border-bottom: 1px solid #f0f0f0;
}

.form-section:last-child {
  border-bottom: none;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 20px;
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
  padding-left: 12px;
}

.form-tip {
  font-size: 13px;
  color: #8c8c8c;
  margin-top: 8px;
}

/* 回复输入组 */
.reply-input-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reply-input-item {
  display: flex;
  gap: 8px;
  align-items: flex-start;
}

.reply-input-item .ant-textarea {
  flex: 1;
}

.reply-actions {
  display: flex;
  gap: 4px;
  flex-shrink: 0;
}

.add-reply-link {
  color: #1890ff;
  font-size: 14px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s;
}

.add-reply-link:hover {
  color: #40a9ff;
}

/* 表单底部按钮 */
.form-footer {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding-top: 24px;
  margin-top: 24px;
  border-top: 1px solid #f0f0f0;
}

.form-footer .ant-btn {
  min-width: 100px;
}

/* ==================== 主流程设置样式 ==================== */

/* 流程内容区域 */
.process-content {
  height: calc(100vh - 120px);
  overflow: hidden;
  background: #f5f5f5;
}

.process-wrapper {
  height: 100%;
  display: flex;
  gap: 16px;
  padding: 0 24px 24px 24px;
}

/* 左侧节点工具箱 */
.process-sidebar {
  width: 200px;
  background: #fff;
  border-radius: 4px;
  padding: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
}

.process-sidebar .sidebar-title {
  font-size: 15px;
  font-weight: 500;
  color: #262626;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.node-toolbox {
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
}

.toolbox-node {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 16px;
  background: #fafafa;
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  cursor: grab;
  transition: all 0.3s;
  font-size: 14px;
  color: #595959;
}

.toolbox-node:hover {
  background: #f0f5ff;
  border-color: #91d5ff;
  color: #1890ff;
  transform: translateX(4px);
}

.toolbox-node:active {
  cursor: grabbing;
}

.toolbox-node .anticon {
  font-size: 18px;
}

/* 节点类型颜色 */
.node-type-start {
  background: #f6ffed;
  border-color: #b7eb8f;
}
.node-type-start:hover {
  background: #d9f7be;
  border-color: #95de64;
}

.node-type-script {
  background: #e6f7ff;
  border-color: #91d5ff;
}
.node-type-script:hover {
  background: #bae7ff;
  border-color: #69c0ff;
}

.node-type-condition {
  background: #fff7e6;
  border-color: #ffd591;
}
.node-type-condition:hover {
  background: #ffe7ba;
  border-color: #ffc069;
}

.node-type-end {
  background: #fff1f0;
  border-color: #ffa39e;
}
.node-type-end:hover {
  background: #ffccc7;
  border-color: #ff7875;
}

.sidebar-tip {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: #fffbe6;
  border-radius: 4px;
  font-size: 13px;
  color: #faad14;
  margin-top: auto;
}

/* 画布区域 */
.process-canvas-wrapper {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 画布工具栏 */
.canvas-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
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
  margin-left: 8px;
}

/* 画布 */
.process-canvas {
  flex: 1;
  overflow: auto;
  background: #f5f5f5;
  position: relative;
}

.canvas-content {
  position: relative;
  min-width: 100%;
  min-height: 100%;
  transition: transform 0.2s ease;
}

/* 连接线层 */
.connection-layer {
  position: absolute;
  top: 0;
  left: 0;
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

.connection-layer .connection-selected .connection-line {
  stroke: #1890ff;
  stroke-width: 3;
  marker-end: url(#arrowhead-selected);
}

.connection-delete {
  cursor: pointer;
  pointer-events: all;
}

.connection-delete:hover circle {
  fill: #ff7875;
}

/* 临时连接线 */
.temp-connection-layer {
  position: absolute;
  top: 0;
  left: 0;
  pointer-events: none;
  z-index: 10;
}

.temp-connection-line {
  stroke: #1890ff;
  stroke-width: 2;
  stroke-dasharray: 5, 5;
}

/* 流程节点 */
.process-node {
  position: absolute;
  width: 200px;
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

.process-node.node-selected {
  box-shadow: 0 0 0 2px #1890ff;
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

.process-node.node-type-condition {
  border: 2px solid #faad14;
}
.process-node.node-type-condition .node-header {
  background: #fff7e6;
  color: #faad14;
}

.process-node.node-type-end {
  border: 2px solid #ff4d4f;
}
.process-node.node-type-end .node-header {
  background: #fff1f0;
  color: #ff4d4f;
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

.node-actions {
  display: flex;
  align-items: center;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.3s;
}

.process-node:hover .node-actions {
  opacity: 1;
}

.node-action-btn {
  padding: 0 4px;
  font-size: 14px;
  color: #8c8c8c;
}
.node-action-btn:hover {
  color: #1890ff;
}
.node-action-btn:last-child:hover {
  color: #ff4d4f;
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

/* 条件分支显示 */
.condition-branches {
  display: flex;
  justify-content: space-around;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid #f0f0f0;
}

.branch-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
}

.branch-yes {
  color: #52c41a;
}

.branch-no {
  color: #ff4d4f;
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

/* 分支设置样式 */
.branch-setting {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.branch-setting .ant-input {
  flex: 1;
}

.branch-label {
  font-size: 13px;
  color: #595959;
  white-space: nowrap;
  min-width: 80px;
}

/* 弹窗中的表单提示 */
.form-tip {
  font-size: 12px;
  color: #8c8c8c;
}
</style>
