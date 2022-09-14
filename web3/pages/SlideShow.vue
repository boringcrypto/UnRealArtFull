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
const serie = computed(() => app.series[series.value])
const image = computed(() =>
    app.series.length >= series.value ? app.randomListWithSeed(seed.value, app.series[series.value].images.length)[screen.value - 1] : 0
)
const time_delta = ref(0)

axios.get("https://worldtimeapi.org/api/timezone/Europe/Amsterdam").then((data) => {
    time_delta.value = data.data.unixtime * 1000 - Date.now()
})

setInterval(() => {
    ;(time.value = Date.now()), 50
})
</script>

<template>
    <div class="row h-100 m-0 p-0">
    <div class="col h-100 m-0 p-0" style="min-width: 85%; background-color: black">
        <Image :series="series" :image="image" :gallery="gallery" class="h-100" hide-q-r></Image>
    </div>
    <div class="col h-100">
        <div style="position:absolute; bottom: 0">
            <small>
                <strong>{{ serie.name || "Untitled" }}</strong>
                <span v-if="serie.author"
                    ><br /><small>by {{ serie.author }}</small>
                </span>
            </small>            
        </div>
    </div>
</div>
</template>

<style></style>
