<script setup lang="ts">
import { computed, inject } from "vue"
import { BigNumber } from "ethers"
import QRCodeVue3 from "qrcode-vue3"
import Data from "../data-web3"

const app = inject("app") as typeof Data
const props = defineProps<{ series: number; image: number; gallery?: string; isLink?: boolean; hideQR?: boolean }>()
const serie = computed(() => app.series[props.series])
const image_url = computed(() => "https://unrealart.infura-ipfs.io/ipfs/" + serie.value.images[props.image])
const gallery_hash = props.gallery ? "?g=" + props.gallery : ""
const link_url = computed(() => location.protocol + "//" + location.host + "/image/" + props.series + "/" + props.image + gallery_hash)
</script>

<template>
    <div>
        <div class="h-100" style="position: relative" v-if="serie">
            <router-link v-if="isLink" :to="'/image/' + props.series + '/' + props.image">
                <img
                    style="position: relative; height: 100%; width: 100%; object-fit: contain"
                    :src="image_url"
                    class="d-block"
                    :alt="serie.name + ' ' + image"
                />
            </router-link>
            <img
                v-else
                style="position: relative; height: 100%; width: 100%; object-fit: contain"
                :src="image_url"
                class="d-block"
                :alt="serie.name + ' ' + image"
            />
            <QRCodeVue3
                v-if="!hideQR"
                class="d-none d-md-block"
                style="position: absolute; bottom: 20px; right: 20px"
                :value="link_url"
                :width="150"
                :height="150"
                :backgroundOptions="{ color: '#bbb' }"
                :dotsOptions="{
                    type: 'rounded',
                    color: '#000',
                }"
            />
        </div>
    </div>
</template>
