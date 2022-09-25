<script setup lang="ts">
import { computed } from "@vue/reactivity"
import { BigNumber, ethers } from "ethers"
import { inject, ref, watch } from "vue"
import { useRoute } from "vue-router"
import Image from "../components/Image.vue"
import Data, { Request } from "../data-web3"
import axios from "axios"
import QRCodeVue3 from "qrcode-vue3"
import BaseImage from "../components/BaseImage.vue"

const app = inject("app") as typeof Data
const work = ref(null as Request | null)
const count = ref(0)

setInterval(async () => {
    const res = await axios.get(app.bot + "show/")
    work.value = res.data.image
    count.value = res.data.count
}, 1000)

//const create_url = computed(() => location.protocol + "//" + location.host + "/#/create")
const create_url = computed(() => "https://un-real-art.com/#/create")
</script>

<template>
    <div>
        <div v-if="work" class="h-100">
            <div class="row h-100 m-0 p-0">
                <div class="col h-100 m-0 p-0" style="min-width: 85%; background-color: black; position: relative;">
                    <Transition name="fade">
                        <BaseImage style="position: absolute;top:0; bottom:0; left:0; right:0" :src="work.img_src" :key="work.img_src"></BaseImage>
                    </Transition>
                </div>
                <div class="col h-100">
                    <div style="position: absolute; top: 0" class="pt-3">
                        <h3>UnRealArt Exhibition</h3>
                        <p>
                            This screen shows {{ count }} works created by visitors.
                        </p>
                        <h3>Try it yourself!</h3>
                        <h5>
                            Scan the QR Code below to create your own AI work from a simple prompt.
                        </h5>
                        <QRCodeVue3
                            class="mt-3 mb-2"
                            :value="create_url"
                            :width="250"
                            :height="250"
                            :backgroundOptions="{ color: '#bbb' }"
                            :dotsOptions="{
                                type: 'rounded',
                                color: '#000',
                            }"
                        />
                        <p>
                            The experience takes about 2 minutes.
                        </p>

                    </div>
            
                    <div style="position:absolute; bottom: 0" class="pb-3">
                        <small>
                            <strong>{{ work.title || "Untitled" }}</strong>
                            <span v-if="work.author"
                                ><br /><small>by {{ work.author }}</small>
                            </span>
                            <p v-if="work.description">{{ work.description }}</p>
                            <p>Process: Midjourney with prompt "{{ work.prompt }}"</p>
                        </small>
                    </div>
                </div>
            </div>
        </div>
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
