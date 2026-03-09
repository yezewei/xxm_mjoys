/**
 * 列表列配置本地存储工具
 * 用于保存和加载用户的列表显示设置（排序、显示/隐藏、宽度）
 */

const STORAGE_PREFIX = 'column_config_';

export interface ColumnConfigItem {
  key: string;
  title: string;
  dataIndex: string;
  width: number | undefined;
  visible: boolean;
  order: number;
}

/**
 * 获取存储键名
 */
function getStorageKey(pageKey: string): string {
  return `${STORAGE_PREFIX}${pageKey}`;
}

/**
 * 保存列配置到本地存储
 * @param pageKey 页面唯一标识
 * @param columns 列配置数组
 */
export function saveColumnConfig(pageKey: string, columns: ColumnConfigItem[]): void {
  try {
    const config = columns.map(col => ({
      key: col.key,
      title: col.title,
      dataIndex: col.dataIndex,
      width: col.width,
      visible: col.visible,
      order: col.order,
    }));
    localStorage.setItem(getStorageKey(pageKey), JSON.stringify(config));
  } catch (error) {
    console.warn('保存列配置失败:', error);
  }
}

/**
 * 从本地存储加载列配置
 * @param pageKey 页面唯一标识
 * @returns 列配置数组，如果没有保存过则返回 null
 */
export function loadColumnConfig(pageKey: string): ColumnConfigItem[] | null {
  try {
    const stored = localStorage.getItem(getStorageKey(pageKey));
    if (stored) {
      return JSON.parse(stored);
    }
  } catch (error) {
    console.warn('加载列配置失败:', error);
  }
  return null;
}

/**
 * 清除列配置
 * @param pageKey 页面唯一标识
 */
export function clearColumnConfig(pageKey: string): void {
  try {
    localStorage.removeItem(getStorageKey(pageKey));
  } catch (error) {
    console.warn('清除列配置失败:', error);
  }
}

/**
 * 根据保存的配置更新列顺序和可见性
 * @param defaultColumns 默认列配置
 * @param savedConfig 保存的列配置
 * @returns 更新后的列配置
 */
export function mergeColumnConfig(
  defaultColumns: ColumnConfigItem[],
  savedConfig: ColumnConfigItem[] | null
): ColumnConfigItem[] {
  if (!savedConfig || savedConfig.length === 0) {
    // 如果没有保存的配置，使用默认配置并添加 order
    return defaultColumns.map((col, index) => ({
      ...col,
      order: index,
      visible: col.visible !== undefined ? col.visible : true,
    }));
  }

  // 创建默认配置的 map，方便查找
  const defaultMap = new Map(defaultColumns.map(col => [col.key, col]));

  // 根据保存的配置更新
  const merged = savedConfig.map(saved => {
    const defaultCol = defaultMap.get(saved.key);
    return {
      key: saved.key,
      title: saved.title,
      dataIndex: saved.dataIndex,
      width: saved.width || defaultCol?.width,
      visible: saved.visible,
      order: saved.order,
    };
  });

  // 添加默认配置中有但保存配置中没有的新列
  const savedKeys = new Set(savedConfig.map(col => col.key));
  defaultColumns.forEach((col) => {
    if (!savedKeys.has(col.key)) {
      merged.push({
        ...col,
        order: merged.length,
        visible: true,
      });
    }
  });

  // 按 order 排序
  return merged.sort((a, b) => a.order - b.order);
}

/**
 * 将列配置转换为 Ant Design Vue 表格的 columns 配置
 * @param columns 列配置数组
 * @returns Ant Design Vue 表格的 columns 配置
 */
export function toTableColumns(columns: ColumnConfigItem[]) {
  return columns
    .filter(col => col.visible)
    .map(col => ({
      title: col.title,
      dataIndex: col.dataIndex,
      key: col.key,
      width: col.width,
    }));
}
