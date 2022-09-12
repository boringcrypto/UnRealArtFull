<script setup lang="ts">
import { computed, inject, ref, watch } from "vue"
import { useRoute } from "vue-router"
import Image from "../components/Image.vue"
import Data from "../data-web3"
const app = inject("app") as typeof Data

const route = useRoute()
const series = ref(parseInt(route.params.series as string))
const serie = computed(() => app.series[series.value])

const load = (newParams: any) => {
    series.value = parseInt(newParams.series as string)
}

watch(
    () => [route.params, app.series.length],
    (params) => load(params[0])
)
</script>

<template>
    <div v-if="serie" class="m-3">
        <div style="max-width: 480px" class="mb-3">
            <strong>{{ serie.name || "Untitled" }}</strong>
            <span v-if="serie.author"
                ><br /><small>by {{ serie.author }}</small></span
            >
            <p v-if="serie.description">{{ app.series[series].description }}</p>
            <p v-if="serie.process">Process: {{ serie.process }}</p>
        </div>
        <div>
            <Image class="mb-3" v-for="(artwork, i) in serie.images" :series="series" :image="i" hide-q-r></Image>
        </div>
        <br />
    </div>
</template>

<style></style>
