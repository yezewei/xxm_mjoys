<template>
  <!-- 主流程设置内容区域 -->
  <div class="process-setting-tab">
    <div class="process-content">
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
                @change="(e) => handleIntentCheckboxChange(e, intent)"
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import type { FormInstance } from 'ant-design-vue/es/form';
import type { Rule } from 'ant-design-vue/es/form';
import { message } from 'ant-design-vue';
import {
  ZoomInOutlined,
  ZoomOutOutlined,
  FullscreenOutlined,
  LayoutOutlined,
  SaveOutlined,
  EditOutlined,
  CloseOutlined,
  CloseCircleOutlined,
  PlayCircleOutlined,
  MessageOutlined,
  CheckCircleOutlined,
  CustomerServiceOutlined,
  SafetyCertificateOutlined,
} from '@ant-design/icons-vue';

// ==================== 接口定义 ====================

type NodeType = 'start' | 'script' | 'success_end' | 'fail_end' | 'transfer' | 'verify';

interface IntentItem {
  id: number;
  intentName: string;
  intentType: string;
}

interface ProcessNode {
  id: number;
  type: NodeType;
  name: string;
  x: number;
  y: number;
  content?: {
    text?: string;
  };
}

interface Connection {
  id: number;
  sourceNodeId: number;
  targetNodeId: number;
  intents?: IntentItem[];
  label?: string;
}

interface NodeTypeDef {
  type: NodeType;
  label: string;
  icon: any;
}

// ==================== Props & Emits ====================

interface Props {
  nodes?: ProcessNode[];
  connections?: Connection[];
  intentList?: IntentItem[];
}

const props = withDefaults(defineProps<Props>(), {
  nodes: () => [],
  connections: () => [],
  intentList: () => [],
});

const emit = defineEmits<{
  (e: 'update:nodes', value: ProcessNode[]): void;
  (e: 'update:connections', value: Connection[]): void;
  (e: 'update:intentList', value: IntentItem[]): void;
  (e: 'save', value: { nodes: ProcessNode[]; connections: Connection[] }): void;
}>();

// ==================== 响应式数据 ====================

// 节点类型配置
const nodeTypes: NodeTypeDef[] = [
  { type: 'start', label: '开始节点', icon: PlayCircleOutlined },
  { type: 'script', label: '通用节点', icon: MessageOutlined },
  { type: 'success_end', label: '成功结束', icon: CheckCircleOutlined },
  { type: 'fail_end', label: '失败结束', icon: CloseOutlined },
  { type: 'transfer', label: '转人工坐席', icon: CustomerServiceOutlined },
  { type: 'verify', label: '验证信息', icon: SafetyCertificateOutlined },
];

// 画布引用
const canvasRef = ref<HTMLElement | null>(null);

// 流程节点数据
const processNodes = ref<ProcessNode[]>(props.nodes.length > 0 ? props.nodes : [
  { id: 1, type: 'start', name: '开始', x: 300, y: 50 },
  { id: 2, type: 'script', name: '开场白', x: 300, y: 180, content: { text: '您好，我是 XX 银行的智能客服，请问您现在方便接听电话吗？' } },
  { id: 3, type: 'script', name: '介绍产品', x: 300, y: 320, content: { text: '太好了！我们银行最近推出了一款高收益的理财产品，年化收益率最高可达 4.5%，您有兴趣了解一下吗？' } },
  { id: 4, type: 'success_end', name: '成功结束', x: 300, y: 450 },
]);

// 连接线数据
const connections = ref<Connection[]>(props.connections.length > 0 ? props.connections : [
  { id: 1, sourceNodeId: 1, targetNodeId: 2 },
  { id: 2, sourceNodeId: 2, targetNodeId: 3 },
  { id: 3, sourceNodeId: 3, targetNodeId: 4 },
]);

// 意图列表
const intentList = ref<IntentItem[]>(props.intentList.length > 0 ? props.intentList : [
  { id: 1, intentName: 'sys.重复', intentType: '重复' },
  { id: 2, intentName: 'sys.肯定', intentType: '肯定' },
  { id: 3, intentName: 'sys.确认', intentType: '肯定' },
  { id: 4, intentName: 'sys.否定', intentType: '否定' },
  { id: 5, intentName: 'sys.中性 - 继续', intentType: '中性' },
]);

// 画布缩放
const canvasZoom = ref(100);

// 画布尺寸
const canvasSize = reactive({ width: 2000, height: 1500 });

// 选中的节点
const selectedNode = ref<ProcessNode | null>(null);

// 选中的连接线
const selectedConnection = ref<Connection | null>(null);

// 正在编辑的节点
const editingNode = ref<ProcessNode | null>(null);

// 节点编辑表单
const nodeEditModalVisible = ref(false);
const nodeEditFormRef = ref<FormInstance>();
const nodeEditForm = reactive({ name: '', text: '' });

const nodeEditRules: Record<string, Rule[]> = {
  name: [{ required: true, message: '请输入节点名称', trigger: 'blur' }],
};

// 连接线编辑表单
const connectionEditModalVisible = ref(false);
const connectionEditFormRef = ref<FormInstance>();
const connectionEditForm = reactive({ selectedIntents: [] as IntentItem[] });

// 拖拽连线状态
const isDrawingConnection = ref(false);
const drawingSourceNode = ref<ProcessNode | null>(null);
const tempMousePosition = reactive({ x: 0, y: 0 });

// 节点拖拽状态
const isDraggingNode = ref(false);
const draggingNode = ref<ProcessNode | null>(null);
const dragOffset = reactive({ x: 0, y: 0 });

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
  console.log('连接线被点击:', connection.id);
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
  console.log('编辑连接线:', connection);
  console.log('意图列表:', intentList.value);
  selectedConnection.value = connection;
  // 初始化已选意图
  connectionEditForm.selectedIntents = connection.intents ? [...connection.intents] : [];
  console.log('已选意图:', connectionEditForm.selectedIntents);
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

</script>

<style scoped>
.process-setting-tab {
  height: 100%;
  overflow: hidden;
}

/* ==================== 主流程设置样式 ==================== */

/* 流程内容区域 */
/* .process-content {
  height: 100%;
  overflow: hidden;
  background: #f5f5f5;
} */

.process-wrapper {
  height: 100%;
  /* padding: 0 24px 24px 24px; */
}

/* 画布区域 */
.process-canvas-wrapper {
  /* flex: 1; */
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  /* display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0; */
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
  min-height: 600px;
}

.canvas-content {
  position: relative;
  min-width: 100%;
  min-height: 100%;
  box-sizing: border-box;
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
</style>
