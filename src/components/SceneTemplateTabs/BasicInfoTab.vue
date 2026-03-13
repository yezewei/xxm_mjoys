<template>
  <div class="basic-info-tab">
    <div class="basic-form-wrapper">
      <a-descriptions bordered :column="2" size="large">
        <a-descriptions-item label="场景 ID" :span="1">
          {{ basicForm.sceneId }}
        </a-descriptions-item>

        <a-descriptions-item label="场景名称" :span="1">
          {{ basicForm.sceneTemplate }}
        </a-descriptions-item>

        <a-descriptions-item label="场景简称" :span="1">
          {{ basicForm.sceneShortName }}
        </a-descriptions-item>

         <a-descriptions-item label="归属机构" :span="1">
          {{ basicForm.organization }}
        </a-descriptions-item>

        <a-descriptions-item label="创建人" :span="1">
          {{ basicForm.creator }}
        </a-descriptions-item>
       

        <a-descriptions-item label="创建时间" :span="1">
          {{ basicForm.createTime }}
        </a-descriptions-item>

       <a-descriptions-item label="上线时间" :span="1">
          {{ basicForm.createTime }}
        </a-descriptions-item>


        <a-descriptions-item label="到期时间" :span="1">
          {{ basicForm.expireTime }}
        </a-descriptions-item>
      
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
</template>

<script setup lang="ts">
import { reactive, computed } from 'vue';

// 定义接口
interface BasicForm {
  sceneId: string;
  creator: string;
  organization: string;
  sceneTemplate: string;
  createTime: string;
  expireTime: string;
  sceneShortName: string;
  templateName: string;
  templateType: string[];
  tags: string[];
  followType: string;
  description: string;
  targetCustomer: string;
  applicableActivity: string;
  financialProduct: string;
}

// 定义 props
interface Props {
  modelValue?: Partial<BasicForm>;
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: () => ({}),
});

// 定义 emits
const emit = defineEmits<{
  (e: 'update:modelValue', value: Partial<BasicForm>): void;
}>();

// 基本信息表单数据
const basicForm = reactive<BasicForm>({
  sceneId: props.modelValue?.sceneId || '232',
  creator: props.modelValue?.creator || 'admin',
  organization: props.modelValue?.organization || '上海中行',
  sceneTemplate: props.modelValue?.sceneTemplate || '信用卡激活',
  createTime: props.modelValue?.createTime || '2025-09-05 13:44:19',
  expireTime: props.modelValue?.expireTime || '2027-03-17 00:00:00',
  sceneShortName: props.modelValue?.sceneShortName || '上海中行信用卡激活',
  templateName: props.modelValue?.templateName || '信用卡激活模板',
  templateType: props.modelValue?.templateType || ['信用卡', '信用卡激活'],
  tags: props.modelValue?.tags || ['信用卡', '激活流程', '高频场景'],
  followType: props.modelValue?.followType || 'sms+manual',
  description: props.modelValue?.description || '适用于信用卡激活场景，包含完整的激活流程指引和常见问题解答',
  targetCustomer: props.modelValue?.targetCustomer || '持有未激活信用卡的新客户，包括个人客户和企业客户',
  applicableActivity: props.modelValue?.applicableActivity || '2026 年信用卡开卡礼活动、首刷礼活动、新户专享理财活动',
  financialProduct: props.modelValue?.financialProduct || '信用卡产品：标准金卡、白金卡、钻石卡；关联产品：消费分期、账单分期、现金分期',
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
</script>

<style scoped>
.basic-info-tab {
  height: 100%;
}

.basic-form-wrapper {
  padding: 24px;
}

:deep(.ant-descriptions) {
  background: #fff;
}

:deep(.ant-descriptions-item-label) {
  font-weight: 500;
  color: #1f1f1f;
}

:deep(.ant-tag) {
  margin-right: 4px;
}
</style>
