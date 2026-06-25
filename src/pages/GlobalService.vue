<template>
  <div class="global-service-page">
    <div class="global-service-wrapper">
      <!-- 配置标签页 -->
      <div class="config-tabs-section">
        <div class="tabs-scroll-wrapper" ref="tabsWrapperRef">
          <div v-show="showLeftArrow" class="tabs-arrow tabs-arrow-left" @click="scrollTabs('left')">
            <left-outlined />
          </div>
          <a-tabs v-model:activeKey="activeTab" tab-position="top" size="middle">
          <!-- 1. 防骚扰策略 -->
          <a-tab-pane key="harassment" tab="防骚扰策略">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">呼叫频率限制</h3>
                  <p class="section-desc">限制对同一号码的呼叫频率，防止对客户造成骚扰。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="同一号码每日最大呼叫次数">
                        <a-input-number v-model:value="harassmentForm.maxDailyCalls" :min="1" :max="100" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="同一号码每周最大呼叫次数">
                        <a-input-number v-model:value="harassmentForm.maxWeeklyCalls" :min="1" :max="500" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="两次呼叫最小间隔（分钟）">
                        <a-input-number v-model:value="harassmentForm.minCallInterval" :min="1" :max="1440" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="超限处理方式">
                        <a-select v-model:value="harassmentForm.overLimitAction" placeholder="请选择">
                          <a-select-option value="block">自动拦截</a-select-option>
                          <a-select-option value="warn">仅警告</a-select-option>
                          <a-select-option value="addBlacklist">加入黑名单</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="客户明确拒绝后冷却天数">
                        <a-input-number v-model:value="harassmentForm.coolingDays" :min="1" :max="365" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="启用防骚扰策略">
                        <a-switch v-model:checked="harassmentForm.enabled" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('harassment')">重置</a-button>
                  <a-button type="primary" @click="handleSave('harassment')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 2. 免打扰名单策略 -->
          <a-tab-pane key="dnd" tab="免打扰名单策略">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">免打扰规则</h3>
                  <p class="section-desc">管理免打扰名单，支持手动添加、批量导入和自动同步。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="免打扰时段开始时间">
                        <a-time-picker v-model:value="dndForm.startTime" format="HH:mm" style="width: 100%" placeholder="选择开始时间" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="免打扰时段结束时间">
                        <a-time-picker v-model:value="dndForm.endTime" format="HH:mm" style="width: 100%" placeholder="选择结束时间" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="启用免打扰策略">
                        <a-switch v-model:checked="dndForm.enabled" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="名单有效期（天）">
                        <a-input-number v-model:value="dndForm.validDays" :min="1" :max="365" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="到期自动移除">
                        <a-switch v-model:checked="dndForm.autoRemove" checked-children="是" un-checked-children="否" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="客户拒绝后自动加入">
                        <a-switch v-model:checked="dndForm.autoAddOnReject" checked-children="是" un-checked-children="否" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-form-item label="批量导入号码">
                    <a-upload :file-list="dndFileList" :before-upload="handleDndUpload" :on-remove="handleDndRemove">
                      <a-button>
                        <upload-outlined />
                        选择文件
                      </a-button>
                      <span class="upload-hint">支持 .xlsx、.csv 格式，每行一个号码</span>
                    </a-upload>
                  </a-form-item>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('dnd')">重置</a-button>
                  <a-button type="primary" @click="handleSave('dnd')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 3. 拨打时间段设置 -->
          <a-tab-pane key="callTime" tab="拨打时间段设置">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">允许拨打时间段</h3>
                  <p class="section-desc">设置系统允许外呼的时间范围，非工作时间段将自动禁止拨打。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="工作日拨打开始时间">
                        <a-time-picker v-model:value="callTimeForm.weekdayStart" format="HH:mm" style="width: 100%" placeholder="选择时间" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="工作日拨打结束时间">
                        <a-time-picker v-model:value="callTimeForm.weekdayEnd" format="HH:mm" style="width: 100%" placeholder="选择时间" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="时区">
                        <a-select v-model:value="callTimeForm.timezone" placeholder="请选择时区">
                          <a-select-option value="Asia/Shanghai">中国标准时间 (UTC+8)</a-select-option>
                          <a-select-option value="Asia/Hong_Kong">香港时间 (UTC+8)</a-select-option>
                          <a-select-option value="Asia/Taipei">台北时间 (UTC+8)</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="周末允许拨打">
                        <a-switch v-model:checked="callTimeForm.weekendEnabled" checked-children="是" un-checked-children="否" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="节假日允许拨打">
                        <a-switch v-model:checked="callTimeForm.holidayEnabled" checked-children="是" un-checked-children="否" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="法定节假日自动禁拨">
                        <a-switch v-model:checked="callTimeForm.autoHolidayBlock" checked-children="是" un-checked-children="否" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('callTime')">重置</a-button>
                  <a-button type="primary" @click="handleSave('callTime')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 4. 邮件服务设置 -->
          <a-tab-pane key="email" tab="邮件服务设置">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">SMTP 服务器配置</h3>
                  <p class="section-desc">配置系统邮件发送服务，用于报表推送、告警通知等场景。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="SMTP 服务器地址">
                        <a-input v-model:value="emailForm.smtpHost" placeholder="请输入 SMTP 服务器地址" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="端口号">
                        <a-input-number v-model:value="emailForm.smtpPort" :min="1" :max="65535" style="width: 100%" placeholder="请输入端口号" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="加密方式">
                        <a-select v-model:value="emailForm.encryption" placeholder="请选择加密方式">
                          <a-select-option value="ssl">SSL</a-select-option>
                          <a-select-option value="tls">TLS</a-select-option>
                          <a-select-option value="none">无加密</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="用户名">
                        <a-input v-model:value="emailForm.username" placeholder="请输入邮箱用户名" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="密码">
                        <a-input-password v-model:value="emailForm.password" placeholder="请输入邮箱密码" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="发件人名称">
                        <a-input v-model:value="emailForm.senderName" placeholder="请输入发件人显示名称" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-form-item>
                    <a-space>
                      <a-button @click="handleTestEmail">
                        <send-outlined />
                        发送测试邮件
                      </a-button>
                      <a-input v-model:value="emailForm.testRecipient" placeholder="测试收件邮箱" style="width: 240px" />
                    </a-space>
                  </a-form-item>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('email')">重置</a-button>
                  <a-button type="primary" @click="handleSave('email')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 5. 语音服务设置 -->
          <a-tab-pane key="voice" tab="语音服务设置">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">TTS 语音引擎</h3>
                  <p class="section-desc">配置文本转语音引擎参数，用于 AI 外呼场景的语音合成。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="TTS 引擎">
                        <a-select v-model:value="voiceForm.engine" placeholder="请选择 TTS 引擎">
                          <a-select-option value="aliyun">阿里云 TTS</a-select-option>
                          <a-select-option value="tencent">腾讯云 TTS</a-select-option>
                          <a-select-option value="baidu">百度 TTS</a-select-option>
                          <a-select-option value="custom">自定义引擎</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="语音音色">
                        <a-select v-model:value="voiceForm.voice" placeholder="请选择音色">
                          <a-select-option value="xiaoyun">小云（女声）</a-select-option>
                          <a-select-option value="xiaogang">小刚（男声）</a-select-option>
                          <a-select-option value="xiaomei">小美（女声）</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="语速（0.5~2.0）">
                        <a-slider v-model:value="voiceForm.speed" :min="0.5" :max="2.0" :step="0.1" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="音量（0~100）">
                        <a-slider v-model:value="voiceForm.volume" :min="0" :max="100" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="采样率">
                        <a-select v-model:value="voiceForm.sampleRate" placeholder="请选择采样率">
                          <a-select-option value="8000">8000 Hz</a-select-option>
                          <a-select-option value="16000">16000 Hz</a-select-option>
                          <a-select-option value="24000">24000 Hz</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="启用语音服务">
                        <a-switch v-model:checked="voiceForm.enabled" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('voice')">重置</a-button>
                  <a-button type="primary" @click="handleSave('voice')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 6. 通话规则配置 -->
          <a-tab-pane key="callRule" tab="通话规则配置">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">通话基本规则</h3>
                  <p class="section-desc">设置通话时长限制、超时处理、转接规则等基础通话参数。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="最大通话时长（秒）">
                        <a-input-number v-model:value="callRuleForm.maxDuration" :min="30" :max="7200" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="无人接听超时（秒）">
                        <a-input-number v-model:value="callRuleForm.noAnswerTimeout" :min="5" :max="120" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="最大重拨次数">
                        <a-input-number v-model:value="callRuleForm.maxRetries" :min="0" :max="10" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="重拨间隔（分钟）">
                        <a-input-number v-model:value="callRuleForm.retryInterval" :min="1" :max="1440" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="超时自动挂断">
                        <a-switch v-model:checked="callRuleForm.autoHangup" checked-children="是" un-checked-children="否" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="通话录音">
                        <a-switch v-model:checked="callRuleForm.recording" checked-children="开启" un-checked-children="关闭" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="未接通处理方式">
                        <a-select v-model:value="callRuleForm.noAnswerAction" placeholder="请选择">
                          <a-select-option value="retry">稍后重拨</a-select-option>
                          <a-select-option value="skip">跳过该号码</a-select-option>
                          <a-select-option value="sms">发送短信通知</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="通话结束自动评分">
                        <a-switch v-model:checked="callRuleForm.autoScore" checked-children="是" un-checked-children="否" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="静音检测超时（秒）">
                        <a-input-number v-model:value="callRuleForm.silenceTimeout" :min="5" :max="120" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('callRule')">重置</a-button>
                  <a-button type="primary" @click="handleSave('callRule')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 7. 拨打速率规则设置 -->
          <a-tab-pane key="dialRate" tab="拨打速率规则设置">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">并发与速率控制</h3>
                  <p class="section-desc">设置系统拨打并发数、速率限制和重试策略，保障外呼稳定性。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="最大并发呼叫数">
                        <a-input-number v-model:value="dialRateForm.maxConcurrent" :min="1" :max="1000" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="每秒最大呼叫数 (CPS)">
                        <a-input-number v-model:value="dialRateForm.maxCPS" :min="1" :max="100" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="线路利用率上限 (%)">
                        <a-input-number v-model:value="dialRateForm.lineUtilization" :min="10" :max="100" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="溢出策略">
                        <a-select v-model:value="dialRateForm.overflowStrategy" placeholder="请选择">
                          <a-select-option value="queue">排队等待</a-select-option>
                          <a-select-option value="drop">丢弃任务</a-select-option>
                          <a-select-option value="callback">延迟回拨</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="自动降速阈值（失败率 %）">
                        <a-input-number v-model:value="dialRateForm.failRateThreshold" :min="1" :max="100" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="启用速率控制">
                        <a-switch v-model:checked="dialRateForm.enabled" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('dialRate')">重置</a-button>
                  <a-button type="primary" @click="handleSave('dialRate')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 8. 短信模版 -->
          <a-tab-pane key="sms" tab="短信模版">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <div class="section-header-row">
                    <div>
                      <h3 class="section-title">短信模版管理</h3>
                      <p class="section-desc">管理系统短信模版，支持变量替换，用于营销通知、验证码等场景。</p>
                    </div>
                    <a-button type="primary" @click="handleAddSmsTemplate">
                      <plus-outlined />
                      新建模版
                    </a-button>
                  </div>
                </div>
                <a-table
                  :columns="smsColumns"
                  :data-source="smsTemplateList"
                  :pagination="false"
                  row-key="id"
                  bordered
                >
                  <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'status'">
                      <a-tag :color="record.status === 'approved' ? 'green' : record.status === 'pending' ? 'orange' : 'red'">
                        {{ record.status === 'approved' ? '已审核' : record.status === 'pending' ? '待审核' : '已拒绝' }}
                      </a-tag>
                    </template>
                    <template v-else-if="column.key === 'action'">
                      <a-space>
                        <a-button type="link" size="small" @click="handleEditSmsTemplate(record)">编辑</a-button>
                        <a-button type="link" size="small" danger @click="handleDeleteSmsTemplate(record)">删除</a-button>
                      </a-space>
                    </template>
                  </template>
                </a-table>
              </div>
            </div>
          </a-tab-pane>

          <!-- 9. 移动端设置 -->
          <a-tab-pane key="mobile" tab="移动端设置">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">移动端推送配置</h3>
                  <p class="section-desc">配置移动端 APP 推送通知、消息提醒等参数。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="推送服务提供商">
                        <a-select v-model:value="mobileForm.pushProvider" placeholder="请选择">
                          <a-select-option value="jiguang">极光推送</a-select-option>
                          <a-select-option value="getui">个推</a-select-option>
                          <a-select-option value="firebase">Firebase</a-select-option>
                          <a-select-option value="huawei">华为推送</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="APP Key">
                        <a-input v-model:value="mobileForm.appKey" placeholder="请输入 APP Key" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="APP Secret">
                        <a-input-password v-model:value="mobileForm.appSecret" placeholder="请输入 APP Secret" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="启用推送通知">
                        <a-switch v-model:checked="mobileForm.pushEnabled" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="新任务提醒">
                        <a-switch v-model:checked="mobileForm.newTaskAlert" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="告警通知">
                        <a-switch v-model:checked="mobileForm.alertNotification" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="免打扰时段开始">
                        <a-time-picker v-model:value="mobileForm.dndStart" format="HH:mm" style="width: 100%" placeholder="选择时间" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="免打扰时段结束">
                        <a-time-picker v-model:value="mobileForm.dndEnd" format="HH:mm" style="width: 100%" placeholder="选择时间" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('mobile')">重置</a-button>
                  <a-button type="primary" @click="handleSave('mobile')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 10. 数据导入规则设置 -->
          <a-tab-pane key="dataImport" tab="数据导入规则设置">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">导入规则配置</h3>
                  <p class="section-desc">设置数据导入的文件格式、字段映射、去重规则等参数。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="支持的文件格式">
                        <a-select v-model:value="dataImportForm.fileFormats" mode="multiple" placeholder="请选择支持格式">
                          <a-select-option value="xlsx">Excel (.xlsx)</a-select-option>
                          <a-select-option value="csv">CSV (.csv)</a-select-option>
                          <a-select-option value="txt">文本 (.txt)</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="单次最大导入行数">
                        <a-input-number v-model:value="dataImportForm.maxRows" :min="100" :max="1000000" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="最大文件大小 (MB)">
                        <a-input-number v-model:value="dataImportForm.maxFileSize" :min="1" :max="500" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="去重规则">
                        <a-select v-model:value="dataImportForm.dedupRule" placeholder="请选择">
                          <a-select-option value="phone">按手机号去重</a-select-option>
                          <a-select-option value="idcard">按身份证号去重</a-select-option>
                          <a-select-option value="none">不去重</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="重复数据处理">
                        <a-select v-model:value="dataImportForm.dupAction" placeholder="请选择">
                          <a-select-option value="skip">跳过</a-select-option>
                          <a-select-option value="overwrite">覆盖</a-select-option>
                          <a-select-option value="merge">合并</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="导入后自动分配任务">
                        <a-switch v-model:checked="dataImportForm.autoAssign" checked-children="是" un-checked-children="否" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-form-item label="默认字段映射">
                    <div class="field-mapping-hint">系统将根据表头自动匹配字段，可在导入时手动调整</div>
                  </a-form-item>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('dataImport')">重置</a-button>
                  <a-button type="primary" @click="handleSave('dataImport')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 11. 小象通服务器设置 -->
          <a-tab-pane key="server" tab="小象通服务器设置">
            <div class="tab-content">
              <div class="section-card">
                <div class="section-header">
                  <h3 class="section-title">服务器连接配置</h3>
                  <p class="section-desc">配置小象通平台服务器连接参数，包括地址、端口和认证信息。</p>
                </div>
                <a-form layout="vertical">
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="服务器地址">
                        <a-input v-model:value="serverForm.host" placeholder="请输入服务器地址" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="端口号">
                        <a-input-number v-model:value="serverForm.port" :min="1" :max="65535" style="width: 100%" placeholder="请输入端口号" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="协议类型">
                        <a-select v-model:value="serverForm.protocol" placeholder="请选择协议">
                          <a-select-option value="https">HTTPS</a-select-option>
                          <a-select-option value="http">HTTP</a-select-option>
                          <a-select-option value="wss">WSS</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="API Key">
                        <a-input-password v-model:value="serverForm.apiKey" placeholder="请输入 API Key" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="API Secret">
                        <a-input-password v-model:value="serverForm.apiSecret" placeholder="请输入 API Secret" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="连接超时（秒）">
                        <a-input-number v-model:value="serverForm.timeout" :min="5" :max="120" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="24">
                    <a-col :span="8">
                      <a-form-item label="心跳间隔（秒）">
                        <a-input-number v-model:value="serverForm.heartbeat" :min="5" :max="300" style="width: 100%" placeholder="请输入" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="自动重连">
                        <a-switch v-model:checked="serverForm.autoReconnect" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item label="启用服务">
                        <a-switch v-model:checked="serverForm.enabled" checked-children="开" un-checked-children="关" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-form-item>
                    <a-button type="primary" ghost @click="handleTestConnection">
                      <api-outlined />
                      测试连接
                    </a-button>
                  </a-form-item>
                </a-form>
              </div>
              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('server')">重置</a-button>
                  <a-button type="primary" @click="handleSave('server')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>

          <!-- 12. 全局操作管理 -->
          <a-tab-pane key="operation" tab="全局操作管理">
            <div class="tab-content">
              <!-- 1. 报表引擎维度同步 -->
              <div class="func-module">
                <div class="func-module-header">
                  <div class="func-module-info">
                    <h3 class="func-module-title">报表引擎维度同步</h3>
                    <p class="func-module-desc">手动同步场景、批次、机构、坐席、主叫号码等基础维度数据，用于系统初始化或修复报表统计数据缺失。</p>
                  </div>
                  <a-button type="primary" :loading="operationSyncing" @click="handleSyncDimensions">
                    <sync-outlined />
                    立即同步
                  </a-button>
                </div>
              </div>

              <!-- 2. 虚拟号查询真实号码展示 -->
              <div class="func-module">
                <div class="func-module-header">
                  <div class="func-module-info">
                    <h3 class="func-module-title">虚拟号查询真实号码展示</h3>
                    <p class="func-module-desc">开启后，坐席在"去跟进"页面查看客户时，系统自动通过虚拟号查询对应的真实号码并展示。</p>
                  </div>
                  <a-switch v-model:checked="operationForm.showRealNumber" checked-children="开" un-checked-children="关" />
                </div>
                <div v-if="operationForm.showRealNumber" class="func-module-body">
                  <div class="sub-option-row">
                    <span class="sub-option-label">展示方式：</span>
                    <a-radio-group v-model:value="operationForm.realNumberDisplayMode">
                      <a-radio value="fixedMask">固定脱敏展示（统一打码）</a-radio>
                      <a-radio value="permissionMask">按脱敏权限展示（根据坐席数据权限决定）</a-radio>
                    </a-radio-group>
                  </div>
                </div>
              </div>

              <!-- 3. 全局导出限制功能 -->
              <div class="func-module">
                <div class="func-module-header">
                  <div class="func-module-info">
                    <h3 class="func-module-title">全局导出限制功能</h3>
                    <p class="func-module-desc">开启后，仅在周一至周五 9:00-18:00 允许导出数据；且单次导出最多选择 31 天的数据范围（覆盖工作台任务列表、AI/人工外呼记录等模块）。</p>
                  </div>
                  <a-switch v-model:checked="operationForm.exportLimit" checked-children="开" un-checked-children="关" />
                </div>
              </div>

              <!-- 4. 通话录音转文本 -->
              <div class="func-module">
                <div class="func-module-header">
                  <div class="func-module-info">
                    <h3 class="func-module-title">通话录音转文本</h3>
                    <p class="func-module-desc">开启后，系统在通话结束后自动将录音转写为文字。覆盖人工通话录音，以及人机协同模式中的人工服务部分录音。</p>
                  </div>
                  <a-switch v-model:checked="operationForm.recordingToText" checked-children="开" un-checked-children="关" />
                </div>
                <div v-if="operationForm.recordingToText" class="func-module-body">
                  <div class="sub-option-row">
                    <span class="sub-option-label">执行时间段：</span>
                    <a-time-picker
                      v-model:value="operationForm.recordingToTextStart"
                      format="HH:mm"
                      :minute-step="30"
                      style="width: 120px"
                      placeholder="开始时间"
                      @change="handleRecordingTimeChange"
                    />
                    <span class="sub-option-separator">~</span>
                    <a-checkbox v-model:checked="operationForm.recordingToTextNextDay" class="next-day-checkbox" @change="handleRecordingNextDayChange">次日</a-checkbox>
                    <a-time-picker
                      v-model:value="operationForm.recordingToTextEnd"
                      format="HH:mm"
                      :minute-step="30"
                      style="width: 120px"
                      placeholder="结束时间"
                      :disabled-time="getDisabledEndTime"
                      @change="handleRecordingTimeChange"
                    />
                  </div>
                </div>
              </div>

              <div class="tab-footer">
                <a-space>
                  <a-button @click="handleReset('operation')">重置</a-button>
                  <a-button type="primary" @click="handleSave('operation')">保存配置</a-button>
                </a-space>
              </div>
            </div>
          </a-tab-pane>
        </a-tabs>
        </div>
      </div>
    </div>

    <!-- 短信模版编辑弹窗 -->
    <a-modal
      v-model:open="smsModalVisible"
      :title="smsModalEditing ? '编辑短信模版' : '新建短信模版'"
      width="600px"
      @ok="handleSmsModalOk"
      @cancel="smsModalVisible = false"
    >
      <a-form layout="vertical">
        <a-form-item label="模版名称">
          <a-input v-model:value="smsForm.name" placeholder="请输入模版名称" />
        </a-form-item>
        <a-form-item label="模版编码">
          <a-input v-model:value="smsForm.code" placeholder="请输入模版编码" />
        </a-form-item>
        <a-form-item label="短信内容">
          <a-textarea v-model:value="smsForm.content" placeholder="请输入短信内容，支持变量如 {姓名}、{电话}" :rows="4" />
        </a-form-item>
        <a-form-item>
          <div class="sms-var-hint">
            可用变量：<a-tag v-for="v in smsVariables" :key="v" color="blue">{{ v }}</a-tag>
          </div>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { message, type UploadFile } from 'ant-design-vue'
import {
  PlusOutlined,
  UploadOutlined,
  SendOutlined,
  ApiOutlined,
  LeftOutlined,
  SyncOutlined
} from '@ant-design/icons-vue'

// ============ Tab 状态 ============
const activeTab = ref('harassment')

// ============ Tab 滚动箭头 ============
const tabsWrapperRef = ref<HTMLElement>()
const showLeftArrow = ref(false)
const showRightArrow = ref(false)

const getTabsNav = (): HTMLElement | null => {
  return tabsWrapperRef.value?.querySelector('.ant-tabs-nav-wrap') as HTMLElement || null
}

const updateArrowVisibility = () => {
  const nav = getTabsNav()
  if (!nav) return
  const { scrollLeft, scrollWidth, clientWidth } = nav
  showLeftArrow.value = scrollLeft > 2
  showRightArrow.value = scrollLeft < scrollWidth - clientWidth - 2
}

const scrollTabs = (direction: 'left' | 'right') => {
  const nav = getTabsNav()
  if (!nav) return
  const offset = direction === 'left' ? -200 : 200
  nav.scrollBy({ left: offset, behavior: 'smooth' })
  setTimeout(updateArrowVisibility, 350)
}

const handleTabsScroll = () => {
  updateArrowVisibility()
}

onMounted(async () => {
  await nextTick()
  const nav = getTabsNav()
  if (nav) {
    nav.addEventListener('scroll', handleTabsScroll, { passive: true })
    updateArrowVisibility()
  }
  window.addEventListener('resize', updateArrowVisibility)
})

onBeforeUnmount(() => {
  const nav = getTabsNav()
  if (nav) {
    nav.removeEventListener('scroll', handleTabsScroll)
  }
  window.removeEventListener('resize', updateArrowVisibility)
})

// ============ 1. 防骚扰策略 ============
const harassmentForm = reactive({
  maxDailyCalls: 3,
  maxWeeklyCalls: 10,
  minCallInterval: 60,
  overLimitAction: 'block',
  coolingDays: 30,
  enabled: true
})

// ============ 2. 免打扰名单策略 ============
const dndForm = reactive({
  startTime: null as any,
  endTime: null as any,
  validDays: 90,
  autoRemove: true,
  autoAddOnReject: true,
  enabled: true
})
const dndFileList = ref<UploadFile[]>([])
const handleDndUpload = (file: UploadFile) => {
  dndFileList.value = [file]
  return false
}
const handleDndRemove = () => {
  dndFileList.value = []
}

// ============ 3. 拨打时间段设置 ============
const callTimeForm = reactive({
  weekdayStart: null as any,
  weekdayEnd: null as any,
  timezone: 'Asia/Shanghai',
  weekendEnabled: false,
  holidayEnabled: false,
  autoHolidayBlock: true
})

// ============ 4. 邮件服务设置 ============
const emailForm = reactive({
  smtpHost: '',
  smtpPort: 465,
  encryption: 'ssl',
  username: '',
  password: '',
  senderName: '',
  testRecipient: ''
})
const handleTestEmail = () => {
  if (!emailForm.testRecipient) {
    message.warning('请输入测试收件邮箱')
    return
  }
  message.success('测试邮件已发送，请查收')
}

// ============ 5. 语音服务设置 ============
const voiceForm = reactive({
  engine: 'aliyun',
  voice: 'xiaoyun',
  speed: 1.0,
  volume: 80,
  sampleRate: '16000',
  enabled: true
})

// ============ 6. 通话规则配置 ============
const callRuleForm = reactive({
  maxDuration: 1800,
  noAnswerTimeout: 30,
  maxRetries: 3,
  retryInterval: 60,
  autoHangup: true,
  recording: true,
  noAnswerAction: 'retry',
  autoScore: false,
  silenceTimeout: 30
})

// ============ 7. 拨打速率规则设置 ============
const dialRateForm = reactive({
  maxConcurrent: 50,
  maxCPS: 10,
  lineUtilization: 80,
  overflowStrategy: 'queue',
  failRateThreshold: 20,
  enabled: true
})

// ============ 8. 短信模版 ============
const smsColumns = [
  { title: '模版编码', dataIndex: 'code', key: 'code', width: 120 },
  { title: '模版名称', dataIndex: 'name', key: 'name', width: 150 },
  { title: '短信内容', dataIndex: 'content', key: 'content', ellipsis: true },
  { title: '审核状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 120 }
]

const smsTemplateList = ref([
  { id: 1, code: 'TPL_001', name: '营销通知', content: '尊敬的{姓名}，我们为您推荐{产品名称}，详情请咨询{电话}。', status: 'approved' },
  { id: 2, code: 'TPL_002', name: '回访提醒', content: '{姓名}您好，{坐席名称}将为您进行服务回访，请保持电话畅通。', status: 'approved' },
  { id: 3, code: 'TPL_003', name: '满意度调查', content: '{姓名}您好，感谢您接受我们的服务，请回复数字评价：1非常满意 2满意 3一般 4不满意。', status: 'pending' }
])

const smsModalVisible = ref(false)
const smsModalEditing = ref(false)
const smsForm = reactive({ name: '', code: '', content: '' })
const smsVariables = ['{姓名}', '{电话}', '{产品名称}', '{坐席名称}', '{日期}', '{时间}']

const handleAddSmsTemplate = () => {
  smsModalEditing.value = false
  Object.assign(smsForm, { name: '', code: '', content: '' })
  smsModalVisible.value = true
}
const handleEditSmsTemplate = (record: any) => {
  smsModalEditing.value = true
  Object.assign(smsForm, { name: record.name, code: record.code, content: record.content })
  smsModalVisible.value = true
}
const handleDeleteSmsTemplate = (record: any) => {
  smsTemplateList.value = smsTemplateList.value.filter(t => t.id !== record.id)
  message.success('删除成功')
}
const handleSmsModalOk = () => {
  if (!smsForm.name || !smsForm.code || !smsForm.content) {
    message.warning('请填写完整信息')
    return
  }
  if (smsModalEditing.value) {
    const item = smsTemplateList.value.find(t => t.code === smsForm.code)
    if (item) {
      Object.assign(item, { name: smsForm.name, content: smsForm.content })
    }
    message.success('修改成功')
  } else {
    smsTemplateList.value.push({
      id: Date.now(),
      code: smsForm.code,
      name: smsForm.name,
      content: smsForm.content,
      status: 'pending'
    })
    message.success('创建成功')
  }
  smsModalVisible.value = false
}

// ============ 9. 移动端设置 ============
const mobileForm = reactive({
  pushProvider: 'jiguang',
  appKey: '',
  appSecret: '',
  pushEnabled: true,
  newTaskAlert: true,
  alertNotification: true,
  dndStart: null as any,
  dndEnd: null as any
})

// ============ 10. 数据导入规则设置 ============
const dataImportForm = reactive({
  fileFormats: ['xlsx', 'csv'],
  maxRows: 100000,
  maxFileSize: 50,
  dedupRule: 'phone',
  dupAction: 'skip',
  autoAssign: false
})

// ============ 11. 小象通服务器设置 ============
const serverForm = reactive({
  host: '',
  port: 443,
  protocol: 'https',
  apiKey: '',
  apiSecret: '',
  timeout: 30,
  heartbeat: 60,
  autoReconnect: true,
  enabled: true
})
const handleTestConnection = () => {
  if (!serverForm.host) {
    message.warning('请输入服务器地址')
    return
  }
  message.success('连接测试成功')
}

// ============ 12. 全局操作管理 ============
const operationSyncing = ref(false)
const operationForm = reactive({
  showRealNumber: false,
  realNumberDisplayMode: 'fixedMask',
  exportLimit: false,
  recordingToText: false,
  recordingToTextStart: null as any,
  recordingToTextEnd: null as any,
  recordingToTextNextDay: false
})

const handleSyncDimensions = () => {
  operationSyncing.value = true
  setTimeout(() => {
    operationSyncing.value = false
    message.success('维度数据同步完成')
  }, 2000)
}

// 次日模式下，结束时间不得大于开始时间
const getDisabledEndTime = () => {
  if (!operationForm.recordingToTextNextDay || !operationForm.recordingToTextStart) return {}
  const startHour = operationForm.recordingToTextStart.hour()
  const startMinute = operationForm.recordingToTextStart.minute()
  return {
    disabledHours: () => {
      const disabled: number[] = []
      for (let i = startHour + 1; i < 24; i++) disabled.push(i)
      return disabled
    },
    disabledMinutes: (selectedHour: number) => {
      if (selectedHour === startHour) {
        const disabled: number[] = []
        for (let i = startMinute + 1; i < 60; i++) disabled.push(i)
        return disabled
      }
      return []
    }
  }
}

const handleRecordingTimeChange = () => {
  if (!operationForm.recordingToTextNextDay || !operationForm.recordingToTextStart || !operationForm.recordingToTextEnd) return
  const start = operationForm.recordingToTextStart.hour() * 60 + operationForm.recordingToTextStart.minute()
  const end = operationForm.recordingToTextEnd.hour() * 60 + operationForm.recordingToTextEnd.minute()
  if (end > start) {
    operationForm.recordingToTextEnd = null
    message.warning('次日模式下，结束时间不得大于开始时间')
  }
}

const handleRecordingNextDayChange = () => {
  // 勾选次日时校验当前结束时间
  if (operationForm.recordingToTextNextDay && operationForm.recordingToTextStart && operationForm.recordingToTextEnd) {
    const start = operationForm.recordingToTextStart.hour() * 60 + operationForm.recordingToTextStart.minute()
    const end = operationForm.recordingToTextEnd.hour() * 60 + operationForm.recordingToTextEnd.minute()
    if (end > start) {
      operationForm.recordingToTextEnd = null
      message.warning('次日模式下，结束时间不得大于开始时间，请重新选择')
    }
  }
}

// ============ 通用操作 ============
const handleSave = (module: string) => {
  message.success(`${getModuleName(module)} 配置已保存`)
}

const handleReset = (module: string) => {
  message.info(`${getModuleName(module)} 配置已重置`)
}

const getModuleName = (key: string): string => {
  const map: Record<string, string> = {
    harassment: '防骚扰策略',
    dnd: '免打扰名单策略',
    callTime: '拨打时间段设置',
    email: '邮件服务设置',
    voice: '语音服务设置',
    callRule: '通话规则配置',
    dialRate: '拨打速率规则设置',
    mobile: '移动端设置',
    dataImport: '数据导入规则设置',
    server: '小象通服务器设置',
    operation: '全局操作管理'
  }
  return map[key] || key
}
</script>

<style scoped>
.global-service-page {
  padding: 16px;
  background-color: #f5f7fb;
  min-height: 100vh;
}

.global-service-wrapper {
  max-width: 1400px;
  margin: 0 auto;
}

/* 配置标签页 */
.config-tabs-section {
  background: #fff;
  border-radius: 4px;
  padding: 16px 24px;
}

/* Tab 滚动箭头 */
.tabs-scroll-wrapper {
  position: relative;
}

.tabs-arrow {
  position: absolute;
  top: 4px;
  z-index: 10;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 14px;
  color: #8f959e;
  transition: color 0.2s;
}

.tabs-arrow:hover {
  color: #1677ff;
}

.tabs-arrow-left {
  left: 0;
}

.config-tabs-section :deep(.ant-tabs-nav-wrap) {
  overflow-x: auto;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.config-tabs-section :deep(.ant-tabs-nav-wrap::-webkit-scrollbar) {
  display: none;
}

.config-tabs-section :deep(.ant-tabs-nav) {
  margin-bottom: 0;
  padding: 0 36px;
}

.config-tabs-section :deep(.ant-tabs-nav-more) {
  display: none !important;
}

.config-tabs-section :deep(.ant-tabs-tab) {
  padding: 12px 16px;
  font-size: 14px;
}

/* 标签页内容 */
.tab-content {
  padding: 24px 0;
}

.section-card {
  background: #fafafa;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 24px;
  margin-bottom: 16px;
}

.section-header {
  margin-bottom: 20px;
}

.section-header-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2329;
  margin: 0 0 4px 0;
}

.section-desc {
  font-size: 13px;
  color: #8f959e;
  margin: 0;
}

/* 底部操作栏 */
.tab-footer {
  display: flex;
  justify-content: flex-end;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

/* 短信模版变量提示 */
.sms-var-hint {
  font-size: 13px;
  color: #8f959e;
}

/* 字段映射提示 */
.field-mapping-hint {
  font-size: 13px;
  color: #8f959e;
  padding: 12px 16px;
  background: #f0f5ff;
  border: 1px solid #d6e4ff;
  border-radius: 4px;
}

/* 上传提示 */
.upload-hint {
  font-size: 12px;
  color: #8f959e;
  margin-left: 12px;
}

/* 表单项间距优化 */
.config-tabs-section :deep(.ant-form-item) {
  margin-bottom: 16px;
}

.config-tabs-section :deep(.ant-form-item-label > label) {
  font-size: 13px;
  color: #595959;
}

/* 表格样式 */
.config-tabs-section :deep(.ant-table-thead > tr > th) {
  background-color: #e6f4ff;
  color: #1f2329;
  font-weight: 500;
}

/* 功能模块布局（全局操作管理） */
.func-module {
  background: #fafafa;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 20px 24px;
  margin-bottom: 12px;
}

.func-module:last-of-type {
  margin-bottom: 0;
}

.func-module-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.func-module-info {
  flex: 1;
  margin-right: 24px;
}

.func-module-title {
  font-size: 15px;
  font-weight: 600;
  color: #1f2329;
  margin: 0 0 6px 0;
}

.func-module-desc {
  font-size: 13px;
  color: #8f959e;
  margin: 0;
  line-height: 1.6;
}

.func-module-body {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

.sub-option-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.sub-option-label {
  font-size: 13px;
  color: #595959;
  flex-shrink: 0;
}

.sub-option-separator {
  font-size: 14px;
  color: #8f959e;
  margin: 0 4px;
}

.next-day-checkbox {
  margin-left: 8px;
  font-size: 13px;
}
</style>
