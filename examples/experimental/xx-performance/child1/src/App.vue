<script lang="ts" setup>
import { ref } from 'vue';

const counter = ref<number>(0);
</script>

<template>
  <h1>Hello from Child 1 + Vue 3!</h1>
  <p>Counter: {{ counter }}</p>
  <button @click="counter++">Increment counter</button>
</template>
