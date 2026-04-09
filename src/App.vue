<template>
  <a-config-provider :theme="{
    components: {
      Menu: {
        subMenuItemBorderRadius: 4
      }
    }
  }">
    <Layout />
  </a-config-provider>
</template>

<script setup lang="ts">
import Layout from "./components/Layout.vue";
</script>
