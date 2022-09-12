<script setup lang="ts">
import { computed } from "@vue/reactivity"
import { ethers } from "ethers"
import { inject, ref, watch } from "vue"
import { useRoute } from "vue-router"
import Image from "../components/Image.vue"
import Data from "../data-web3"
import axios from "axios"

const app = inject("app") as typeof Data

const route = useRoute()
const screen = ref(parseInt(route.params.screen as string))
const gallery = (route.params.gallery as string) || ethers.constants.AddressZero
const time = ref(Date.now())
const seed = computed(() => Math.floor((time.value + time_delta.value) / 30000))
const series = computed(() => seed.value % app.series.length)
const image = computed(() =>
    app.series.length >= series.value ? app.randomListWithSeed(seed.value, app.series[series.value].images.length)[screen.value] : 0
)
const time_delta = ref(0)

axios.get("http://worldtimeapi.org/api/timezone/Europe/Amsterdam").then((data) => {
    time_delta.value = data.data.unixtime * 1000 - Date.now()
})

setInterval(() => {
    ;(time.value = Date.now()), 50
})
</script>

<template>
    <div class="h-100">
        <Image :series="series" :image="image" :gallery="gallery" class="h-100"></Image>
    </div>
</template>

<style></style>
