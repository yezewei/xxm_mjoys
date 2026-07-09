<template>
  <a-config-provider :theme="{
    components: {
      Menu: {
        subMenuItemBorderRadius: 4
      }
    }
  }">
    <!-- 移动端页面不使用 Layout -->
    <template v-if="isMobileRoute">
      <router-view />
    </template>
    <!-- 其他页面使用 Layout -->
    <template v-else>
      <Layout />
    </template>
  </a-config-provider>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import Layout from "./components/Layout.vue";

const route = useRoute()

// 判断是否为移动端路由
const isMobileRoute = computed(() => {
  return route.path === '/mobile' || route.path.startsWith('/mobile/')
})
</script>
