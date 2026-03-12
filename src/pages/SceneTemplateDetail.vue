<template>
  <div class="scene-template-detail">
    <!-- 顶部标签页 -->
    <div class="tabs-section">
      <a-tabs v-model:activeKey="activeTabKey" @change="handleTabChange">
        <a-tab-pane key="basic" data-tab-key="basic" tab="基本信息" />
        <a-tab-pane key="process" data-tab-key="process" tab="主流程设置" />
        <a-tab-pane key="qa" data-tab-key="qa" tab="QA 库" />
        <a-tab-pane key="intent" data-tab-key="intent" tab="意图库" />
        <a-tab-pane key="fallback" data-tab-key="fallback" tab="流程兜底设置" />
        <a-tab-pane key="script" data-tab-key="script" tab="话术管理" />
        <a-tab-pane key="user-classify" data-tab-key="user-classify" tab="用户分类" />
        <a-tab-pane key="system-settings" data-tab-key="system-settings" tab="场景系统设置" />
        <a-tab-pane key="sms" data-tab-key="sms" tab="场景短信" />
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
        <div class="toolbar-section qa-toolbar">
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
            <a-button type="primary" class="create-scene-qa-btn" @click="handleCreateQa">
              <plus-outlined />
              新建场景 QA
            </a-button>
            <a-dropdown trigger="click">
              <a-button class="reference-qa-btn" @click="handleReferenceQa">
                <link-outlined />
                引用通用/行业 QA
              </a-button>
            </a-dropdown>
            <a-button @click="handleExceptionCheck">
              <warning-outlined />
              异常检测
            </a-button>
            <a-button class="operation-guide-btn" @click="showQaGuide">
              <question-circle-outlined />
              操作引导
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
                  <a-space>
                    <a-button
                      v-if="qa.qaType === '场景 QA'"
                      type="link"
                      size="small"
                      class="add-user-question-btn"
                      @click="handleAddUserQuestion(qa)"
                    >
                      <message-outlined />
                      添加用户问法
                    </a-button>
                    <a-button type="link" size="small" class="add-reply-btn" @click="handleAddReply(qa)">
                      <plus-outlined />
                      新增回复
                    </a-button>
                    <a-popconfirm
                      title="确定删除该 QA？"
                      ok-text="确定"
                      cancel-text="取消"
                      @confirm="handleDeleteQa(qa)"
                    >
                      <a-button type="link" size="small" class="delete-qa-btn">
                        <delete-outlined />
                        删除 QA
                      </a-button>
                    </a-popconfirm>
                  </a-space>
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
              :locale="{
                items_per_page: '条/页',
                jump_to: '跳转至',
                page: '页',
              }"
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
                <div class="reply-input-group fallback-reply-group">
                  <div
                    v-for="(_reply, index) in fallbackForm.silenceReplies"
                    :key="index"
                    class="reply-input-item"
                  >
                    <div class="fallback-reply-content">
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
                <div class="reply-input-group fallback-reply-group">
                  <div
                    v-for="(_reply, index) in fallbackForm.emptySemanticsReplies"
                    :key="index"
                    class="reply-input-item"
                  >
                    <div class="fallback-reply-content">
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
                      <a-button
                        v-if="fallbackForm.hangupReplies.length > 1"
                        type="text"
                        size="small"
                        @click="handleDeleteHangupReply(index)"
                      >
                        <delete-outlined />
                        删除
                      </a-button>
                    </div>
                  </div>
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

    <!-- 话术管理内容区域 -->
    <div v-else-if="activeTabKey === 'script'" class="script-content">
      <div class="script-scroll-wrapper">
        <!-- 话术管理子标签页 -->
        <div class="script-sub-tabs">
          <a-tabs v-model:activeKey="scriptSubTabKey" @change="handleScriptSubTabChange">
            <a-tab-pane key="compliance" data-tab-key="compliance" tab="话术消保" />
            <a-tab-pane key="audio" data-tab-key="audio" tab="话术录音" />
            <a-tab-pane key="variable" data-tab-key="variable" tab="话术变量" />
          </a-tabs>
        </div>

        <!-- 话术消保内容 -->
        <div v-if="scriptSubTabKey === 'compliance'" class="script-sub-content">
          <!-- 顶部操作区 -->
          <div class="script-toolbar-section">
            <div class="script-toolbar-left">
              <a-space>
                <a-input
                  v-model:value="scriptSearchKeyword"
                  placeholder="请输入话术文本搜索"
                  style="width: 200px"
                  @press-enter="handleScriptSearch"
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
            <div class="script-toolbar-right">
              <a-space>
                <a-dropdown trigger="click">
                  <a-button>
                    批量删除 <down-outlined />
                  </a-button>
                  <template #overlay>
                    <a-menu>
                      <a-menu-item key="delete-selected" @click="handleBatchDeleteSelected">
                        删除所选
                      </a-menu-item>
                      <a-menu-item key="delete-all" @click="handleBatchDeleteAll">
                        删除全部
                      </a-menu-item>
                    </a-menu>
                  </template>
                </a-dropdown>
                <a-dropdown trigger="click">
                  <a-button>
                    批量导出 <down-outlined />
                  </a-button>
                  <template #overlay>
                    <a-menu>
                      <a-menu-item key="export-selected" @click="handleBatchExportSelected">
                        导出所选
                      </a-menu-item>
                      <a-menu-item key="export-all" @click="handleBatchExportAll">
                        导出全部
                      </a-menu-item>
                    </a-menu>
                  </template>
                </a-dropdown>
              </a-space>
            </div>
          </div>

          <!-- 数据表格 -->
          <div class="script-list">
            <div class="script-table-wrapper">
              <a-table
                :columns="scriptColumns"
                :data-source="scriptList"
                :pagination="false"
                row-key="id"
                size="middle"
                :row-selection="{ selectedRowKeys: selectedScriptRowKeys, onChange: onScriptSelectChange }"
                @change="handleScriptTableChange"
                :scroll="{ x: 1000 }"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'uid'">
                    <span>{{ record.uid }}</span>
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
                  <template v-if="column.key === 'action'">
                    <a-space :size="8">
                      <a-button type="link" size="small" @click="handleEditScript(record)">
                        <edit-outlined />
                        编辑
                      </a-button>
                      <template v-if="record.complianceStatus === '未消保'">
                        <a-dropdown trigger="click">
                          <a-button type="link" size="small">
                            话术消保 <down-outlined />
                          </a-button>
                          <template #overlay>
                            <a-menu>
                              <a-menu-item key="pass" @click="handleCompliancePass(record)" class="compliance-pass">
                                <check-circle-outlined />
                                <span class="pass-text">消保通过</span>
                              </a-menu-item>
                              <a-menu-item key="reject" @click="handleComplianceReject(record)" class="compliance-reject">
                                <close-circle-outlined />
                                <span class="reject-text">消保不通过</span>
                              </a-menu-item>
                            </a-menu>
                          </template>
                        </a-dropdown>
                      </template>
                    </a-space>
                  </template>
                </template>
              </a-table>
            </div>
            <!-- 分页 -->
            <div class="script-pagination">
              <span class="selected-count">共 {{ scriptTotal }} 条，已选择 {{ selectedScriptRowKeys.length }} 条</span>
              <a-pagination
                v-model:current="scriptPagination.current"
                v-model:page-size="scriptPagination.pageSize"
                :total="scriptPagination.total"
                show-size-changer
                show-quick-jumper
                :show-total="(total: number) => `共 ${total} 条`"
                :page-size-options="['10', '20', '50']"
                :locale="{
                  items_per_page: '条/页',
                  jump_to: '跳转至',
                  page: '页',
                }"
                @change="handleScriptPageChange"
                @show-size-change="handleScriptPageSizeChange"
              />
            </div>
          </div>
        </div>

        <!-- 话术录音内容 -->
        <div v-else-if="scriptSubTabKey === 'audio'" class="script-sub-content">
          <!-- 录音包列表页面 -->
          <div v-if="!showAudioDetail" class="audio-package-list">
            <!-- 顶部操作区 -->
            <div class="script-toolbar-section">
              <div class="script-toolbar-left">
                <a-space>
                  <a-input
                    v-model:value="audioPackageSearchKeyword"
                    placeholder="请输入录音包名称搜索"
                    style="width: 200px"
                    @press-enter="handleAudioPackageSearch"
                  >
                    <template #prefix>
                      <search-outlined />
                    </template>
                  </a-input>
                  <a-button type="primary" @click="handleAudioPackageSearch">
                    <search-outlined />
                    搜索
                  </a-button>
                  <a-button @click="handleAudioPackageReset">
                    <reload-outlined />
                    重置
                  </a-button>
                </a-space>
              </div>
              <div class="script-toolbar-right">
                <a-space>
                  <a-button type="primary" @click="handleCreateAudioPackage">
                    <plus-outlined />
                    新建录音包
                  </a-button>
                </a-space>
              </div>
            </div>

            <!-- 录音包列表表格 -->
            <div class="script-list">
              <div class="script-table-wrapper">
                <a-table
                  :columns="audioPackageColumns"
                  :data-source="audioPackageList"
                  :pagination="audioPackagePagination"
                  row-key="id"
                  size="middle"
                  @change="handleAudioPackageTableChange"
                >
                  <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'packageName'">
                      <span>{{ record.packageName }}</span>
                      <a-tag v-if="record.isDefault" color="blue" style="margin-left: 8px;">默认</a-tag>
                    </template>
                    <template v-if="column.key === 'recorder'">
                      <span>{{ record.recorder }}</span>
                    </template>
                    <template v-if="column.key === 'progress'">
                      <div class="progress-cell">
                        <a-progress :percent="record.progressPercent" :stroke-color="record.progressPercent === 100 ? '#52c41a' : '#1890ff'" :show-info="false" style="width: 100px;" />
                        <span class="progress-text">{{ record.progressPercent }}% ({{ record.completedCount }}/{{ record.totalCount }})</span>
                      </div>
                    </template>
                    <template v-if="column.key === 'uploadStatus'">
                      <a-tag :color="record.uploadStatus === '已完成' ? 'green' : 'default'">
                        {{ record.uploadStatus }}
                      </a-tag>
                    </template>
                    <template v-if="column.key === 'action'">
                      <a-space :size="8">
                        <a-button type="link" size="small" @click="handleViewAudioPackageDetail(record)">
                          详情
                        </a-button>
                        <a-button type="link" size="small" @click="handleEditAudioPackage(record)">
                          编辑
                        </a-button>
                        <a-button 
                          type="link" 
                          size="small" 
                          @click="handleSetDefaultAudioPackage(record)"
                          v-if="!record.isDefault"
                        >
                          设为默认
                        </a-button>
                        <a-popconfirm
                          title="确定删除该录音包？"
                          ok-text="确定"
                          cancel-text="取消"
                          @confirm="handleDeleteAudioPackage(record)"
                        >
                          <a-button 
                            type="link" 
                            size="small" 
                            danger
                            :disabled="audioPackageList.length === 1"
                          >
                            删除
                          </a-button>
                        </a-popconfirm>
                      </a-space>
                    </template>
                  </template>
                </a-table>
              </div>
            </div>
          </div>

          <!-- 录音详情页面 -->
          <div v-else class="audio-detail-list">
            <!-- 顶部操作区 -->
            <div class="script-toolbar-section">
              <div class="script-toolbar-left">
                <a-space>
                  <a-button @click="handleBackToAudioPackage">
                    <left-outlined />
                    返回录音包列表
                  </a-button>
                  <a-divider type="vertical" />
                  <span class="current-package-name">当前录音包：{{ currentAudioPackage?.packageName || '' }}</span>
                </a-space>
              </div>
              <div class="script-toolbar-right">
                <a-space>
                  <a-button @click="handleImportAudio">
                    <upload-outlined />
                    批量导入录音
                  </a-button>
                  <a-button @click="handleVoiceCheck">语音检测</a-button>
                </a-space>
              </div>
            </div>

            <!-- 录音列表表格 -->
            <div class="script-list">
              <div class="script-table-wrapper">
                <a-table
                  :columns="audioColumns"
                  :data-source="scriptList"
                  :pagination="false"
                  row-key="id"
                  size="middle"
                  :scroll="{ x: 1000 }"
                >
                  <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'uid'">
                      <span>{{ record.uid }}</span>
                    </template>
                    <template v-if="column.key === 'replyText'">
                      <span class="script-reply-text">{{ record.replyText }}</span>
                    </template>
                    <template v-if="column.key === 'recordFileName'">
                      <span>{{ record.recordFileName }}</span>
                    </template>
                    <template v-if="column.key === 'audio'">
                      <audio
                        v-if="record.audioUrl"
                        :src="record.audioUrl"
                        controls
                        style="height: 32px;"
                        @error="(e) => handleAudioError(e, record)"
                      >
                        您的浏览器不支持音频播放
                      </audio>
                      <span v-else style="color: #999;">暂无录音</span>
                    </template>
                    <template v-if="column.key === 'audioUploadStatus'">
                      <a-tag :color="record.audioUploadStatus === '已上传' ? 'green' : 'default'">
                        {{ record.audioUploadStatus || '未上传' }}
                      </a-tag>
                    </template>
                    <template v-if="column.key === 'action'">
                      <a-space :size="8">
                        <!-- <a-button type="link" size="small" @click="handleEditScript(record)">
                          <edit-outlined />
                          编辑
                        </a-button> -->
                        <a-button type="link" size="small" @click="triggerAudioFileSelect">
                          <upload-outlined />
                          上传录音
                        </a-button>
                      </a-space>
                    </template>
                  </template>
                </a-table>
              </div>
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
                  v-model:value="scriptSearchKeyword"
                  placeholder="请输入变量名搜索"
                  style="width: 200px"
                  @press-enter="handleScriptSearch"
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
            <div class="script-toolbar-right">
              <a-space>
                <a-button type="primary" @click="handleAddVariable">
                  <plus-outlined />
                  导入变量
                </a-button>
              </a-space>
            </div>
          </div>

          <!-- 变量列表表格 -->
          <div class="script-list">
            <div class="script-table-wrapper">
              <a-table
                :columns="variableColumns"
                :data-source="variableList"
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
                    <a-input
                      v-if="editingVariableId === record.id"
                      v-model:value="record.variableValue"
                      placeholder="请输入变量值，多个值用分号分隔"
                      style="width: 100%"
                      @press-enter="handleSaveVariableValue(record)"
                    />
                    <span v-else class="variable-value-text" @click="handleEditVariableValue(record)">
                      {{ record.variableValue || '-' }}
                    </span>
                  </template>
                  <template v-if="column.key === 'action'">
                    <a-space :size="8">
                      <a-button 
                        v-if="editingVariableId === record.id"
                        type="link" 
                        size="small" 
                        @click="handleSaveVariableValue(record)"
                      >
                        保存
                      </a-button>
                      <a-button 
                        v-else
                        type="link" 
                        size="small" 
                        @click="handleEditVariableValue(record)"
                      >
                        编辑
                      </a-button>
                    </a-space>
                  </template>
                </template>
              </a-table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 场景系统设置内容区域 -->
    <div v-else-if="activeTabKey === 'system-settings'" class="system-settings-content">
      <!-- 引导弹窗 -->
      <div v-if="guideVisible && guideSteps[guideCurrentStep]" class="guide-overlay">
        <div class="guide-popover">
          <div class="guide-header">
            <span class="guide-step-indicator">步骤 {{ guideSteps[guideCurrentStep].step }} / {{ guideSteps.length }}</span>
            <a-button type="text" size="small" class="guide-close-btn" @click="handleGuideClose">
              <close-outlined />
            </a-button>
          </div>
          <div class="guide-body">
            <h4 class="guide-title">{{ guideSteps[guideCurrentStep].title }}</h4>
            <p class="guide-description">{{ guideSteps[guideCurrentStep].description }}</p>
          </div>
          <div class="guide-footer" :class="{ 'guide-footer-first': guideCurrentStep === 0 }">
            <a-button
              v-if="guideCurrentStep > 0"
              size="small"
              @click="handleGuidePrev"
            >
              上一步
            </a-button>
            <a-button
              type="primary"
              size="small"
              @click="handleGuideNext"
              :style="{ marginLeft: guideCurrentStep === 0 ? 'auto' : '0' }"
            >
              {{ guideCurrentStep === guideSteps.length - 1 ? '完成引导' : '下一步' }}
            </a-button>
          </div>
          <!-- 引导步骤指示器 -->
          <div class="guide-steps-indicator">
            <div
              v-for="(step, index) in guideSteps"
              :key="step.step"
              :class="['step-dot', { active: guideCurrentStep === index }]"
              @click="handleGuideJump(index)"
            />
          </div>
        </div>
      </div>
      <div class="system-settings-wrapper">
        <!-- 客户跟进配置 -->
        <div class="settings-section">
          <div class="section-title">
            <div class="title-bar"></div>
            <span>客户跟进配置</span>
          </div>
          <div class="section-content">
            <a-form layout="vertical">
              <!-- 意向客户推送 -->
              <a-form-item label="意向客户推送：" class="required-label">
                <a-switch v-model:checked="systemSettingsForm.intentCustomerPush" />
                <div class="form-tip">机器人拨打电话后是否需要将意向客户推送给客户经理进行跟进，提高业务转化率</div>
              </a-form-item>

              <!-- 推送意向范围 -->
              <a-form-item label="推送意向范围：" v-if="systemSettingsForm.intentCustomerPush">
                <a-checkbox-group v-model:value="systemSettingsForm.pushIntentRange">
                  <a-checkbox value="有意向">有意向</a-checkbox>
                  <a-checkbox value="可能有意向">可能有意向</a-checkbox>
                  <a-checkbox value="无意向">无意向</a-checkbox>
                  <a-checkbox value="未接通">未接通</a-checkbox>
                </a-checkbox-group>
                <div class="form-tip">用户分类对将用户拨打的数据进行分发</div>
              </a-form-item>

              <!-- "意向率"包括 -->
              <a-form-item label='"意向率"包括：'>
                <a-checkbox-group v-model:value="systemSettingsForm.intentRateRange">
                  <a-checkbox value="有意向">有意向</a-checkbox>
                  <a-checkbox value="可能有意向">可能有意向</a-checkbox>
                  <a-checkbox value="无意向">无意向</a-checkbox>
                  <a-checkbox value="未接通">未接通</a-checkbox>
                </a-checkbox-group>
                <div class="form-tip">请勾选 系统统计 指标"有意向"包含哪些客户标签</div>
              </a-form-item>


           

              <!-- 当前场景跟进表单字段设置 -->
              <a-form-item label="当前场景跟进表单字段设置：">
                <div class="checkbox-grid">
                  <a-checkbox v-for="field in followUpFields" :key="field.value" v-model:checked="field.checked">
                    {{ field.label }}
                  </a-checkbox>
                </div>
                <div class="form-tip">客户跟进字段可以前往<a href="#" class="link-text">客户信息配置</a>中进行管理</div>
              </a-form-item>

      
            </a-form>
          </div>
        </div>

        <!-- 人机协同配置 -->
        <div class="settings-section">
          <div class="section-title">
            <div class="title-bar"></div>
            <span>人机协同配置</span>
          </div>
          <div class="section-content">
            <a-form layout="vertical">
              <!-- 人机协同模式 -->
              <a-form-item label="人机协同模式：">
                <a-switch v-model:checked="systemSettingsForm.humanMachineCollaboration" />
                <question-circle-outlined class="help-icon" />
                <span class="label-text" style="margin-left: 12px;">话术中是否配置转人工：<span :class="hasTransferScript ? 'success-text' : 'error-text'">{{ hasTransferScript ? '是' : '否' }}</span></span>
              </a-form-item>

              <!-- 协同方式 -->
              <a-form-item label="协同方式" class="required-label" v-if="systemSettingsForm.humanMachineCollaboration">
                <a-radio-group v-model:value="systemSettingsForm.collaborationMode">
                  <a-radio value="active-intervention">主动介入</a-radio>
                  <a-radio value="transfer">转人工</a-radio>
                  <a-radio value="both">主动介入 + 转人工</a-radio>
                </a-radio-group>
              </a-form-item>

              <!-- 转人工条件 -->
              <a-form-item label="转人工条件：" class="required-label" v-if="systemSettingsForm.humanMachineCollaboration">
                <a-radio-group v-model:value="systemSettingsForm.transferCondition">
                  <a-radio value="auto-transfer">接通自动转接</a-radio>
                  <a-radio value="after-intro">听完开场白自动转接</a-radio>
                  <a-radio value="trigger">触发话术/QA 转接</a-radio>
                </a-radio-group>
                <div class="form-tip" style="margin-top: 8px;">
                  <question-circle-outlined style="margin-right: 4px;" />
                  <question-circle-outlined style="margin-right: 4px;" />
                  <question-circle-outlined />
                </div>
                <div class="form-tip error-text" style="margin-top: 12px;">
                  注意：接通自动转接模式中话术/QA 中的转人工配置不生效
                </div>
              </a-form-item>

              <!-- 协同策略 -->
              <a-form-item label="协同策略：" class="required-label" v-if="systemSettingsForm.humanMachineCollaboration">
                <a-radio-group v-model:value="systemSettingsForm.collaborationStrategy">
                  <a-radio value="random-free">随机空闲转接</a-radio>
                  <a-radio value="distribution">按分发策略转接</a-radio>
                  <a-radio value="external-skill">转接给外部技能组</a-radio>
                </a-radio-group>
                <question-circle-outlined class="help-icon" style="margin-left: 8px;" v-for="i in 3" :key="i" />
              </a-form-item>
            </a-form>
          </div>
        </div>

        <!-- 底部按钮 -->
        <div class="form-footer">
          <a-button>
            <rollback-outlined />
            返回
          </a-button>
          <a-button type="primary">
            <save-outlined />
            保存
          </a-button>
          <span class="save-tip">保存成功后，5 分钟后生效</span>
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
            v-for="(category, index) in userCategories"
            :key="category.id"
            :class="['category-item', { active: selectedCategoryId === category.id }]"
            @click="handleSelectCategory(category.id)"
          >
            <span class="category-name">{{ category.name }}</span>
            <div class="category-item-right">
              <a-switch
                v-model:checked="category.enabled"
                size="small"
                @click.stop="handleToggleCategoryEnabled(category)"
                :checked-children="'启用'"
                :un-checked-children="'停用'"
              />
              <a-dropdown trigger="click">
                <a-button
                  type="text"
                  size="small"
                  class="more-action-btn"
                  @click.stop
                >
                  <ellipsis-outlined />
                </a-button>
                <template #overlay>
                  <a-menu>
                    <a-menu-item
                      key="edit"
                      @click.stop="handleEditCategory(category, index)"
                    >
                      <edit-outlined />
                      编辑
                    </a-menu-item>
                    <a-menu-item
                      v-if="index >= 3"
                      key="delete"
                      class="delete-menu-item"
                      @click.stop="handleDeleteCategory(category)"
                    >
                      <delete-outlined />
                      删除
                    </a-menu-item>
                  </a-menu>
                </template>
              </a-dropdown>
            </div>
          </div>
          <div class="add-category-btn" @click="handleAddCategory">
            <plus-outlined />
            添加分类
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
            <div class="save-btn-top-right">
              <a-button type="primary" @click="handleSaveClassify">
                <save-outlined />
                保存
              </a-button>
            </div>
          </div>

          <!-- 规则列表区域 -->
          <div class="rule-list-container">
            <!-- 暂无数据提示 -->
            <a-empty v-if="currentCategoryRules.length === 0 && editingRules.length === 0" description="暂无数据" />

            <!-- 已保存的规则列表 -->
            <div v-if="currentCategoryRules.length > 0" class="saved-rule-list">
              <div
                v-for="(rule, index) in currentCategoryRules"
                :key="rule.id"
                class="rule-item"
              >
                <div class="rule-header">
                  <span class="rule-index">表达式{{ index + 1 }}</span>
                  <a-popconfirm
                    title="确定删除该规则？"
                    ok-text="确定"
                    cancel-text="取消"
                    @confirm="handleDeleteRule(rule)"
                  >
                    <a-button type="text" class="delete-btn">
                      <delete-outlined />
                    </a-button>
                  </a-popconfirm>
                </div>
                <div class="rule-content">
                  <!-- 条件列表 -->
                  <div class="condition-display-list">
                    <div
                      v-for="(condition, cIndex) in rule.conditions"
                      :key="cIndex"
                      class="condition-display-item"
                    >
                      <span class="condition-field">{{ condition.fieldType }}</span>
                      <span class="condition-operator">{{ condition.operator }}</span>
                      <span class="condition-value">{{ condition.value }}</span>
                      <span v-if="cIndex < rule.conditions.length - 1" class="condition-connector">且</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 编辑中的规则列表 -->
            <div v-if="editingRules.length > 0" class="editing-rule-list">
              <div
                v-for="(rule, ruleIndex) in editingRules"
                :key="rule.id"
                class="rule-item-editing"
              >
                <div class="rule-header">
                  <span class="rule-index">表达式{{ ruleIndex + 1 }}</span>
                  <a-button
                    v-if="editingRules.length > 1"
                    type="text"
                    size="small"
                    class="delete-expression-btn"
                    @click="handleDeleteExpression(ruleIndex)"
                  >
                    <delete-outlined />
                    删除表达式
                  </a-button>
                </div>
                <div class="editing-expression-wrapper">
                  <!-- 条件列表 -->
                  <div class="condition-list">
                    <div
                      v-for="(condition, conditionIndex) in rule.conditions"
                      :key="condition.id"
                      class="condition-item"
                    >
                      <span class="condition-index">条件{{ conditionIndex + 1 }}:</span>
                      <a-select
                        v-model:value="condition.fieldType"
                        style="width: 140px"
                        placeholder="字段类型"
                      >
                        <a-select-option value="QA 标签">QA 标签</a-select-option>
                        <a-select-option value="意图">意图</a-select-option>
                        <a-select-option value="通话时长">通话时长</a-select-option>
                        <a-select-option value="静音次数">静音次数</a-select-option>
                      </a-select>
                      <a-select
                        v-model:value="condition.operator"
                        style="width: 110px"
                        placeholder="操作符"
                      >
                        <a-select-option value="包含">包含</a-select-option>
                        <a-select-option value="不包含">不包含</a-select-option>
                        <a-select-option value="等于">等于</a-select-option>
                        <a-select-option value="大于">大于</a-select-option>
                        <a-select-option value="小于">小于</a-select-option>
                      </a-select>
                      <a-input
                        v-model:value="condition.value"
                        style="width: 180px"
                        placeholder="请输入值"
                      />
                      <a-button
                        type="text"
                        size="small"
                        @click="handleAddCondition(ruleIndex)"
                        v-if="conditionIndex === rule.conditions.length - 1"
                        class="add-condition-btn"
                      >
                        <plus-circle-outlined />
                        添加条件
                      </a-button>
                      <a-button
                        type="text"
                        size="small"
                        @click="handleRemoveCondition(ruleIndex, conditionIndex)"
                        v-if="rule.conditions.length > 1"
                        class="remove-condition-btn"
                      >
                        <minus-circle-outlined />
                        删除
                      </a-button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 新增表达式按钮 -->
            <div class="add-rule-btn-wrapper">
              <a-button @click="handleAddExpression">
                <plus-outlined />
                新增表达式
              </a-button>
            </div>
          </div>
        </div>
      </div>

      <!-- 添加/编辑分类弹窗 -->
      <a-modal
        v-model:open="categoryModalVisible"
        :title="categoryModalTitle"
        width="500px"
        ok-text="确定"
        cancel-text="取消"
        @ok="handleCategoryModalOk"
        @cancel="handleCategoryModalCancel"
      >
        <a-form
          ref="categoryFormRef"
          :model="categoryForm"
          :rules="categoryFormRules"
          layout="vertical"
        >
          <a-form-item label="分类名称" name="name">
            <a-input
              v-model:value="categoryForm.name"
              :disabled="categoryForm.id > 0 && categoryForm.id <= 3"
              :placeholder="categoryForm.id > 0 && categoryForm.id <= 3 ? '默认分类，不可编辑' : '请输入分类名称'"
            />
          </a-form-item>
          <a-form-item label="分类优先级" name="priority">
            <a-input-number
              v-model:value="categoryForm.priority"
              style="width: 100%"
              :min="1"
              :max="999"
              placeholder="请输入优先级数字，数字越小优先级越高"
            />
          </a-form-item>
          <a-form-item label="是否默认分类" name="isDefault">
            <a-switch
              v-model:checked="categoryForm.isDefault"
              checked-children="是"
              un-checked-children="否"
            />
          </a-form-item>
        </a-form>
      </a-modal>
    </div>

    <!-- 主流程设置内容区域 -->
    <div v-else-if="activeTabKey === 'process'" class="process-content">
      <div class="process-wrapper">
        <!-- 流程图画布 -->
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

          <!-- 节点添加栏（固定在画布区域顶部） -->
          <div class="node-palette">
            <!-- <div class="palette-header">
              <span>节点工具箱</span>
            </div> -->
            <div class="palette-content">
              <div
                v-for="nodeType in nodeTypes"
                :key="nodeType.type"
                class="palette-node-item"
                draggable="true"
                @dragstart="handlePaletteNodeDragStart($event, nodeType)"
              >
                <component :is="nodeType.icon" />
                <span>{{ nodeType.label }}</span>
              </div>
            </div>
          </div>

          <!-- 画布区域 -->
          <div
            ref="canvasRef"
            class="process-canvas"
            @click="handleCanvasClick"
            @dragover="handleCanvasDragOver"
            @drop="handleCanvasDrop"
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
                  <!-- 意图标签（流程线上展示勾选的意图名称） -->
                  <foreignObject
                    v-if="connection.intents && connection.intents.length > 0"
                    :x="getConnectionMidpoint(connection).x - 50"
                    :y="getConnectionMidpoint(connection).y - 20"
                    width="100"
                    height="40"
                    class="connection-intent-label"
                  >
                    <div class="intent-tags">
                      <a-tag
                        v-for="intent in connection.intents"
                        :key="intent.id"
                        size="small"
                        color="blue"
                      >
                        {{ intent.intentName }}
                      </a-tag>
                    </div>
                  </foreignObject>
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
                      v-if="node.type !== 'start'"
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

    <!-- 场景短信内容区域 -->
    <div v-else-if="activeTabKey === 'sms'" class="sms-content">
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
          <div class="sms-toolbar-right">
            <a-space>
              <a-button type="primary" @click="handleImportSmsTemplate">
                <upload-outlined />
                导入模版
              </a-button>
              <a-button type="primary" @click="handleCreateSms">
                <plus-outlined />
                新增短信
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
                <template v-if="column.key === 'action'">
                  <a-space :size="8">
                    <a-button type="link" size="small" @click="handleEditSms(record)">
                      <edit-outlined />
                      编辑
                    </a-button>
                    <a-popconfirm
                      title="确定删除该短信？"
                      ok-text="确定"
                      cancel-text="取消"
                      @confirm="handleDeleteSms(record)"
                    >
                      <a-button type="link" size="small" danger>
                        <delete-outlined />
                        删除
                      </a-button>
                    </a-popconfirm>
                  </a-space>
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

    <!-- 其他标签页内容占位 -->
    <div v-else class="other-tab-placeholder">
      <a-empty :description="`这里是${getTabName(activeTabKey)}内容`" />
    </div>

    <!-- 节点编辑弹窗 -->
    <a-modal
      v-model:open="nodeEditModalVisible"
      :title="getNodeEditModalTitle(editingNode?.type)"
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

        <a-form-item 
          v-if="editingNode?.type && editingNode.type !== 'start'" 
          label="话术内容" 
          name="text"
        >
          <a-textarea
            v-model:value="nodeEditForm.text"
            :placeholder="getNodeEditPlaceholder(editingNode?.type)"
            :rows="6"
          />
          <a class="ai-generate-btn" style="margin-top: 8px; display: inline-flex;" @click="handleAiGenerateNodeContent">
            <thunderbolt-outlined />
            AI 生成
          </a>
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
      width="600px"
      :footer="null"
      @cancel="handleConnectionEditCancel"
    >
      <a-form
        ref="connectionEditFormRef"
        :model="connectionEditForm"
        layout="vertical"
      >
        <a-form-item label="流转条件（勾选意图）">
          <div class="intent-select-list">
            <a-checkbox
              v-for="intent in intentList"
              :key="intent.id"
              :checked="isIntentSelected(intent.id)"
              @change="handleIntentCheckboxChange($event, intent)"
            >
              <a-tag :color="getIntentTypeColor(intent.intentType)">
                {{ intent.intentName }}
              </a-tag>
            </a-checkbox>
          </div>
          <div class="form-tip" style="margin-top: 8px;">
            勾选的意图将作为流转条件，当识别到这些意图时，流程将沿着此连接线继续
          </div>
        </a-form-item>
        <a-form-item label="已选意图">
          <div class="selected-intent-tags">
            <a-tag
              v-for="intent in connectionEditForm.selectedIntents"
              :key="intent.id"
              color="blue"
              closable
              @close="handleRemoveIntent(intent)"
            >
              {{ intent.intentName }}
            </a-tag>
            <span v-if="connectionEditForm.selectedIntents.length === 0" style="color: #999;">暂无已选意图</span>
          </div>
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
                  <thunderbolt-outlined />
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
              <thunderbolt-outlined />
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
              <thunderbolt-outlined />
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
            <span class="total-text">共 {{ referenceTotal }} 条</span>
            <a-checkbox v-model:checked="referenceSelectAll" @change="onReferenceSelectAll">全选</a-checkbox>
            <a-pagination
              v-model:current="referenceCurrent"
              v-model:page-size="referencePageSize"
              :total="referenceTotal"
              show-size-changer
              show-quick-jumper
              :show-total="(total: number) => `共 ${total} 条`"
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

    <!-- 新建录音包弹窗 -->
    <a-modal
      v-model:open="createAudioPackageModalVisible"
      title="新建录音包"
      width="500px"
      :footer="null"
      @cancel="handleCreateAudioPackageCancel"
    >
      <a-form
        ref="createAudioPackageFormRef"
        :model="createAudioPackageForm"
        :rules="createAudioPackageRules"
        layout="vertical"
      >
        <a-form-item label="录音包名称" name="packageName">
          <a-input
            v-model:value="createAudioPackageForm.packageName"
            placeholder="请输入录音包名称"
          />
        </a-form-item>
        <a-form-item label="录音师" name="recorder">
          <a-input
            v-model:value="createAudioPackageForm.recorder"
            placeholder="请输入录音师姓名"
          />
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleCreateAudioPackageCancel">取消</a-button>
        <a-button type="primary" @click="handleCreateAudioPackageSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 编辑录音包弹窗 -->
    <a-modal
      v-model:open="editAudioPackageModalVisible"
      title="编辑录音包"
      width="500px"
      :footer="null"
      @cancel="handleEditAudioPackageCancel"
    >
      <a-form
        ref="editAudioPackageFormRef"
        :model="editAudioPackageForm"
        :rules="editAudioPackageRules"
        layout="vertical"
      >
        <a-form-item label="录音包名称" name="packageName">
          <a-input
            v-model:value="editAudioPackageForm.packageName"
            placeholder="请输入录音包名称"
          />
        </a-form-item>
        <a-form-item label="录音师" name="recorder">
          <a-input
            v-model:value="editAudioPackageForm.recorder"
            placeholder="请输入录音师姓名"
          />
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleEditAudioPackageCancel">取消</a-button>
        <a-button type="primary" @click="handleEditAudioPackageSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 添加用户问法弹窗 -->
    <a-modal
      v-model:open="addUserQuestionModalVisible"
      title="添加用户问法"
      width="1000px"
      :footer="null"
      @cancel="handleAddUserQuestionCancel"
    >
      <div class="add-user-question-container">
        <!-- TAB 切换 -->
        <a-tabs v-model:activeKey="userQuestionActiveTab">
          <a-tab-pane key="pattern" tab="pattern 语料">
            <!-- pattern 语料操作区 -->
            <div class="pattern-toolbar">
              <div class="toolbar-left">
                <a-space>
                  <a-input
                    v-model:value="patternSearchKeyword"
                    placeholder="关键词查询"
                    class="search-input"
                    allow-clear
                    @press-enter="handlePatternSearch"
                  >
                    <template #suffix>
                      <search-outlined style="cursor: pointer" />
                    </template>
                  </a-input>
                  <a-button type="primary" size="small" @click="handlePatternSearch">
                    <search-outlined />
                    搜索
                  </a-button>
                </a-space>
              </div>
              <div class="toolbar-right">
                <a-space>
                  <a-button size="small" @click="handleOpenAddPatternModal">
                    <plus-outlined />
                    新增语料
                  </a-button>
                  <a-button danger size="small" @click="handleBatchDeletePattern">
                    批量删除
                  </a-button>
                  <a-button size="small" @click="handleSemanticTest">
                    语义测试
                  </a-button>
                </a-space>
              </div>
            </div>

            <!-- pattern 语料表格 -->
            <div class="pattern-table-wrapper">
              <a-table
                :columns="patternColumns"
                :data-source="patternList"
                :pagination="patternPagination"
                row-key="id"
                size="small"
                :row-selection="{ selectedRowKeys: selectedPatternRowKeys, onChange: onPatternSelectChange }"
                @change="handlePatternTableChange"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'patternText'">
                    <div v-if="editingPatternId === record.id" class="pattern-edit-wrapper">
                      <a-input
                        ref="editInputRef"
                        v-model:value="record.patternText"
                        style="width: 100%"
                        @press-enter="handleSavePatternEdit(record)"
                        @blur="handleSavePatternEdit(record)"
                      />
                    </div>
                    <span
                      v-else
                      class="pattern-text"
                      @click="handleEditPattern(record)"
                    >
                      {{ record.patternText }}
                    </span>
                  </template>
                  <template v-if="column.key === 'action'">
                    <a-button
                      type="text"
                      size="small"
                      danger
                      @click="handleDeletePattern(record)"
                    >
                      <delete-outlined />
                    </a-button>
                  </template>
                </template>
              </a-table>
            </div>
          </a-tab-pane>

          <a-tab-pane key="semantic" tab="语义槽">
            <!-- 语义槽表格 -->
            <div class="semantic-slot-table-wrapper">
              <a-table
                :columns="semanticSlotColumns"
                :data-source="semanticSlotList"
                :pagination="semanticSlotPagination"
                row-key="id"
                size="small"
                @change="handleSemanticSlotTableChange"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'slotName'">
                    <span class="slot-name" :style="{ borderBottom: `2px solid ${record.color}` }">{{ record.slotName }}</span>
                  </template>
                  <template v-if="column.key === 'bindDict'">
                    <a-tag color="blue">{{ record.bindDict }}</a-tag>
                  </template>
                  <template v-if="column.key === 'action'">
                    <a-button
                      type="text"
                      size="small"
                      danger
                      @click="handleDeleteSemanticSlot(record)"
                    >
                      <delete-outlined />
                    </a-button>
                  </template>
                </template>
              </a-table>
            </div>
          </a-tab-pane>
        </a-tabs>

        <!-- 底部保存按钮 -->
        <div class="modal-footer" style="justify-content: flex-end; border-top: none; padding-top: 16px;">
          <a-button @click="handleAddUserQuestionCancel">取消</a-button>
          <a-button type="primary" @click="handleSaveUserQuestion">保存</a-button>
        </div>
      </div>
    </a-modal>

    <!-- 新增语料弹窗 -->
    <a-modal
      v-model:open="addPatternModalVisible"
      title="新增语料"
      width="600px"
      :footer="null"
      @cancel="handleAddPatternModalCancel"
    >
      <a-form
        ref="addPatternFormRef"
        :model="addPatternForm"
        :rules="addPatternRules"
        layout="vertical"
      >
        <a-form-item label="语料内容" name="patternText">
          <a-textarea
            v-model:value="addPatternForm.patternText"
            placeholder="请输入语料内容，支持批量输入，每行一条"
            :rows="8"
          />
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleAddPatternModalCancel">取消</a-button>
        <a-button @click="handleReportPattern">上报语料并保存</a-button>
        <a-button type="primary" @click="handleAddPatternSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 上报语料确认弹窗 -->
    <a-modal
      v-model:open="reportPatternConfirmVisible"
      title="上报语料确认"
      width="500px"
      :footer="null"
      @cancel="handleReportPatternCancel"
    >
      <div class="report-pattern-confirm-content">
        <a-alert
          message="上报语料将进入异常看板，摸象公司定期分析并用于优化通用/行业 QA 模型。请确保语料准确无误。"
          type="warning"
          show-icon
        />
      </div>
      <div class="modal-footer">
        <a-button @click="handleReportPatternCancel">取消</a-button>
        <a-button type="primary" @click="handleReportPatternConfirm">确认</a-button>
      </div>
    </a-modal>

    <!-- 编辑话术弹窗 -->
    <a-modal
      v-model:open="editScriptModalVisible"
      title="编辑话术"
      width="700px"
      :footer="null"
      @cancel="handleEditScriptCancel"
    >
      <a-form
        ref="editScriptFormRef"
        :model="editScriptForm"
        :rules="editScriptRules"
        layout="vertical"
      >
        <a-form-item label="话术文本" name="replyText">
          <a-textarea
            v-model:value="editScriptForm.replyText"
            placeholder="请输入话术文本"
            :rows="6"
          />
        </a-form-item>
        <a-form-item label="录音上传">
          <a-button @click="triggerAudioFileSelect" :loading="audioUploading">
            <upload-outlined />
            {{ editScriptForm.audioUrl ? '重新上传录音' : '上传录音' }}
          </a-button>
          <input
            ref="audioFileInputRef"
            type="file"
            accept="audio/*"
            @change="handleAudioFileChange"
            style="display: none;"
          />
          <div v-if="editScriptForm.audioUrl" style="margin-top: 12px;">
            <audio :src="editScriptForm.audioUrl" controls style="width: 100%;" />
          </div>
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleEditScriptCancel">取消</a-button>
        <a-button type="primary" @click="handleEditScriptSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 编辑短信弹窗 -->
    <a-modal
      v-model:open="editSmsModalVisible"
      title="编辑短信"
      width="600px"
      :footer="null"
      @cancel="handleEditSmsCancel"
    >
      <a-form
        ref="editSmsFormRef"
        :model="editSmsForm"
        :rules="editSmsRules"
        layout="vertical"
      >
        <a-form-item label="短信名称" name="smsName">
          <a-input
            v-model:value="editSmsForm.smsName"
            placeholder="请输入短信名称"
          />
        </a-form-item>
        <a-form-item label="短信 CODE" name="smsCode">
          <a-input
            v-model:value="editSmsForm.smsCode"
            placeholder="请输入短信 CODE"
          />
        </a-form-item>
        <a-form-item label="短信内容" name="smsContent">
          <a-textarea
            v-model:value="editSmsForm.smsContent"
            placeholder="请输入短信内容"
            :rows="6"
          />
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleEditSmsCancel">取消</a-button>
        <a-button type="primary" @click="handleEditSmsSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 遮罩层 -->
    <div v-if="guideVisible" class="guide-mask">
      <div 
        class="guide-highlight"
        :style="{
          top: highlightRect.top + 'px',
          left: highlightRect.left + 'px',
          width: highlightRect.width + 'px',
          height: highlightRect.height + 'px',
        }"
      />
    </div>

    <!-- 气泡引导 -->
    <div v-if="guideVisible && guideSteps[guideCurrentStep]" class="guide-overlay" :class="{ 'guide-with-transition': enableGuideTransition }" :style="{ top: guidePosition.top + 'px', left: guidePosition.left + 'px' }">
      <div class="guide-popover">
        <div class="guide-header">
          <span class="guide-step-indicator">步骤 {{ guideSteps[guideCurrentStep].step }} / {{ guideSteps.length }}</span>
          <a-button type="text" size="small" class="guide-close-btn" @click="handleGuideClose">
            <close-outlined />
          </a-button>
        </div>
        <div class="guide-body">
          <h4 class="guide-title">{{ guideSteps[guideCurrentStep].title }}</h4>
          <p class="guide-description">{{ guideSteps[guideCurrentStep].description }}</p>
        </div>
        <div class="guide-footer" :class="{ 'guide-footer-first': guideCurrentStep === 0 }">
          <a-button
            v-if="guideCurrentStep > 0"
            size="small"
            @click="handleGuidePrev"
          >
            上一步
          </a-button>
          <a-button
            type="primary"
            size="small"
            @click="handleGuideNext"
            :style="{ marginLeft: guideCurrentStep === 0 ? 'auto' : '0' }"
          >
            {{ guideCurrentStep === guideSteps.length - 1 ? '完成引导' : '下一步' }}
          </a-button>
        </div>
        <!-- 引导步骤指示器 -->
        <div class="guide-steps-indicator">
          <div
            v-for="(step, index) in guideSteps"
            :key="step.step"
            :class="['step-dot', { active: guideCurrentStep === index }]"
            @click="handleGuideJump(index)"
          />
        </div>
      </div>
    </div>

    <!-- 重新引导按钮（右下角） -->
    <a-button
      class="restart-guide-btn"
      type="primary"
      shape="circle"
      size="large"
      @click="showGuide"
    >
      <question-outlined />
    </a-button>

    <!-- QA 库新手引导弹窗 -->
    <QaGuideModal
      :visible="qaGuideVisible"
      :steps="qaGuideSteps"
      @close="handleQaGuideClose"
      @finish="handleQaGuideFinish"
    />

  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, nextTick, watch } from 'vue';
import type { FormInstance, Rule } from 'ant-design-vue/es/form';
import { message, Modal } from 'ant-design-vue';
import {
  SearchOutlined,
  PlusOutlined,
  LinkOutlined,
  WarningOutlined,
  DeleteOutlined,
  EditOutlined,
  SaveOutlined,
  RollbackOutlined,
  QuestionCircleOutlined,
  ReloadOutlined,
  UpOutlined,
  DownOutlined,
  CloseOutlined,
  ZoomInOutlined,
  ZoomOutOutlined,
  FullscreenOutlined,
  LayoutOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  PlayCircleOutlined,
  MessageOutlined,
  ThunderboltOutlined,
  UploadOutlined,
  CustomerServiceOutlined,
  SafetyCertificateOutlined,
  EllipsisOutlined,
  QuestionOutlined,
  LeftOutlined,
} from '@ant-design/icons-vue';
import QaGuideModal from '../components/QaGuideModal.vue';

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
type NodeType = 'start' | 'script' | 'success_end' | 'fail_end' | 'transfer' | 'verify';

// 意图项接口
interface IntentItem {
  id: number;
  intentName: string;
  intentType: string;
}

// 流程节点
interface ProcessNode {
  id: number;
  type: NodeType;
  name: string;
  x: number;
  y: number;
  content?: {
    text?: string;        // 话术节点的内容
  };
}

// 连接线
interface Connection {
  id: number;
  sourceNodeId: number;
  targetNodeId: number;
  intents?: IntentItem[]; // 流转条件：勾选的意图列表
  label?: string;         // 连接线标签
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
  { type: 'script', label: '通用节点', icon: MessageOutlined },
  { type: 'success_end', label: '成功结束', icon: CheckCircleOutlined },
  { type: 'fail_end', label: '失败结束', icon: CloseCircleOutlined },
  { type: 'transfer', label: '转人工坐席', icon: CustomerServiceOutlined },
  { type: 'verify', label: '验证信息', icon: SafetyCertificateOutlined },
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
    type: 'script',
    name: '介绍产品',
    x: 300,
    y: 320,
    content: {
      text: '太好了！我们银行最近推出了一款高收益的理财产品，年化收益率最高可达 4.5%，您有兴趣了解一下吗？',
    },
  },
  {
    id: 4,
    type: 'success_end',
    name: '成功结束',
    x: 300,
    y: 450,
  },
]);

// 连接线数据（模拟数据）
const connections = ref<Connection[]>([
  { id: 1, sourceNodeId: 1, targetNodeId: 2 },
  { id: 2, sourceNodeId: 2, targetNodeId: 3 },
  { id: 3, sourceNodeId: 3, targetNodeId: 4 },
]);

// 画布缩放
const canvasZoom = ref(100);

// 画布尺寸
const canvasSize = reactive({
  width: 2000,
  height: 1500,
});

// 工具箱位置（可拖拽）
const toolboxPosition = reactive({
  x: 20,
  y: 20,
});
const isDraggingToolbox = ref(false);
const toolboxDragOffset = reactive({ x: 0, y: 0 });
const toolboxVisible = ref(true);

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
});

const nodeEditRules: Record<string, Rule[]> = {
  name: [{ required: true, message: '请输入节点名称', trigger: 'blur' }],
};

// 连接线编辑表单
const connectionEditModalVisible = ref(false);
const connectionEditFormRef = ref<FormInstance>();
const connectionEditForm = reactive({
  selectedIntents: [] as IntentItem[],
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
  showTotal: (total: number) => `共 ${total} 条`,
  pageSizeOptions: ['10', '20', '50'],
  locale: {
    items_per_page: '条/页',
    jump_to: '跳转至',
    page: '页',
  },
});

// 意图列表数据（模拟数据）
const intentList = ref<IntentItem[]>([
  { id: 1, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 2, intentName: 'sys.肯定', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 3, intentName: 'sys.确认', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 4, intentName: 'sys.否定', intentType: '否定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 5, intentName: 'sys.中性 - 继续', intentType: '中性', priority: 1, updateTime: '2025-12-15 16:52:11' },
  
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

// ==================== 话术管理相关数据 ====================

// 话术管理接口
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

// 话术搜索关键词
const scriptSearchKeyword = ref('');

// 话术筛选条件
const scriptComplianceFilter = ref<string | undefined>(undefined);
const scriptAudioStatusFilter = ref<string | undefined>(undefined);

// 话术管理子 tab
const scriptSubTabKey = ref('compliance');

// 录音包列表数据（模拟数据）
const audioPackageList = ref([
  { id: 1, packageName: '默认录音', recorder: '录音师 XXX', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: true },
  { id: 2, packageName: '坐席 1 线下录音', recorder: '坐席 1', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: false },
  { id: 3, packageName: '坐席 1 声音复刻生成录音', recorder: '坐席 1', progressPercent: 100, completedCount: 100, totalCount: 200, uploadStatus: '已完成', isDefault: false },
  { id: 4, packageName: '坐席 2 声音复刻生成录音', recorder: '坐席 2', progressPercent: 0, completedCount: 0, totalCount: 200, uploadStatus: '未完成', isDefault: false },
  { id: 5, packageName: '坐席 3 声音复刻生成录音', recorder: '坐席 3', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: false },
  { id: 6, packageName: '坐席 4 声音复刻生成录音', recorder: '坐席 4', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: false },
  { id: 7, packageName: '坐席 5 声音复刻生成录音', recorder: '坐席 5', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: false },
]);

// 录音包分页
const audioPackagePagination = reactive({
  current: 1,
  pageSize: 10,
  total: 7,
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

// 录音包搜索关键词
const audioPackageSearchKeyword = ref('');

// 当前选中的录音包
const currentAudioPackage = ref<any>(null);

// 是否显示录音详情列表
const showAudioDetail = ref(false);

// 当前正在编辑的变量 ID
const editingVariableId = ref<number | null>(null);

// 新建录音包弹窗
const createAudioPackageModalVisible = ref(false);
const createAudioPackageFormRef = ref<FormInstance>();
const createAudioPackageForm = reactive({
  packageName: '',
  recorder: '',
});

const createAudioPackageRules: Record<string, Rule[]> = {
  packageName: [{ required: true, message: '请输入录音包名称', trigger: 'blur' }],
  recorder: [{ required: true, message: '请输入录音师姓名', trigger: 'blur' }],
};

// 编辑录音包弹窗
const editAudioPackageModalVisible = ref(false);
const editAudioPackageFormRef = ref<FormInstance>();
const editAudioPackageForm = reactive({
  id: 0,
  packageName: '',
  recorder: '',
});

const editAudioPackageRules: Record<string, Rule[]> = {
  packageName: [{ required: true, message: '请输入录音包名称', trigger: 'blur' }],
  recorder: [{ required: true, message: '请输入录音师姓名', trigger: 'blur' }],
};

// 变量列表数据（模拟数据）
const variableList = ref([
  { id: 1, variableName: 'customerName', variableValue: '张先生' },
  { id: 2, variableName: 'cardNo', variableValue: '****1234' },
  { id: 3, variableName: 'loanAmount', variableValue: '50 万' },
  { id: 4, variableName: 'points', variableValue: '10000' },
  { id: 5, variableName: 'productRate', variableValue: '4.5%' },
]);

// 话术列表数据（模拟数据）
const scriptList = ref<ScriptItem[]>([
  {
    id: 1,
    uid: 1,
    replyText: '您好，您建行卡内有小额定期存款可以转出，请登录中国建设银行 APP 点击转账进入定活互转然后点击定期转活期，即可操作，祝您生活愉快，再见！',
    variableValue: '',
    recordFileName: 'nlg_2',
    audioUrl: '',
    complianceStatus: '未消保',
    audioUploadStatus: '未上传',
    source: '主流程',
  },
  {
    id: 2,
    uid: 2,
    replyText: '尊敬的客户您好，这里是建行客服中心，关于您之前咨询的理财产品，我们最近有新活动，年化收益率最高可达 4.5%，有兴趣了解一下吗？',
    variableValue: '{customerName: 张先生}',
    recordFileName: 'nlg_3',
    audioUrl: '/audio/nlg_3.mp3',
    complianceStatus: '消保通过',
    audioUploadStatus: '已上传',
    source: 'QA.你是哪个银行',
  },
  {
    id: 3,
    uid: 3,
    replyText: '您好，这里是建行信用卡中心，检测到您的信用卡账单已逾期，请尽快还款，否则将影响您的个人征信记录。',
    variableValue: '{cardNo: ****1234}',
    recordFileName: 'nlg_4',
    audioUrl: '/audio/nlg_4.mp3',
    complianceStatus: '消保不通过',
    audioUploadStatus: '已上传',
    source: 'QA.信用卡逾期怎么办',
  },
  {
    id: 4,
    uid: 4,
    replyText: '尊敬的客户，感谢您使用建行服务，您的贷款申请已审批通过，请携带有效身份证件到就近网点办理签约手续。',
    variableValue: '{loanAmount: 50 万}',
    recordFileName: 'nlg_5',
    audioUrl: '',
    complianceStatus: '消保通过',
    audioUploadStatus: '未上传',
    source: '主流程',
  },
  {
    id: 5,
    uid: 5,
    replyText: '您好，建行提醒您，您的信用卡积分即将到期，请尽快登录建行手机银行兑换精美礼品，过期将自动清零。',
    variableValue: '{points: 10000}',
    recordFileName: 'nlg_6',
    audioUrl: '/audio/nlg_6.mp3',
    complianceStatus: '未消保',
    audioUploadStatus: '已上传',
    source: 'QA.积分兑换',
  },
]);

// 话术分页
const scriptPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 5,
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

// 选中的话术行
const selectedScriptRowKeys = ref<number[]>([]);

// 话术总数
const scriptTotal = ref(5);

// 编辑话术弹窗
const editScriptModalVisible = ref(false);
const editScriptFormRef = ref<FormInstance>();
const editScriptForm = reactive({
  id: 0,
  replyText: '',
  audioUrl: '',
});
const currentEditScript = ref<ScriptItem | null>(null);

// 录音上传相关
const audioUploading = ref(false);
const selectedAudioFile = ref<File | null>(null);
const audioFileInputRef = ref<HTMLInputElement | null>(null);

const editScriptRules: Record<string, Rule[]> = {
  replyText: [{ required: true, message: '请输入话术文本', trigger: 'blur' }],
};

// 话术表格列配置
const scriptColumns = [
  {
    title: 'uid',
    dataIndex: 'uid',
    key: 'uid',
    width: 70,
    fixed: 'left' as const,
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
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right' as const,
  },
];

// 录音表格列配置
const audioColumns = [
  {
    title: 'uid',
    dataIndex: 'uid',
    key: 'uid',
    width: 70,
    fixed: 'left' as const,
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
    width: 300,
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right' as const,
  },
];

// 录音包表格列配置
const audioPackageColumns = [
  {
    title: '录音包名称',
    dataIndex: 'packageName',
    key: 'packageName',
    width: 200,
  },
  {
    title: '录音师',
    dataIndex: 'recorder',
    key: 'recorder',
    width: 150,
  },
  {
    title: '录音进度',
    dataIndex: 'progress',
    key: 'progress',
    width: 250,
  },
  {
    title: '录音上传状态',
    dataIndex: 'uploadStatus',
    key: 'uploadStatus',
    width: 120,
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right' as const,
  },
];

// 变量表格列配置
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
  {
    title: '操作',
    key: 'action',
    width: 120,
    fixed: 'right' as const,
  },
];

// ==================== 场景短信相关数据 ====================

// 短信接口
interface SmsItem {
  id: number;
  smsName: string;
  smsCode: string;
  smsContent: string;
  modifyTime: string;
}

// 短信模版名称筛选
const smsTemplateNameFilter = ref('');

// 短信内容筛选
const smsContentFilter = ref('');

// 短信列表数据（模拟数据）
const smsList = ref<SmsItem[]>([
  {
    id: 125,
    smsName: '挂机短信',
    smsCode: 'SMS122123',
    smsContent: '这是挂机短信',
    modifyTime: '2026-03-11 16:22:37',
  },
]);

// 短信分页
const smsPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 1,
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
const smsTotal = ref(1);

// 编辑短信弹窗
const editSmsModalVisible = ref(false);
const editSmsFormRef = ref<FormInstance>();
const editSmsForm = reactive({
  id: 0,
  smsName: '',
  smsCode: '',
  smsContent: '',
});

const editSmsRules: Record<string, Rule[]> = {
  smsName: [{ required: true, message: '请输入短信名称', trigger: 'blur' }],
  smsCode: [{ required: true, message: '请输入短信 CODE', trigger: 'blur' }],
  smsContent: [{ required: true, message: '请输入短信内容', trigger: 'blur' }],
};

// 短信表格列配置
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
  {
    title: '操作',
    key: 'action',
    width: 120,
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

// ==================== 场景系统设置相关数据 ====================

// 跟进表单字段接口
interface FollowUpField {
  value: string;
  label: string;
  checked: boolean;
}

// 场景系统设置表单数据
const systemSettingsForm = reactive({
  // 客户跟进配置
  intentCustomerPush: true, // 意向客户推送
  pushIntentRange: ['有意向', '可能有意向'] as string[], // 推送意向范围
  intentRateRange: ['有意向', '可能有意向'] as string[], // "意向率"包括
  agentDistributionLimit: false, // 坐席分发限制
  qualityCheckDelay: false, // 质检延迟下发
  distributeTo: 'org-agent' as 'selected-agent' | 'skill-group' | 'org-agent', // 分发给
  distributionRule: '归属-org' as '归属-direct' | '归属-org' | 'average', // 分发规则
  fallbackRule: false, // 兜底规则
  smsReminder: false, // 跟进短信提醒
  
  // 人机协同配置
  humanMachineCollaboration: true, // 人机协同模式
  collaborationMode: 'transfer' as 'active-intervention' | 'transfer' | 'both', // 协同方式
  transferCondition: 'auto-transfer' as 'auto-transfer' | 'after-intro' | 'trigger', // 转人工条件
  collaborationStrategy: 'random-free' as 'random-free' | 'distribution' | 'external-skill', // 协同策略
});

// 跟进表单字段列表
const followUpFields = ref<FollowUpField[]>([
  { value: 'follow-note', label: '跟进备注', checked: false },
  { value: 'add-wechat', label: '是否成功添加企微', checked: false },
  { value: 'wechat-name', label: '微信名', checked: false },
  { value: 'follow-continue', label: '客户跟进 - 持续跟进', checked: false },
  { value: 'willing-transfer', label: '是否愿意调户', checked: false },
  { value: 'appoint-date', label: '预约日期', checked: false },
  { value: 'connect-status', label: '接通状态', checked: false },
  { value: 'online-handled', label: '已线上办理', checked: false },
  { value: 'has-balance', label: '活期是否有余额', checked: false },
  { value: 'huaxia-product', label: '华夏是否购买过产品', checked: false },
  { value: 'request-follow', label: '要求再次跟进', checked: false },
  { value: 'request-sms', label: '要求发送短信', checked: false },
  { value: 'other-channel-time', label: '其他渠道资金到账时间', checked: false },
  { value: 'other-channel-amount', label: '其他渠道资金到账金额', checked: false },
  { value: 'add-enterprise', label: '添加企微', checked: false },
  { value: 'has-money-no-trust', label: '有资金但不信任', checked: false },
  { value: 'other-business', label: '其他业务需求', checked: false },
  { value: 'go-branch', label: '去网点处理非外呼业务', checked: false },
  { value: 'visit-time', label: '到访时间', checked: false },
  { value: 'demand', label: '需求', checked: false },
  { value: 'wechat-status', label: '加微情况', checked: false },
  { value: 'card-intent', label: '办卡意向', checked: false },
  { value: 'handle-method', label: '办理方式', checked: false },
  { value: 'deal-amount', label: '成交金额', checked: false },
  { value: 'come-branch', label: '来网点', checked: false },
  { value: 'customer归属', label: '客户归属情况', checked: false },
]);

// 计算属性：是否有转人工话术
const hasTransferScript = computed(() => {
  // TODO: 检查话术中是否配置了转人工
  return false;
});

// ==================== 气泡引导相关数据 ====================

// 引导步骤接口
interface GuideStep {
  step: number;
  title: string;
  description: string;
  target: string; // CSS 选择器
  placement: 'top' | 'bottom' | 'left' | 'right';
}

// 引导步骤配置
const guideSteps: GuideStep[] = [
  {
    step: 1,
    title: '配置话术主流程',
    description: '点击"主流程设置"标签，配置机器人拨打的话术流程，包括开场白、产品介绍、成功/失败结束等节点。',
    target: '[data-tab-key="process"]',
    placement: 'bottom',
  },
  {
    step: 2,
    title: '引用通用/行业 QA',
    description: '点击"QA 库"标签，引用通用或行业 QA，并编辑回复内容，丰富机器人的应答能力。',
    target: '[data-tab-key="qa"]',
    placement: 'bottom',
  },
  {
    step: 3,
    title: '维护意图库',
    description: '点击"意图库"标签，添加或编辑意图，定义用户可能的意图和对应的处理方式。',
    target: '[data-tab-key="intent"]',
    placement: 'bottom',
  },
  {
    step: 4,
    title: '检查兜底设置',
    description: '点击"流程兜底设置"标签，检查静音超时、语义为空、强制挂断等配置项是否完整。',
    target: '[data-tab-key="fallback"]',
    placement: 'bottom',
  },
  {
    step: 5,
    title: '消保审核和上传录音',
    description: '点击"话术管理"标签，对所有话术文本进行消保审核，并上传录音文件。',
    target: '[data-tab-key="script"]',
    placement: 'bottom',
  },
  {
    step: 6,
    title: '定义用户分类',
    description: '点击"用户分类"标签，根据业务场景定义用户分类规则，如意向客户、无意向客户等。',
    target: '[data-tab-key="user-classify"]',
    placement: 'bottom',
  },
  {
    step: 7,
    title: '配置场景系统设置',
    description: '点击"场景系统设置"标签，配置客户跟进规则和人机协同规则，包括意向客户推送、转人工条件等。',
    target: '[data-tab-key="system-settings"]',
    placement: 'bottom',
  },
  {
    step: 8,
    title: '配置短信内容模板',
    description: '点击"场景短信"标签，配置当前场景使用到的短信内容模板，包括挂机短信等。',
    target: '[data-tab-key="sms"]',
    placement: 'bottom',
  },
];

// 引导状态
const guideVisible = ref(false);
const guideCurrentStep = ref(0);
const guideStarted = ref(false);

// 引导框位置
const guidePosition = reactive({
  top: 0,
  left: 0,
});

// 是否启用过渡动画（首次显示时不启用，后续步骤切换时启用）
const enableGuideTransition = ref(false);

// 遮罩层位置和高亮区域
const highlightElement = ref<HTMLElement | null>(null);
const highlightRect = reactive({
  top: 0,
  left: 0,
  width: 0,
  height: 0,
});

// ==================== QA 库新手引导相关数据 ====================

// QA 引导步骤配置
const qaGuideSteps = [
  {
    title: '引用通用/行业 QA',
    content: '点击"引用通用/行业 QA"按钮，引用当前场景涉及的行业/通用 QA，快速丰富应答库。',
    targetSelector: '.qa-toolbar .reference-qa-btn',
  },
  {
    title: '编辑回复',
    content: '在 QA 卡片中点击"新增回复"按钮，编辑行业/通用 QA 的回复内容，使其更符合当前场景需求。',
    targetSelector: '.qa-card:first-child .add-reply-btn',
  },
  {
    title: '创建场景 QA',
    content: '点击"新建场景 QA"按钮，创建当前场景专属的 QA 和对应回复，满足特定业务需求。',
    targetSelector: '.qa-toolbar .create-scene-qa-btn',
  },
  {
    title: '添加用户问法',
    content: '点击场景 QA 卡片中的"添加用户问法"按钮，维护场景对应的 pattern 语料，提升识别准确率。',
    targetSelector: '.qa-card:first-child .add-user-question-btn',
  },
  {
    title: '语料维护说明',
    content: '当通用/行业 QA 缺失语料时，可创建同名场景 QA 维护语料后上报，用于模型优化。场景模板 QA 库展示基于当前模板创建的场景中的所有 QA。',
    targetSelector: '.qa-content',
  },
];

// QA 引导状态
const qaGuideVisible = ref(false);
const qaGuideCompleted = ref(false);

// 计算属性：当前引导步骤
const currentGuideStep = computed(() => {
  return guideSteps[guideCurrentStep.value];
});

// 计算引导框位置
const calculateGuidePosition = () => {
  nextTick(() => {
    setTimeout(() => {
      const tabKey = guideSteps[guideCurrentStep.value].target.replace('[data-tab-key="', '').replace('"]', '');
      console.log('计算引导位置，tabKey:', tabKey);
      
      // step1 时，强制使用"主流程设置"tab 的位置
      const targetTabKey = guideCurrentStep.value === 0 ? 'process' : tabKey;
      
      // 方法 1: 尝试使用 data-node-key 查找
      let targetElement = document.querySelector(`.ant-tabs-tab[data-node-key="${targetTabKey}"]`) as HTMLElement;
      
      // 方法 2: 如果找不到，尝试通过 role="tab" 和 aria-controls 查找
      if (!targetElement) {
        const tabs = document.querySelectorAll('[role="tab"]');
        for (let i = 0; i < tabs.length; i++) {
          const tab = tabs[i] as HTMLElement;
          if (tab.getAttribute('aria-controls')?.includes(targetTabKey)) {
            targetElement = tab;
            break;
          }
        }
      }
      
      // 方法 3: 如果还是找不到，尝试通过 tab 的文本内容匹配
      if (!targetElement) {
        const tabTextMap: Record<string, string> = {
          'process': '主流程设置',
          'qa': 'QA 库',
          'intent': '意图库',
          'script': '话术管理',
          'user-classify': '用户分类',
          'fallback': '流程兜底设置',
          'system-settings': '场景系统设置',
        };
        const tabText = tabTextMap[targetTabKey];
        if (tabText) {
          const tabs = document.querySelectorAll('.ant-tabs-tab');
          for (let i = 0; i < tabs.length; i++) {
            const tab = tabs[i];
            if (tab.textContent?.includes(tabText)) {
              targetElement = tab;
              break;
            }
          }
        }
      }
      
      console.log('目标元素:', targetElement);
      
      if (targetElement) {
        const rect = targetElement.getBoundingClientRect();
        console.log('目标元素位置:', rect);
        
        // 使用 fixed 定位，直接使用视口坐标
        guidePosition.left = rect.left;
        guidePosition.top = rect.bottom + 14; // 8px + 6px 间距
        
        // 设置高亮区域
        highlightElement.value = targetElement;
        highlightRect.top = rect.top;
        highlightRect.left = rect.left;
        highlightRect.width = rect.width;
        highlightRect.height = rect.height;
        
        console.log('引导框位置:', guidePosition);
      } else {
        console.log('未找到目标元素:', targetTabKey);
        // 如果找不到元素，使用默认位置
        guidePosition.top = 70;
        guidePosition.left = 24;
      }
    }, 50); // 减少延迟时间
  });
};

// ==================== 用户分类相关数据 ====================

// 用户分类接口
interface UserCategory {
  id: number;
  name: string;
  priority: number;
  isDefault: boolean;
  enabled: boolean; // 启用/停用状态
  rules: CategoryRule[];
}

interface CategoryRule {
  id: number;
  expression: string;
  resultType?: string;
  conditions?: RuleCondition[];
}

interface RuleCondition {
  id: number;
  fieldType: string;
  operator: string;
  value: string;
}

// 用户分类列表
const userCategories = ref<UserCategory[]>([
  {
    id: 1,
    name: '有意向',
    priority: 1,
    isDefault: true,
    enabled: true,
    rules: [],
  },
  {
    id: 2,
    name: '可能有意向',
    priority: 2,
    isDefault: false,
    enabled: true,
    rules: [],
  },
  {
    id: 3,
    name: '无意向',
    priority: 3,
    isDefault: true,
    enabled: true,
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

// 添加/编辑分类弹窗
const categoryModalVisible = ref(false);
const categoryModalTitle = ref('添加分类');
const categoryFormRef = ref<FormInstance>();
const categoryForm = reactive({
  id: 0,
  name: '',
  priority: 1,
  isDefault: false,
  enabled: true,
});

const categoryFormRules: Record<string, Rule[]> = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }],
  priority: [{ required: true, message: '请输入优先级', trigger: 'blur' }],
};

// 新增规则表达式相关
const showAddRuleForm = ref(false);
const newRuleIndex = ref(1);
const newRuleForm = reactive({
  resultType: '',
  conditions: [] as RuleCondition[],
});
let conditionIdCounter = 1;

// 编辑中的规则列表（支持多个表达式）
const editingRules = ref<CategoryRule[]>([]);
let ruleIdCounter = 1;

// 初始化新规则表单
const initNewRuleForm = () => {
  newRuleForm.resultType = '';
  newRuleForm.conditions = [{
    id: conditionIdCounter++,
    fieldType: 'QA 标签',
    operator: '不包含',
    value: '',
  }];
};

// 初始化编辑规则
const initEditingRules = () => {
  const category = userCategories.value.find(c => c.id === selectedCategoryId.value);
  if (category && category.rules.length > 0) {
    // 复制已有规则用于编辑
    editingRules.value = category.rules.map(rule => ({
      ...rule,
      conditions: rule.conditions ? rule.conditions.map(c => ({ ...c })) : [],
    }));
  } else {
    // 新建一个空规则
    editingRules.value = [{
      id: ruleIdCounter++,
      resultType: '',
      conditions: [{
        id: conditionIdCounter++,
        fieldType: 'QA 标签',
        operator: '不包含',
        value: '',
      }],
    }];
  }
};

// 添加用户问法弹窗
const addUserQuestionModalVisible = ref(false);
const currentAddUserQuestionQa = ref<QaItem | null>(null);
const userQuestionActiveTab = ref('pattern');

// 新增语料弹窗
const addPatternModalVisible = ref(false);
const addPatternFormRef = ref<FormInstance>();
const addPatternForm = reactive({
  patternText: '',
});

const addPatternRules: Record<string, Rule[]> = {
  patternText: [{ required: true, message: '请输入语料内容', trigger: 'blur' }],
};

// 上报语料确认弹窗
const reportPatternConfirmVisible = ref(false);

const patternSearchKeyword = ref('');
const patternList = ref([
  { id: 1, patternText: '你他妈.*打电话给我' },
  { id: 2, patternText: '你他妈.*打我电话' },
  { id: 3, patternText: '我现在.{0,1}电话录 [着] 音' },
  { id: 4, patternText: '不要给我 [有 | 推销] 任何 [的] 推销' },
  { id: 5, patternText: '我不 (接受 | 要) 任何 [的] 推销' },
  { id: 6, patternText: '对你们 [银行](很 | 好 | 非常)(失望 | 不满 | 不满意)' },
  { id: 7, patternText: '找 (消保 | 银监会 | 保监会 | 银保监会)' },
  { id: 8, patternText: '[在 | 我] 睡觉.{0,3}[你] 给我转到.{0,2}(银监会 | 保监会 | 银保监会)' },
  { id: 9, patternText: '给我转到.{0,2}(银监会 | 保监会 | 银保监会)' },
  { id: 10, patternText: '(在 | 去 | 要)(一二三 | 幺二三|123).{0,4}(查 | 看 | 查看 | 查询)[一] 下' },
]);

// 当前正在编辑的 pattern ID
const editingPatternId = ref<number | null>(null);
const editInputRef = ref<any>(null);

// pattern 分页
const patternPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 261,
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

// 选中的 pattern 行
const selectedPatternRowKeys = ref<number[]>([]);

// 语义槽列表（模拟数据）
const semanticSlotList = ref([
  { id: 1, slotName: '你', color: '#52c41a', bindDict: '@com.你' },
  { id: 2, slotName: '什么', color: '#52c41a', bindDict: '@com.什么' },
  { id: 3, slotName: '语气词', color: '#eb2f96', bindDict: '@com.语气词' },
  { id: 4, slotName: '办理', color: '#722ed1', bindDict: '@com.办理' },
  { id: 5, slotName: '你', color: '#1890ff', bindDict: '@com.你' },
  { id: 6, slotName: '什么', color: '#faad14', bindDict: '@com.什么' },
  { id: 7, slotName: '语气词', color: '#13c2c2', bindDict: '@com.语气词' },
  { id: 8, slotName: '办理', color: '#722ed1', bindDict: '@com.办理' },
]);

// 语义槽分页
const semanticSlotPagination = reactive({
  current: 1,
  pageSize: 10,
  total: 8,
  showSizeChanger: false,
  showQuickJumper: false,
  showTotal: (total: number) => `共 ${total} 条`,
  locale: {
    items_per_page: '条/页',
    jump_to: '跳转至',
    page: '页',
  },
});

// pattern 表格列
const patternColumns = [
  {
    title: 'pattern 语料',
    dataIndex: 'patternText',
    key: 'patternText',
    width: 850,
  },
  {
    title: '操作',
    key: 'action',
    width: 80,
    fixed: 'right' as const,
  },
];

// 语义槽表格列
const semanticSlotColumns = [
  {
    title: '语义槽',
    dataIndex: 'slotName',
    key: 'slotName',
    width: 300,
  },
  {
    title: '绑定词库',
    dataIndex: 'bindDict',
    key: 'bindDict',
    width: 300,
  },
  {
    title: '操作',
    key: 'action',
    width: 80,
    fixed: 'right' as const,
  },
];

// ==================== 方法定义 ====================

// ==================== 流程图相关方法 ====================

// 获取节点图标
const getNodeIcon = (type: NodeType) => {
  const iconMap: Record<NodeType, any> = {
    start: PlayCircleOutlined,
    script: MessageOutlined,
    success_end: CheckCircleOutlined,
    fail_end: CloseCircleOutlined,
    transfer: CustomerServiceOutlined,
    verify: SafetyCertificateOutlined,
  };
  return iconMap[type];
};

// 获取连接点位置
const getConnectorPosition = (node: ProcessNode, direction: 'in' | 'out') => {
  const nodeWidth = 200;
  const nodeHeight = 80;

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
  const nodeHeight = 80;

  const startX = sourceNode.x + nodeWidth / 2;
  const startY = sourceNode.y + nodeHeight;
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
  const nodeHeight = 80;

  const startX = sourceNode.x + nodeWidth / 2;
  const startY = sourceNode.y + nodeHeight;
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
  const nodeHeight = 80;

  const startX = drawingSourceNode.value.x + nodeWidth / 2;
  const startY = drawingSourceNode.value.y + nodeHeight;
  const endX = tempMousePosition.x;
  const endY = tempMousePosition.y;

  const controlY1 = startY + Math.abs(endY - startY) / 2;
  const controlY2 = endY - Math.abs(endY - startY) / 2;

  return `M ${startX} ${startY} C ${startX} ${controlY1}, ${endX} ${controlY2}, ${endX} ${endY}`;
};

// 添加节点（点击按钮添加）
const handleAddNode = (nodeType: NodeTypeDef) => {
  if (!canvasRef.value) return;

  const rect = canvasRef.value.getBoundingClientRect();
  const scale = canvasZoom.value / 100;
  
  // 计算画布中心位置
  const scrollLeft = canvasRef.value.scrollLeft || 0;
  const scrollTop = canvasRef.value.scrollTop || 0;
  const centerX = (rect.width / 2 + scrollLeft) / scale - 100;
  const centerY = (rect.height / 2 + scrollTop) / scale - 40;

  const newNode: ProcessNode = {
    id: Date.now(),
    type: nodeType.type as NodeType,
    name: getNodeDefaultName(nodeType.type as NodeType),
    x: Math.max(0, centerX),
    y: Math.max(0, centerY + processNodes.value.length * 20), // 稍微错开位置
    content: {},
  };

  processNodes.value.push(newNode);

  // 自动连接到上一个非结束节点
  if (nodeType.type !== 'start') {
    const nonEndNodes = processNodes.value.filter(
      n => n.type !== 'success_end' && n.type !== 'fail_end' && n.id !== newNode.id
    );
    if (nonEndNodes.length > 0) {
      const lastNode = nonEndNodes[nonEndNodes.length - 1];
      connections.value.push({
        id: Date.now() + 1,
        sourceNodeId: lastNode.id,
        targetNodeId: newNode.id,
      });
    }
  }

  message.success(`已添加${nodeType.label}`);
};

// 获取节点默认名称
const getNodeDefaultName = (type: NodeType) => {
  const nameMap: Record<NodeType, string> = {
    start: '开始',
    script: '通用节点',
    success_end: '成功结束',
    fail_end: '失败结束',
    transfer: '转人工坐席',
    verify: '验证信息',
  };
  return nameMap[type];
};

// 画布点击
const handleCanvasClick = () => {
  selectedNode.value = null;
  selectedConnection.value = null;
};

// 画布拖拽over（允许放置）
const handleCanvasDragOver = (event: DragEvent) => {
  event.preventDefault();
  event.dataTransfer!.dropEffect = 'copy';
};

// 画布拖拽放置（从节点添加栏拖拽节点到画布）
const handleCanvasDrop = (event: DragEvent) => {
  event.preventDefault();
  
  const nodeTypeStr = event.dataTransfer?.getData('nodeType');
  if (!nodeTypeStr) return;
  
  const nodeType = JSON.parse(nodeTypeStr);
  
  if (!canvasRef.value) return;
  
  const rect = canvasRef.value.getBoundingClientRect();
  const scale = canvasZoom.value / 100;
  
  // 计算放置位置（考虑滚动偏移）
  const scrollLeft = canvasRef.value.scrollLeft || 0;
  const scrollTop = canvasRef.value.scrollTop || 0;
  const x = (event.clientX - rect.left) / scale - 100; // 居中
  const y = (event.clientY - rect.top) / scale - 40;
  
  const newNode: ProcessNode = {
    id: Date.now(),
    type: nodeType.type as NodeType,
    name: getNodeDefaultName(nodeType.type as NodeType),
    x: Math.max(0, x),
    y: Math.max(0, y),
    content: {},
  };
  
  processNodes.value.push(newNode);
  
  // 自动连接到上一个非结束节点
  if (nodeType.type !== 'start') {
    const nonEndNodes = processNodes.value.filter(
      n => n.type !== 'success_end' && n.type !== 'fail_end' && n.id !== newNode.id
    );
    if (nonEndNodes.length > 0) {
      const lastNode = nonEndNodes[nonEndNodes.length - 1];
      connections.value.push({
        id: Date.now() + 1,
        sourceNodeId: lastNode.id,
        targetNodeId: newNode.id,
      });
    }
  }
  
  message.success(`已添加${nodeType.label}`);
};

// 节点添加栏拖拽开始
const handlePaletteNodeDragStart = (event: DragEvent, nodeType: NodeTypeDef) => {
  event.dataTransfer?.setData('nodeType', JSON.stringify(nodeType));
  event.dataTransfer!.effectAllowed = 'copy';
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
  nodeEditModalVisible.value = true;
};

// 获取节点编辑弹窗标题
const getNodeEditModalTitle = (type: NodeType | undefined) => {
  const titleMap: Record<NodeType, string> = {
    start: '开始节点设置',
    script: '通用节点设置',
    success_end: '成功结束设置',
    fail_end: '失败结束设置',
    transfer: '转人工坐席设置',
    verify: '验证信息设置',
  };
  return type ? titleMap[type] : '节点设置';
};

// 获取节点编辑占位符
const getNodeEditPlaceholder = (type: NodeType | undefined) => {
  const placeholderMap: Record<NodeType, string> = {
    start: '请输入话术内容',
    script: '请输入话术回复内容',
    success_end: '请输入成功结束时的话术',
    fail_end: '请输入失败结束时的话术',
    transfer: '请输入转人工坐席的话术',
    verify: '请输入验证信息的话术',
  };
  return type ? placeholderMap[type] : '请输入话术内容';
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
      if (editingNode.value.type !== 'start') {
        editingNode.value.content.text = nodeEditForm.text;
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
  // 初始化已选意图
  connectionEditForm.selectedIntents = connection.intents ? [...connection.intents] : [];
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
    selectedConnection.value.intents = connectionEditForm.selectedIntents.length > 0 
      ? [...connectionEditForm.selectedIntents] 
      : undefined;
    message.success('保存成功');
    connectionEditModalVisible.value = false;
  }
};

// 判断意图是否已选中
const isIntentSelected = (intentId: number) => {
  return connectionEditForm.selectedIntents.some(i => i.id === intentId);
};

// 意图勾选变化
const handleIntentCheckboxChange = (event: Event, intent: IntentItem) => {
  const checked = (event.target as HTMLInputElement).checked;
  if (checked) {
    if (!connectionEditForm.selectedIntents.some(i => i.id === intent.id)) {
      connectionEditForm.selectedIntents.push(intent);
    }
  } else {
    connectionEditForm.selectedIntents = connectionEditForm.selectedIntents.filter(i => i.id !== intent.id);
  }
};

// 移除已选意图
const handleRemoveIntent = (intent: IntentItem) => {
  connectionEditForm.selectedIntents = connectionEditForm.selectedIntents.filter(i => i.id !== intent.id);
};

// 获取意图类型颜色
const getIntentTypeColor = (intentType: string) => {
  const colorMap: Record<string, string> = {
    '肯定': 'green',
    '否定': 'red',
    '中性': 'blue',
    '重复': 'orange',
  };
  return colorMap[intentType] || 'default';
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
  if (selectedReferenceRowKeys.value.length === 0) {
    message.warning('请至少选择一个 QA');
    return;
  }
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

// ==================== 话术管理相关方法 ====================

// 搜索话术
const handleScriptSearch = () => {
  console.log('搜索话术:', scriptSearchKeyword.value);
  message.info(`搜索：${scriptSearchKeyword.value || '全部'}`);
  // TODO: 实现搜索逻辑
};

// 重置话术搜索
const handleScriptReset = () => {
  scriptSearchKeyword.value = '';
  console.log('重置话术搜索');
  message.success('已重置搜索条件');
};

// 话术表格变化
const handleScriptTableChange = (pagination: any) => {
  scriptPagination.current = pagination.current;
  scriptPagination.pageSize = pagination.pageSize;
  console.log('话术表格变化:', pagination);
  // TODO: 实现数据加载
};

// 话术分页变化
const handleScriptPageChange = (page: number) => {
  scriptPagination.current = page;
  console.log('话术分页变化:', page);
  // TODO: 实现数据加载
};

// 话术每页条数变化
const handleScriptPageSizeChange = (_current: number, size: number) => {
  scriptPagination.pageSize = size;
  scriptPagination.current = 1;
  console.log('话术每页条数变化:', size);
  // TODO: 实现数据加载
};

// 话术选择变化
const onScriptSelectChange = (selectedRowKeys: number[]) => {
  selectedScriptRowKeys.value = selectedRowKeys;
};

// 话术子 tab 切换
const handleScriptSubTabChange = (key: string) => {
  console.log('切换话术子 tab:', key);
  // 切换 tab 时重置搜索条件
  scriptSearchKeyword.value = '';
  scriptComplianceFilter.value = undefined;
  scriptAudioStatusFilter.value = undefined;
};

// 新建变量
const handleAddVariable = () => {
  message.info('导入变量功能开发中...');
  // TODO: 实现导入变量弹窗
};

// 编辑变量值
const handleEditVariableValue = (record: any) => {
  editingVariableId.value = record.id;
};

// 保存变量值
const handleSaveVariableValue = (record: any) => {
  console.log('保存变量值:', record.variableName, record.variableValue);
  editingVariableId.value = null;
  message.success('保存变量值成功');
  // TODO: 实现保存逻辑
};

// ==================== 场景短信相关方法 ====================

// 搜索短信
const handleSmsSearch = () => {
  console.log('搜索短信:', smsTemplateNameFilter.value, smsContentFilter.value);
  message.info(`搜索：模版名称="${smsTemplateNameFilter.value || '全部'}", 短信内容="${smsContentFilter.value || '全部'}"`);
  // TODO: 实现搜索逻辑
};

// 重置短信搜索
const handleSmsReset = () => {
  smsTemplateNameFilter.value = '';
  smsContentFilter.value = '';
  console.log('重置短信搜索');
  message.success('已重置搜索条件');
};

// 短信表格变化
const handleSmsTableChange = (pagination: any) => {
  smsPagination.current = pagination.current;
  smsPagination.pageSize = pagination.pageSize;
  console.log('短信表格变化:', pagination);
  // TODO: 实现数据加载
};

// 短信分页变化
const handleSmsPageChange = (page: number) => {
  smsPagination.current = page;
  console.log('短信分页变化:', page);
  // TODO: 实现数据加载
};

// 短信每页条数变化
const handleSmsPageSizeChange = (_current: number, size: number) => {
  smsPagination.pageSize = size;
  smsPagination.current = 1;
  console.log('短信每页条数变化:', size);
  // TODO: 实现数据加载
};

// 导入模版
const handleImportSmsTemplate = () => {
  message.info('导入模版功能开发中...');
  // TODO: 实现导入模版弹窗
};

// 新增短信
const handleCreateSms = () => {
  message.info('新增短信功能开发中...');
  // TODO: 实现新增短信弹窗
};

// 编辑短信
const handleEditSms = (record: SmsItem) => {
  console.log('编辑短信:', record);
  editSmsForm.id = record.id;
  editSmsForm.smsName = record.smsName;
  editSmsForm.smsCode = record.smsCode;
  editSmsForm.smsContent = record.smsContent;
  editSmsModalVisible.value = true;
};

// 取消编辑短信
const handleEditSmsCancel = () => {
  editSmsModalVisible.value = false;
  editSmsFormRef.value?.resetFields();
};

// 提交编辑短信
const handleEditSmsSubmit = async () => {
  try {
    await editSmsFormRef.value?.validate();
    const index = smsList.value.findIndex(item => item.id === editSmsForm.id);
    if (index !== -1) {
      smsList.value[index].smsName = editSmsForm.smsName;
      smsList.value[index].smsCode = editSmsForm.smsCode;
      smsList.value[index].smsContent = editSmsForm.smsContent;
      smsList.value[index].modifyTime = new Date().toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      }).replace(/\//g, '-');
    }
    message.success('保存短信成功');
    editSmsModalVisible.value = false;
    editSmsFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 删除短信
const handleDeleteSms = (record: SmsItem) => {
  console.log('删除短信:', record);
  const index = smsList.value.findIndex(item => item.id === record.id);
  if (index !== -1) {
    smsList.value.splice(index, 1);
    smsTotal.value = smsList.value.length;
    message.success('删除短信成功');
  }
};

// ==================== 录音包管理方法 ====================

// 录音包搜索
const handleAudioPackageSearch = () => {
  console.log('搜索录音包:', audioPackageSearchKeyword.value);
  message.info(`搜索：${audioPackageSearchKeyword.value || '全部'}`);
  // TODO: 实现搜索逻辑
};

// 录音包重置
const handleAudioPackageReset = () => {
  audioPackageSearchKeyword.value = '';
  console.log('重置录音包搜索');
  message.success('已重置搜索条件');
};

// 录音包表格变化
const handleAudioPackageTableChange = (pagination: any) => {
  audioPackagePagination.current = pagination.current;
  audioPackagePagination.pageSize = pagination.pageSize;
  console.log('录音包表格变化:', pagination);
};

// 新建录音包
const handleCreateAudioPackage = () => {
  createAudioPackageForm.packageName = '';
  createAudioPackageForm.recorder = '';
  createAudioPackageModalVisible.value = true;
};

// 取消新建录音包
const handleCreateAudioPackageCancel = () => {
  createAudioPackageModalVisible.value = false;
  createAudioPackageFormRef.value?.resetFields();
};

// 提交新建录音包
const handleCreateAudioPackageSubmit = async () => {
  try {
    await createAudioPackageFormRef.value?.validate();
    const newPackage = {
      id: Date.now(),
      packageName: createAudioPackageForm.packageName,
      recorder: createAudioPackageForm.recorder,
      progressPercent: 0,
      completedCount: 0,
      totalCount: 200,
      uploadStatus: '未完成',
      isDefault: false,
    };
    audioPackageList.value.push(newPackage);
    message.success('新建录音包成功');
    createAudioPackageModalVisible.value = false;
    createAudioPackageFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 编辑录音包
const handleEditAudioPackage = (record: any) => {
  editAudioPackageForm.id = record.id;
  editAudioPackageForm.packageName = record.packageName;
  editAudioPackageForm.recorder = record.recorder;
  editAudioPackageModalVisible.value = true;
};

// 取消编辑录音包
const handleEditAudioPackageCancel = () => {
  editAudioPackageModalVisible.value = false;
  editAudioPackageFormRef.value?.resetFields();
};

// 提交编辑录音包
const handleEditAudioPackageSubmit = async () => {
  try {
    await editAudioPackageFormRef.value?.validate();
    const record = audioPackageList.value.find(item => item.id === editAudioPackageForm.id);
    if (record) {
      record.packageName = editAudioPackageForm.packageName;
      record.recorder = editAudioPackageForm.recorder;
    }
    message.success('编辑录音包成功');
    editAudioPackageModalVisible.value = false;
    editAudioPackageFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 删除录音包
const handleDeleteAudioPackage = (record: any) => {
  // 至少保留一个录音包
  if (audioPackageList.value.length === 1) {
    message.warning('至少保留一个录音包');
    return;
  }
  console.log('删除录音包:', record);
  const index = audioPackageList.value.findIndex(item => item.id === record.id);
  if (index !== -1) {
    audioPackageList.value.splice(index, 1);
    message.success('删除录音包成功');
  }
};

// 查看录音包详情
const handleViewAudioPackageDetail = (record: any) => {
  console.log('查看录音包详情:', record);
  currentAudioPackage.value = record;
  showAudioDetail.value = true;
};

// 返回录音包列表
const handleBackToAudioPackage = () => {
  currentAudioPackage.value = null;
  showAudioDetail.value = false;
};

// 设为默认录音包
const handleSetDefaultAudioPackage = (record: any) => {
  // 将所有录音包的 isDefault 设为 false
  audioPackageList.value.forEach(item => {
    item.isDefault = false;
  });
  // 将当前录音包设为默认
  record.isDefault = true;
  message.success('设为默认录音包成功');
};

// 编辑话术
const handleEditScript = (record: ScriptItem) => {
  currentEditScript.value = record;
  editScriptForm.id = record.id;
  editScriptForm.replyText = record.replyText;
  editScriptForm.audioUrl = record.audioUrl;
  editScriptModalVisible.value = true;
  selectedAudioFile.value = null;
  audioUploading.value = false;
};

// 触发音频文件选择
const triggerAudioFileSelect = () => {
  audioFileInputRef.value?.click();
};

// 取消编辑话术
const handleEditScriptCancel = () => {
  editScriptModalVisible.value = false;
  editScriptFormRef.value?.resetFields();
  currentEditScript.value = null;
  selectedAudioFile.value = null;
  audioUploading.value = false;
};

// 提交编辑话术
const handleEditScriptSubmit = async () => {
  try {
    await editScriptFormRef.value?.validate();
    if (currentEditScript.value) {
      // 如果话术文本发生了变化，将消保状态重置为未消保
      if (currentEditScript.value.replyText !== editScriptForm.replyText) {
        currentEditScript.value.complianceStatus = '未消保';
      }
      currentEditScript.value.replyText = editScriptForm.replyText;
      currentEditScript.value.audioUrl = editScriptForm.audioUrl;
      if (editScriptForm.audioUrl) {
        currentEditScript.value.audioUploadStatus = '已上传';
      }
    }
    message.success('保存成功');
    editScriptModalVisible.value = false;
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 音频文件选择变化
const handleAudioFileChange = (e: Event) => {
  const target = e.target as HTMLInputElement;
  if (target.files && target.files.length > 0) {
    selectedAudioFile.value = target.files[0];
    // 自动上传
    handleUploadAudio();
  }
};

// 上传录音
const handleUploadAudio = () => {
  if (!selectedAudioFile.value) {
    message.warning('请先选择音频文件');
    return;
  }
  audioUploading.value = true;
  // 模拟上传
  setTimeout(() => {
    const url = URL.createObjectURL(selectedAudioFile.value!);
    editScriptForm.audioUrl = url;
    audioUploading.value = false;
    selectedAudioFile.value = null;
    message.success('录音上传成功');
  }, 1500);
};

// 音频加载错误处理
const handleAudioError = (_e: Event, record: ScriptItem) => {
  console.log('音频加载失败:', record.recordFileName);
  // 可以在这里设置默认音频或隐藏播放器
};

// 获取消保状态颜色
const getComplianceStatusColor = (status?: string) => {
  const colorMap: Record<string, string> = {
    '消保通过': 'green',
    '消保不通过': 'red',
    '未消保': 'default',
  };
  return colorMap[status || '未消保'] || 'default';
};

// ==================== 话术管理 - 批量操作方法 ====================

// 批量删除 - 删除所选
const handleBatchDeleteSelected = () => {
  if (selectedScriptRowKeys.value.length === 0) {
    message.warning('请先选择要删除的话术');
    return;
  }
  Modal.confirm({
    title: '删除选中',
    content: `删除后对应话术来源配置的话术文本将被清空，确定要删除选中的 ${selectedScriptRowKeys.value.length} 条话术吗？此操作不可恢复！`,
    okText: '确定',
    cancelText: '取消',
    onOk: () => {
      scriptList.value = scriptList.value.filter(item => !selectedScriptRowKeys.value.includes(item.id));
      selectedScriptRowKeys.value = [];
      message.success('删除选中话术成功');
    },
  });
};

// 批量删除 - 删除全部
const handleBatchDeleteAll = () => {
  Modal.confirm({
    title: '删除全部',
    content: '删除后对应话术来源配置的话术文本将被清空，确定要删除全部话术吗？此操作不可恢复！',
    okText: '确定',
    cancelText: '取消',
    onOk: () => {
      scriptList.value = [];
      selectedScriptRowKeys.value = [];
      message.success('删除全部话术成功');
    },
  });
};

// 批量导出 - 导出所选
const handleBatchExportSelected = () => {
  if (selectedScriptRowKeys.value.length === 0) {
    message.warning('请先选择要导出的话术');
    return;
  }
  const selectedScripts = scriptList.value.filter(item => selectedScriptRowKeys.value.includes(item.id));
  console.log('导出选中话术:', selectedScripts);
  message.success(`已导出 ${selectedScripts.length} 条话术`);
};

// 批量导出 - 导出全部
const handleBatchExportAll = () => {
  console.log('导出全部话术:', scriptList.value);
  message.success(`已导出 ${scriptList.value.length} 条话术`);
};

// 导入录音
const handleImportAudio = () => {
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = 'audio/*';
  input.onchange = (e) => {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      console.log('导入录音文件:', target.files[0]);
      message.success('录音导入成功');
    }
  };
  input.click();
};

// 语音检测
const handleVoiceCheck = () => {
  message.info('开始语音检测...');
  console.log('语音检测');
};

// 消保通过
const handleCompliancePass = (record: ScriptItem) => {
  record.complianceStatus = '消保通过';
  message.success('已设置为消保通过');
};

// 消保不通过
const handleComplianceReject = (record: ScriptItem) => {
  record.complianceStatus = '消保不通过';
  message.success('已设置为消保不通过');
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

// 编辑分类
const handleEditCategory = (category: UserCategory, index: number) => {
  // 默认分类（前 3 个）不允许编辑名称
  if (index < 3) {
    categoryModalTitle.value = '查看分类';
  } else {
    categoryModalTitle.value = '编辑分类';
  }
  categoryForm.id = category.id;
  categoryForm.name = category.name;
  categoryForm.priority = category.priority;
  categoryForm.isDefault = category.isDefault;
  categoryModalVisible.value = true;
};

// 添加分类
const handleAddCategory = () => {
  categoryModalTitle.value = '添加分类';
  categoryForm.id = 0;
  categoryForm.name = '';
  categoryForm.priority = 1;
  categoryForm.isDefault = false;
  categoryForm.enabled = true;
  categoryModalVisible.value = true;
};

// 分类弹窗确认
const handleCategoryModalOk = () => {
  categoryFormRef.value?.validate().then(() => {
    if (categoryForm.id === 0) {
      // 新增
      const newId = Math.max(...userCategories.value.map(c => c.id), 0) + 1;
      userCategories.value.push({
        id: newId,
        name: categoryForm.name,
        priority: categoryForm.priority,
        isDefault: categoryForm.isDefault,
        enabled: true,
        rules: [],
      });
      message.success('添加分类成功');
    } else {
      // 编辑
      const category = userCategories.value.find(c => c.id === categoryForm.id);
      if (category) {
        // 默认分类（前 3 个）不允许修改名称
        if (category.id > 3) {
          category.name = categoryForm.name;
        }
        category.priority = categoryForm.priority;
        category.isDefault = categoryForm.isDefault;
      }
      message.success('保存成功');
    }
    categoryModalVisible.value = false;
  }).catch(() => {
    // 验证失败
  });
};

// 切换分类启用/停用状态
const handleToggleCategoryEnabled = (category: UserCategory) => {
  category.enabled = !category.enabled;
  message.success(category.enabled ? '已启用' : '已停用');
};

// 删除分类
const handleDeleteCategory = (category: UserCategory) => {
  Modal.confirm({
    title: '删除分类',
    content: `确定要删除分类"${category.name}"吗？删除后不可恢复！`,
    okText: '确定',
    cancelText: '取消',
    onOk: () => {
      const index = userCategories.value.findIndex(c => c.id === category.id);
      if (index !== -1) {
        userCategories.value.splice(index, 1);
        // 如果删除的是当前选中的分类，切换到第一个分类
        if (selectedCategoryId.value === category.id) {
          selectedCategoryId.value = userCategories.value[0]?.id || 0;
        }
        message.success('删除分类成功');
      }
    },
  });
};

// 分类弹窗取消
const handleCategoryModalCancel = () => {
  categoryModalVisible.value = false;
};

// 选择分类时初始化编辑规则
const handleSelectCategory = (id: number) => {
  selectedCategoryId.value = id;
  initEditingRules();
};

// 新增表达式
const handleAddExpression = () => {
  editingRules.value.push({
    id: ruleIdCounter++,
    resultType: '',
    conditions: [{
      id: conditionIdCounter++,
      fieldType: 'QA 标签',
      operator: '不包含',
      value: '',
    }],
  });
};

// 删除表达式
const handleDeleteExpression = (ruleIndex: number) => {
  if (editingRules.value.length > 1) {
    editingRules.value.splice(ruleIndex, 1);
  } else {
    message.warning('至少保留一个表达式');
  }
};

// 添加条件
const handleAddCondition = (ruleIndex: number) => {
  const rule = editingRules.value[ruleIndex];
  rule.conditions.push({
    id: conditionIdCounter++,
    fieldType: 'QA 标签',
    operator: '不包含',
    value: '',
  });
};

// 删除条件
const handleRemoveCondition = (ruleIndex: number, conditionIndex: number) => {
  const rule = editingRules.value[ruleIndex];
  if (rule.conditions.length > 1) {
    rule.conditions.splice(conditionIndex, 1);
  } else {
    message.warning('至少保留一个条件');
  }
};

// 保存用户分类配置
const handleSaveClassify = () => {
  const category = userCategories.value.find(c => c.id === selectedCategoryId.value);
  if (category) {
    category.rules = editingRules.value.map(rule => ({
      ...rule,
      conditions: rule.conditions ? rule.conditions.map(c => ({ ...c })) : [],
    }));
  }

  console.log('保存用户分类:', userCategories.value);
  message.success('保存成功');
};

// 删除规则
const handleDeleteRule = (rule: CategoryRule) => {
  const category = userCategories.value.find(c => c.id === selectedCategoryId.value);
  if (category) {
    const ruleIndex = category.rules.findIndex(r => r.id === rule.id);
    if (ruleIndex !== -1) {
      category.rules.splice(ruleIndex, 1);
    }
  }
  // 同时从编辑列表中移除
  const editIndex = editingRules.value.findIndex(r => r.id === rule.id);
  if (editIndex !== -1) {
    editingRules.value.splice(editIndex, 1);
  }
  message.success('删除规则成功');
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

// 添加用户问法
const handleAddUserQuestion = (qa: QaItem) => {
  currentAddUserQuestionQa.value = qa;
  addUserQuestionModalVisible.value = true;
  // 重置数据
  userQuestionActiveTab.value = 'pattern';
  patternSearchKeyword.value = '';
  selectedPatternRowKeys.value = [];
  console.log('添加用户问法:', qa);
};

// 取消添加用户问法
const handleAddUserQuestionCancel = () => {
  addUserQuestionModalVisible.value = false;
  currentAddUserQuestionQa.value = null;
  userQuestionActiveTab.value = 'pattern';
};

// 打开新增语料弹窗
const handleOpenAddPatternModal = () => {
  addPatternForm.patternText = '';
  addPatternModalVisible.value = true;
};

// 取消新增语料
const handleAddPatternModalCancel = () => {
  addPatternModalVisible.value = false;
  addPatternFormRef.value?.resetFields();
};

// 上报语料
const handleReportPattern = () => {
  reportPatternConfirmVisible.value = true;
};

// 取消上报语料
const handleReportPatternCancel = () => {
  reportPatternConfirmVisible.value = false;
};

// 确认上报语料
const handleReportPatternConfirm = async () => {
  try {
    // 校验语料是否填写
    await addPatternFormRef.value?.validate();
    const lines = addPatternForm.patternText.split('\n').filter(line => line.trim());
    if (lines.length === 0) {
      message.warning('请输入至少一条语料');
      return;
    }
    reportPatternConfirmVisible.value = false;
    message.success('语料上报成功');
    // TODO: 实现上报语料的实际逻辑
    console.log('上报语料:', addPatternForm.patternText);
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 提交新增语料
const handleAddPatternSubmit = async () => {
  try {
    await addPatternFormRef.value?.validate();
    const lines = addPatternForm.patternText.split('\n').filter(line => line.trim());
    if (lines.length === 0) {
      message.warning('请输入至少一条语料');
      return;
    }
    lines.forEach(line => {
      patternList.value.push({
        id: Date.now() + Math.random(),
        patternText: line.trim(),
      });
    });
    message.success(`成功添加${lines.length}条语料`);
    addPatternModalVisible.value = false;
    addPatternFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 删除 pattern
const handleDeletePattern = (record: any) => {
  const index = patternList.value.findIndex(item => item.id === record.id);
  if (index > -1) {
    patternList.value.splice(index, 1);
    message.success('删除成功');
  }
};

// 批量删除 pattern
const handleBatchDeletePattern = () => {
  if (selectedPatternRowKeys.value.length === 0) {
    message.warning('请先选择要删除的语料');
    return;
  }
  patternList.value = patternList.value.filter(item => !selectedPatternRowKeys.value.includes(item.id));
  selectedPatternRowKeys.value = [];
  message.success(`已删除${patternList.value.length}条语料`);
};

// 语义测试
const handleSemanticTest = () => {
  message.info('语义测试功能开发中...');
};

// 保存用户问法
const handleSaveUserQuestion = () => {
  console.log('保存用户问法:', {
    qa: currentAddUserQuestionQa.value,
    patterns: patternList.value,
    semanticSlots: semanticSlotList.value,
  });
  message.success('保存成功');
  addUserQuestionModalVisible.value = false;
};

// pattern 表格变化
const handlePatternTableChange = (pagination: any) => {
  patternPagination.current = pagination.current;
  patternPagination.pageSize = pagination.pageSize;
};

// pattern 选择变化
const onPatternSelectChange = (selectedRowKeys: number[]) => {
  selectedPatternRowKeys.value = selectedRowKeys;
};

// 删除语义槽
const handleDeleteSemanticSlot = (record: any) => {
  const index = semanticSlotList.value.findIndex(item => item.id === record.id);
  if (index > -1) {
    semanticSlotList.value.splice(index, 1);
    message.success('删除成功');
  }
};

// 语义槽表格变化
const handleSemanticSlotTableChange = (pagination: any) => {
  semanticSlotPagination.current = pagination.current;
  semanticSlotPagination.pageSize = pagination.pageSize;
};

// pattern 搜索
const handlePatternSearch = () => {
  console.log('搜索 pattern:', patternSearchKeyword.value);
  // TODO: 实现搜索逻辑
  message.info('搜索功能开发中...');
};

// 编辑 pattern
const handleEditPattern = (record: any) => {
  console.log('点击编辑 pattern:', record.id);
  editingPatternId.value = record.id;
  // 下一步聚焦输入框，需要在 DOM 更新后
  nextTick(() => {
    console.log('input ref:', editInputRef.value);
    if (editInputRef.value && editInputRef.value.focus) {
      editInputRef.value.focus();
    }
  });
};

// 保存 pattern 编辑
const handleSavePatternEdit = (record: any) => {
  console.log('保存 pattern 编辑:', record.patternText);
  // TODO: 实现保存逻辑
  editingPatternId.value = null;
  message.success('保存成功');
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

// 删除 QA
const handleDeleteQa = (qa: QaItem) => {
  console.log('删除 QA:', qa);
  const qaIndex = qaList.value.findIndex(item => item.id === qa.id);
  if (qaIndex !== -1) {
    qaList.value.splice(qaIndex, 1);
  }
  message.success('删除 QA 成功');
};

// 初始化
onMounted(() => {
  console.log('SceneTemplateDetail 组件已挂载');
  // 初始化用户分类编辑规则
  initEditingRules();
});

// 监听 tab 变化，在 QA 标签页首次加载时显示引导
watch(activeTabKey, (newKey) => {
  if (newKey === 'qa') {
    // 检查是否已完成 QA 引导
    const hasCompletedQaGuide = localStorage.getItem('qaGuideCompleted');
    if (!hasCompletedQaGuide && !qaGuideCompleted.value) {
      // 延迟显示，确保 DOM 已渲染
      setTimeout(() => {
        showQaGuide();
      }, 500);
    }
  }
}, { immediate: true });

// 显示 QA 引导
const showQaGuide = () => {
  console.log('显示 QA 引导');
  qaGuideVisible.value = true;
};

// 隐藏 QA 引导
const hideQaGuide = () => {
  qaGuideVisible.value = false;
};

// 完成 QA 引导
const handleQaGuideFinish = () => {
  qaGuideCompleted.value = true;
  hideQaGuide();
  message.success('引导完成！');
};

// 关闭 QA 引导
const handleQaGuideClose = () => {
  hideQaGuide();
};

// 监听 QA 引导 visible 变化
watch(() => qaGuideVisible.value, (newVal) => {
  if (newVal) {
    console.log('QA 引导已显示');
  }
});

// 显示引导
const showGuide = () => {
  // 直接显示引导，不检查 localStorage
  console.log('显示引导');
  guideCurrentStep.value = 0;
  guideStarted.value = true;
  // 先隐藏引导框，不启用过渡动画
  guideVisible.value = false;
  enableGuideTransition.value = false;
  
  // 计算位置并显示引导框
  setTimeout(() => {
    calculateGuidePosition();
    // 等位置计算好后再显示引导框
    setTimeout(() => {
      guideVisible.value = true;
    }, 100);
  }, 100);
};

// 隐藏引导
const hideGuide = () => {
  guideVisible.value = false;
  guideStarted.value = false;
  // 清除高亮区域
  highlightElement.value = null;
  highlightRect.top = 0;
  highlightRect.left = 0;
  highlightRect.width = 0;
  highlightRect.height = 0;
  // 用户完成引导后，记录到 localStorage
  localStorage.setItem('sceneTemplateGuideShown', 'true');
};

// 切换到指定 tab
const switchToTab = (tabKey: string) => {
  activeTabKey.value = tabKey;
  // 切换 tab 后滚动到顶部
  setTimeout(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }, 100);
};

// 下一步
const handleGuideNext = () => {
  if (guideCurrentStep.value < guideSteps.length - 1) {
    guideCurrentStep.value++;
    // 启用过渡动画
    enableGuideTransition.value = true;
    // 计算下一个步骤的引导框位置
    setTimeout(() => {
      calculateGuidePosition();
    }, 50);
  } else {
    hideGuide();
  }
};

// 上一步
const handleGuidePrev = () => {
  if (guideCurrentStep.value > 0) {
    guideCurrentStep.value--;
    // 启用过渡动画
    enableGuideTransition.value = true;
    // 计算上一个步骤的引导框位置
    setTimeout(() => {
      calculateGuidePosition();
    }, 50);
  }
};

// 跳至指定步骤
const handleGuideJump = (step: number) => {
  guideCurrentStep.value = step;
  // 启用过渡动画
  enableGuideTransition.value = true;
  // 计算指定步骤的引导框位置
  setTimeout(() => {
    calculateGuidePosition();
  }, 50);
};

// 完成引导
const handleGuideFinish = () => {
  hideGuide();
};

// 关闭引导
const handleGuideClose = () => {
  hideGuide();
};
</script>

<style scoped>
.scene-template-detail {
  /* height: 100%; */
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
  /* margin: 0 24px 24px 24px; */
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

/* 操作引导按钮样式 */
.operation-guide-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  color: #fff !important;
  border: none !important;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.operation-guide-btn:hover {
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4) !important;
  transform: translateY(-1px) !important;
  color: #fff !important;
}

.qa-scroll-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  min-height: 0;
  /* padding: 0 24px 24px 24px; */
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

/* 删除 QA 按钮样式 */
.delete-qa-btn {
  color: #ff4d4f;
}

.delete-qa-btn:hover {
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
  /* padding: 0 24px 24px 24px; */
}

.intent-wrapper {
  flex: 1;
  display: flex;
  gap: 16px;
  overflow: hidden;
}

/* 话术管理内容区域 */
.script-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
  padding: 0;
}

.script-scroll-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;
  width: 100%;
  /* padding: 0 24px 24px 24px; */
}

/* 话术管理子标签页 */
.script-sub-tabs {
  background: #fff;
  padding: 0 24px;
  margin-bottom: 16px;
}

.script-sub-tabs :deep(.ant-tabs-nav) {
  margin: 0;
}

.script-sub-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 录音包列表和录音详情列表 */
.audio-package-list,
.audio-detail-list {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 进度条单元格 */
.progress-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-cell .progress-text {
  font-size: 13px;
  color: #595959;
  white-space: nowrap;
}

/* 当前录音包名称 */
.current-package-name {
  font-size: 14px;
  color: #262626;
  font-weight: 500;
}

/* 顶部操作区 */
.script-toolbar-section {
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

.script-toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.script-toolbar-right {
  display: flex;
  align-items: center;
}

/* 话术列表 */
.script-list {
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  flex: 1;
  min-height: 0;
  overflow: hidden;
  padding: 16px 0;
}

.script-table-wrapper {
  flex: 1;
  overflow: auto;
  min-height: 0;
  padding: 0 16px;
}

.script-list :deep(.ant-table) {
  font-size: 13px;
}

.script-list :deep(.ant-table-wrapper) {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.script-list :deep(.ant-table-container) {
  flex: 1;
  overflow: auto;
}

.script-list :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
  white-space: nowrap;
}

.script-list :deep(.ant-table-fixed-right) {
  position: sticky;
  right: 0;
  z-index: 10;
  background: #fff;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.1);
}

.script-list :deep(.ant-table-cell-fix-right) {
  background: #fff;
}

.script-list :deep(.ant-table-fixed-header .ant-table-scroll-horizontal) {
  overflow-x: auto;
}

.script-reply-text {
  display: block;
  white-space: normal;
  line-height: 1.6;
  color: #333;
  max-height: 100px;
  overflow-y: auto;
}

.variable-name {
  font-family: monospace;
  color: #1890ff;
  background: #f0f5ff;
  padding: 2px 6px;
  border-radius: 3px;
}

.variable-value-text {
  cursor: pointer;
  color: #595959;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
}

.variable-value-text:hover {
  background: #f5f5f5;
  color: #1890ff;
}

.script-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: transparent;
  padding: 8px 16px;
  flex-shrink: 0;
}

.script-pagination .selected-count {
  color: #666;
  font-size: 13px;
}

/* 消保下拉菜单样式 */
.compliance-pass {
  color: #52c41a !important;
}

.compliance-pass .pass-text {
  color: #52c41a;
}

.compliance-reject {
  color: #ff4d4f !important;
}

.compliance-reject .reject-text {
  color: #ff4d4f;
}

/* 话术管理滚动条样式 */
.script-list::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.script-list::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 4px;
}

.script-list::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 4px;
}

.script-list::-webkit-scrollbar-thumb:hover {
  background: #999;
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
  padding: 16px 20px;
}

.intent-table-wrapper :deep(.ant-table) {
  font-size: 13px;
}

.intent-table-wrapper :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
}

/* 用户分类内容区域 */
.user-classify-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
  /* padding: 0 24px 24px 24px; */
}

.user-classify-wrapper {
  flex: 1;
  display: flex;
  gap: 16px;
  overflow: hidden;
}

/* 左侧分类列表 */
.classify-sidebar {
  width: 320px;
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

.category-item-right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.category-name {
  font-size: 14px;
  color: #595959;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.category-item.active .category-name {
  color: #1890ff;
  font-weight: 500;
}

.more-action-btn {
  color: #595959;
  font-size: 16px;
}

.more-action-btn:hover {
  color: #1890ff;
}

.delete-menu-item {
  color: #ff4d4f;
}

.delete-menu-item:hover {
  color: #ff7875;
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

.default-rule-alert-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 8px 12px;
  border-radius: 4px;
  flex-shrink: 0;
}

.default-rule-alert {
  padding: 0;
  background: transparent;
  border: none;
  color: #d4380d;
  font-size: 14px;
  flex: 1;
}

.save-btn-top-right {
  display: flex;
  justify-content: flex-end;
  margin-left: 16px;
  flex-shrink: 0;
}

.save-btn-top-right .ant-btn-primary {
  background: #1890ff;
  border-color: #1890ff;
}

.rule-list-container {
  flex: 1;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 16px;
  margin-bottom: 16px;
  background: #fff;
  display: flex;
  flex-direction: column;
  gap: 16px;
  overflow: hidden;
}

.saved-rule-list,
.editing-rule-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  overflow-y: auto;
  flex: 1;
  min-height: 0;
}

/* 规则列表滚动条样式 */
.saved-rule-list::-webkit-scrollbar,
.editing-rule-list::-webkit-scrollbar {
  width: 6px;
}

.saved-rule-list::-webkit-scrollbar-track,
.editing-rule-list::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 3px;
}

.saved-rule-list::-webkit-scrollbar-thumb,
.editing-rule-list::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 3px;
}

.saved-rule-list::-webkit-scrollbar-thumb:hover,
.editing-rule-list::-webkit-scrollbar-thumb:hover {
  background: #999;
}

.rule-item {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 16px;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  background: #fafafa;
}

.rule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 12px;
  border-bottom: 1px solid #e8e8e8;
}

.rule-index {
  font-size: 14px;
  font-weight: 500;
  color: #262626;
}

.rule-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.condition-display-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.condition-display-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 8px;
  background: #f5f5f5;
  border-radius: 4px;
  font-size: 13px;
}

.condition-field {
  color: #262626;
  font-weight: 500;
}

.condition-operator {
  color: #595959;
}

.condition-value {
  color: #1890ff;
}

.condition-connector {
  color: #faad14;
  font-weight: 500;
}

.rule-item-editing {
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 16px;
  background: #fff;
}

.editing-expression-wrapper {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
  margin-top: 12px;
}

.condition-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 4px;
}

.condition-item {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.condition-index {
  font-size: 13px;
  color: #595959;
  min-width: 60px;
}

.delete-expression-btn {
  color: #ff4d4f;
  font-size: 13px;
}

.delete-expression-btn:hover {
  color: #ff7875;
}

.rule-delete-action {
  padding-left: 16px;
}

.rule-delete-action .delete-btn {
  color: #ff4d4f;
  font-size: 18px;
}

.add-rule-btn-wrapper {
  display: flex;
  justify-content: flex-start;
  padding-top: 8px;
}

.rule-form-body {
  margin-top: 12px;
  width: 100%;
}

.rule-form-row {
  margin-bottom: 16px;
}

.condition-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.condition-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}

.condition-item:last-child {
  margin-bottom: 0;
}

.add-condition-btn {
  color: #1890ff !important;
}

.remove-condition-btn {
  color: #ff4d4f !important;
}

.condition-suffix {
  color: #666;
  font-size: 14px;
  white-space: nowrap;
}

/* 弹窗底部按钮区 */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 24px;
}

/* 上报语料确认弹窗内容 */
.report-pattern-confirm-content {
  padding: 8px 0;
}

.report-pattern-confirm-content .ant-alert {
  font-size: 14px;
  line-height: 1.5;
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
  min-width: 0;
}

.reply-actions {
  display: flex;
  flex-direction: column;
  gap: 6px;
  flex-shrink: 0;
  padding-top: 4px;
}

.ai-generate-btn,
.delete-reply-btn {
  padding: 4px 8px;
  font-size: 12px;
  white-space: nowrap;
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

/* 添加用户问法弹窗样式 */
.add-user-question-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.add-user-question-container .pattern-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  margin-bottom: 12px;
}

.add-user-question-container .pattern-toolbar .toolbar-left {
  display: flex;
  align-items: center;
}

.add-user-question-container .pattern-toolbar .toolbar-right {
  display: flex;
  align-items: center;
}

.add-user-question-container .pattern-toolbar .search-input {
  width: 200px;
}

.add-user-question-container .pattern-toolbar .ant-btn-sm {
  height: 32px;
  padding: 4px 11px;
  font-size: 14px;
}

.pattern-table-wrapper {
  border: 1px solid #f0f0f0;
  border-radius: 4px;
}

.pattern-table-wrapper .ant-table {
  font-size: 13px;
}

.pattern-text {
  word-break: break-all;
  display: block;
  min-height: 22px;
  line-height: 22px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
  cursor: pointer;
}

.pattern-text:hover {
  background-color: #f5f5f5;
  color: #1890ff;
}

.pattern-edit-wrapper {
  padding: 4px 8px;
}

.semantic-slot-table-wrapper {
  border: 1px solid #f0f0f0;
  border-radius: 4px;
}

.semantic-slot-table-wrapper .ant-table {
  font-size: 13px;
}

.slot-name {
  padding-bottom: 2px;
  font-weight: 500;
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
  /* padding: 0 24px 24px 24px; */
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

/* 流程兜底设置回复组样式 */
.fallback-reply-group {
  display: block;
}

.fallback-reply-content {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.fallback-reply-content .ant-textarea {
  flex: 1;
}

.fallback-reply-content .reply-actions {
  display: flex;
  gap: 4px;
  flex-shrink: 0;
  padding-top: 8px;
}

.reply-input-item {
  /* display: flex; */
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

.save-tip {
  color: #1890ff;
  font-size: 13px;
  margin-left: 8px;
  align-self: center;
}

/* ==================== 场景系统设置样式 ==================== */

.system-settings-content {
  height: calc(100vh - 120px);
  overflow: hidden;
  background: #f5f5f5;
}

.system-settings-wrapper {
  height: 100%;
  overflow-y: auto;
  /* padding: 24px; */
}

.settings-section {
  margin-bottom: 24px;
  padding: 24px;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
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
  line-height: 1.5;
}

.form-tip.error-text {
  color: #ff4d4f;
}

.link-text {
  color: #1890ff;
  text-decoration: none;
}

.link-text:hover {
  text-decoration: underline;
}

.help-icon {
  color: #8c8c8c;
  font-size: 14px;
  margin-left: 4px;
  cursor: help;
}

.required-label {
  color: #ff4d4f;
}

.required-label .label-text {
  color: #262626;
  font-size: 14px;
}

.checkbox-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin: 8px 0;
}

.checkbox-grid .ant-checkbox-wrapper {
  font-size: 13px;
  color: #595959;
}

.radio-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin: 8px 0;
}

.radio-group .ant-radio-wrapper {
  font-size: 14px;
  color: #595959;
  line-height: 1.5;
}

.success-text {
  color: #52c41a;
  font-weight: 500;
}

.error-text {
  color: #ff4d4f;
  font-weight: 500;
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
  /* padding: 0 24px 24px 24px; */
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
  min-height: 100%; /* 允许 flex 子项缩小 */
  height: 100%;
}

/* 画布工具栏 */
.canvas-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
  flex-shrink: 0; /* 防止工具栏被压缩 */
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

/* 节点添加栏（固定在画布区域顶部） */
.node-palette {
  position: relative;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  flex-shrink: 0; /* 防止被压缩 */
}

.palette-header {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  font-size: 13px;
  font-weight: 500;
  color: #262626;
  background: #fafafa;
  border-bottom: 1px solid #f0f0f0;
}

.palette-content {
  display: flex;
  gap: 8px;
  padding: 8px 16px;
  overflow-x: auto;
  background: #fff;
}

.palette-node-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: #f5f5f5;
  border-radius: 4px;
  cursor: grab;
  transition: all 0.3s;
  white-space: nowrap;
  user-select: none;
}

.palette-node-item:hover {
  background: #e6f7ff;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.palette-node-item:active {
  cursor: grabbing;
}

.palette-node-item .anticon {
  font-size: 18px;
  color: #1890ff;
  flex-shrink: 0;
}

.palette-node-item span {
  font-size: 13px;
  color: #595959;
}

/* 节点添加工具栏（悬浮在画布上） */
.node-add-toolbar {
  position: absolute;
  top: 16px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 100;
  background: #fff;
  padding: 8px 16px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
}

.node-add-toolbar .toolbar-label {
  font-size: 13px;
  color: #595959;
  font-weight: 500;
  margin-right: 8px;
}

.add-node-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 12px !important;
  font-size: 13px;
  border-radius: 4px;
  transition: all 0.3s;
}

.add-node-btn .anticon {
  font-size: 14px;
}

/* 画布 */
.process-canvas {
  flex: 1;
  overflow: auto;
  background: #f5f5f5;
  position: relative;
  min-height: 0; /* 允许 flex 子项缩小 */
}

.canvas-content {
  position: relative;
  width: 100%;
  height: 100%;
  box-sizing: border-box;
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

/* 连接线意图标签 */
.connection-intent-label {
  pointer-events: none;
}

.intent-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  justify-content: center;
  align-items: center;
  background: rgba(255, 255, 255, 0.95);
  padding: 4px 8px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

/* 意图选择列表 */
.intent-select-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  max-height: 200px;
  overflow-y: auto;
  padding: 8px;
  background: #fafafa;
  border-radius: 4px;
  border: 1px solid #e8e8e8;
}

.intent-select-list .ant-checkbox-wrapper {
  display: inline-flex;
  align-items: center;
}

/* 已选意图标签 */
.selected-intent-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  min-height: 32px;
  padding: 8px;
  background: #fafafa;
  border-radius: 4px;
  border: 1px solid #e8e8e8;
}

.selected-intent-tags .ant-tag {
  margin: 0;
}

/* ==================== 气泡引导样式 ==================== */

/* 遮罩层 */
.guide-mask {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 9998;
  pointer-events: none;
}

/* 高亮区域 - 使用 box-shadow 创建镂空效果 */
.guide-highlight {
  position: fixed;
  z-index: 9999;
  pointer-events: none;
  box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.5);
  border-radius: 4px;
  transition: top 0.3s cubic-bezier(0.4, 0, 0.2, 1), 
              left 0.3s cubic-bezier(0.4, 0, 0.2, 1),
              width 0.3s cubic-bezier(0.4, 0, 0.2, 1),
              height 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.guide-overlay {
  position: fixed;
  width: 300px;
  z-index: 9999;
}

/* 带过渡效果的引导框 */
.guide-overlay.guide-with-transition {
  transition: top 0.3s cubic-bezier(0.4, 0, 0.2, 1), left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.guide-popover {
  position: relative;
  z-index: 10000;
  width: 100%;
  background: #fff;
  border-radius: 6px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  padding: 12px 16px;
  animation: guide-popover-slide 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes guide-popover-slide {
  from {
    opacity: 0;
    transform: translateY(-5px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.guide-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.guide-step-indicator {
  font-size: 11px;
  color: #1890ff;
  font-weight: 500;
}

.guide-close-btn {
  color: #8c8c8c;
  font-size: 14px;
  padding: 0;
  width: 20px;
  height: 20px;
}

.guide-close-btn:hover {
  color: #595959;
}

.guide-body {
  margin-bottom: 12px;
}

.guide-title {
  font-size: 13px;
  font-weight: 500;
  color: #262626;
  margin: 0 0 6px 0;
}

.guide-description {
  font-size: 12px;
  color: #595959;
  line-height: 1.5;
  margin: 0;
}

.guide-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 10px;
  border-top: 1px solid #f0f0f0;
}

.guide-footer-first {
  justify-content: flex-end;
}

.guide-steps-indicator {
  display: flex;
  justify-content: center;
  gap: 6px;
  margin-top: 10px;
}

.step-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #d9d9d9;
  cursor: pointer;
  transition: all 0.3s;
}

.step-dot.active {
  width: 16px;
  border-radius: 3px;
  background: #1890ff;
}

.step-dot:hover {
  background: #40a9ff;
}

/* 右下角重新引导按钮 */
.restart-guide-btn {
  position: fixed;
  right: 24px;
  bottom: 24px;
  z-index: 999;
  width: 48px;
  height: 48px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.restart-guide-btn:hover {
  transform: scale(1.1);
}

/* ==================== 场景短信样式 ==================== */

/* 场景短信内容区域 */
.sms-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
  padding: 0;
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
</style>
