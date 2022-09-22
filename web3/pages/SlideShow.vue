<script setup lang="ts">
import { computed } from "@vue/reactivity"
import { BigNumber, ethers } from "ethers"
import { inject, ref, watch } from "vue"
import { useRoute } from "vue-router"
import Image from "../components/Image.vue"
import Data from "../data-web3"
import axios from "axios"
import QRCodeVue3 from "qrcode-vue3"

const app = inject("app") as typeof Data

const route = useRoute()
const screen = ref(parseInt(route.params.screen as string))
const gallery = ref((route.params.gallery as string) || "boringcrypto.eth")
if (!ethers.utils.isAddress(gallery.value)) {
    if (app.web3.provider) {
        app.web3.provider?.resolveName(gallery.value).then((address) => {
            if (!address) {
                gallery.value = "boringcrypto.eth"
            }
        })
    } else {
        gallery.value = "boringcrypto.eth"
    }
}

const time = ref(Date.now())
const seed = computed(() => Math.floor((time.value + time_delta.value) / 30000))
const series = computed(() => app.randomListWithSeed(1234, app.series.length)[seed.value % app.series.length])
const serie = computed(() => app.series[series.value])
const image = computed(() =>
    app.series.length >= series.value ? app.randomListWithSeed(seed.value, app.series[series.value].images.length)[screen.value - 1] : 0
)

const next_seed = computed(() => seed.value + 1)
const next_series = computed(() => next_seed.value % app.series.length)
const next_image = computed(() =>
    app.series.length >= next_series.value ? app.randomListWithSeed(next_seed.value, app.series[next_series.value].images.length)[screen.value - 1] : 0
)

const gallery_hash = gallery ? "?g=" + gallery : ""
const link_url = computed(() => location.protocol + "//" + location.host + "/#/image/" + series.value + "/" + image.value + gallery_hash)

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
    <div class="col h-100 m-0 p-0" style="min-width: 85%; background-color: black; position: relative;">
        <transition name="fade">
            <Image v-if="serie" style="position: absolute;top:0; bottom:0; left:0; right:0" :series="series" :image="image" :key="series * 1000000 + image" :gallery="gallery" class="h-100" hide-q-r></Image>
        </transition>
    </div>
    <div class="col h-100">
        <div style="position:absolute; bottom: 0" class="pb-3">
            <QRCodeVue3
                class="mb-3"
                :value="link_url"
                :width="150"
                :height="150"
                :backgroundOptions="{ color: '#bbb' }"
                :dotsOptions="{
                    type: 'rounded',
                    color: '#000',
                }"
            />

            <small v-if="serie">
                <strong>{{ serie.name || "Untitled" }}</strong>
                <span v-if="serie.author"
                    ><br /><small>by {{ serie.author }}</small>
                </span>
                <p>This is part of a series of {{ serie.images.length }} artworks.</p>
                <p v-if="serie.description">{{ app.series[series].description }}</p>
                <p v-if="serie.process">Process: {{ serie.process }}</p>
                <p>{{ BigNumber.from(serie.price).div("1000000000000").toNumber() / 1000000 }} ETH</p>
            </small>            
        </div>
    </div>
    <Image class="d-none" :series="next_series" :image="next_image" hide-q-r></Image>
</div>
</template>

<style>
    .fade-enter-active,
    .fade-leave-active {
    transition: opacity 3s ease;
    }

    .fade-enter-from,
    .fade-leave-to {
    opacity: 0;
    }
</style>
