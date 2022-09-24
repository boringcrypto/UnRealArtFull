<script setup lang="ts">
const props = defineProps<{ src: string; }>()
</script>

<template>
    <div>
        <div class="h-100" style="position: relative" v-if="src">
            <img
                style="position: relative; height: 100%; width: 100%; object-fit: contain"
                :src="src"
                class="d-block"
            />
        </div>
    </div>
</template>
