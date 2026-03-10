-- 场景模板表
-- 用于存储场景模板的基本信息和配置

DROP TABLE IF EXISTS `scene_template`;

CREATE TABLE `scene_template` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键 ID',
  `template_name` VARCHAR(255) NOT NULL COMMENT '模板名称',
  `bank_id` BIGINT DEFAULT NULL COMMENT '银行 ID',
  `bank_name` VARCHAR(100) DEFAULT NULL COMMENT '银行名称',
  `org_id` BIGINT DEFAULT NULL COMMENT '归属机构 ID',
  `org_name` VARCHAR(100) DEFAULT NULL COMMENT '归属机构名称',
  `scene_name` VARCHAR(255) DEFAULT NULL COMMENT '场景名称',
  `scene_short_name` VARCHAR(100) DEFAULT NULL COMMENT '场景简称',
  `scene_code` VARCHAR(100) DEFAULT NULL COMMENT '场景编号',
  `template_type` VARCHAR(255) DEFAULT NULL COMMENT '模板类型（级联分类，如"信用卡/信用卡激活"）',
  `follow_type` VARCHAR(50) DEFAULT NULL COMMENT '跟进方式（all/sms/manual/sms+manual）',
  `tags` JSON DEFAULT NULL COMMENT '标签数组',
  `description` TEXT DEFAULT NULL COMMENT '模板描述',
  `expire_date` DATE DEFAULT NULL COMMENT '到期时间',
  `target_customer` TEXT DEFAULT NULL COMMENT '适用客群',
  `applicable_activity` TEXT DEFAULT NULL COMMENT '适用活动',
  `financial_product` TEXT DEFAULT NULL COMMENT '金融产品',
  `reference_scene_id` BIGINT DEFAULT NULL COMMENT '引用场景 ID（如果是引用创建）',
  `scene_count` INT DEFAULT 0 COMMENT '已创建场景数量',
  `status` TINYINT DEFAULT 1 COMMENT '状态（1-启用，0-禁用）',
  `created_by` BIGINT DEFAULT NULL COMMENT '创建人 ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at` DATETIME DEFAULT NULL COMMENT '删除时间（软删除）',
  PRIMARY KEY (`id`),
  KEY `idx_template_name` (`template_name`),
  KEY `idx_bank_id` (`bank_id`),
  KEY `idx_org_id` (`org_id`),
  KEY `idx_scene_code` (`scene_code`),
  KEY `idx_template_type` (`template_type`),
  KEY `idx_follow_type` (`follow_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='场景模板表';

-- 插入示例数据
INSERT INTO `scene_template` (`template_name`, `bank_id`, `bank_name`, `org_id`, `org_name`, `scene_name`, `scene_short_name`, `scene_code`, `template_type`, `follow_type`, `tags`, `description`, `target_customer`, `applicable_activity`, `financial_product`, `scene_count`, `status`) VALUES
('信用卡激活', 1, '工商银行', 1, '总行', '信用卡激活场景', '卡激活', 'SCENE_CC_001', '信用卡/信用卡激活', 'sms+manual', '["标签 1", "标签 2", "标签 3"]', '用于短信下发后，再进行外呼。', '新办信用卡客户', '信用卡激活活动', '信用卡', 5, 1),
('账户回访', 2, '农业银行', 1, '总行', '账户回访场景', '户回访', 'SCENE_ACC_001', '回访/开卡回访', 'manual', '["标签 1", "标签 2", "标签 3"]', '成年版的开卡回访，无需跟进', '新开账户客户', '账户回访活动', '账户服务', 5, 1),
('信用卡换卡', 3, '中国银行', 2, '北京分行', '信用卡换卡场景', '卡换卡', 'SCENE_CC_002', '信用卡/信用卡换卡', 'sms', '["标签 1", "标签 2", "标签 3"]', '信用卡到期换新卡', '信用卡到期客户', '信用卡换卡活动', '信用卡', 5, 1),
('存款到期续存', 4, '建设银行', 3, '上海分行', '存款到期续存场景', '存续存', 'SCENE_DEP_001', '存款/存款到期提醒', 'sms+manual', '["标签 1", "标签 2", "标签 3"]', '定期存款到期后提醒转存', '定期存款到期客户', '存款续存活动', '定期存款', 5, 1),
('信用卡促活', 5, '交通银行', 1, '总行', '信用卡促活场景', '卡促活', 'SCENE_CC_003', '信用卡/信用卡促活', 'sms+manual', '["标签 1", "标签 2", "标签 3"]', '用于短信下发后，再进行外呼。', '沉睡信用卡客户', '信用卡促活活动', '信用卡', 5, 1),
('手机银行签到有礼', 1, '工商银行', 1, '总行', '手机银行签到有礼场景', '签到有礼', 'SCENE_MB_001', '手机银行/手机银行促活', 'sms', '["标签 1", "标签 2", "标签 3"]', '手机银行促活类', '手机银行用户', '手机银行签到活动', '手机银行服务', 5, 1);
