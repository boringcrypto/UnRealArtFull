<script setup lang="ts">
import { computed } from "@vue/reactivity"
import { BigNumber, ethers } from "ethers"
import { inject, ref, watch } from "vue"
import { useRoute } from "vue-router"
import Image from "../components/Image.vue"
import Data, { Request } from "../data-web3"
import axios from "axios"
import QRCodeVue3 from "qrcode-vue3"

const app = inject("app") as typeof Data
const work = ref(null as Request | null)

setInterval(async () => {
    const res = await axios.get(app.bot + "show/")
    work.value = res.data
}, 1000)

const create_url = computed(() => location.protocol + "//" + location.host + "/#/create")
</script>

<template>
    <div>
        <div v-if="false">
            <h1>Create your own AI work. Scan this QR code:</h1>
            <QRCodeVue3
                    class="mb-3"
                    :value="create_url"
                    :width="150"
                    :height="150"
                    :backgroundOptions="{ color: '#bbb' }"
                    :dotsOptions="{
                        type: 'rounded',
                        color: '#000',
                    }"
                />
            <a :href="create_url" target="_blank">{{ create_url }}</a>
        </div>
        <div v-if="work" class="h-100">
            <div class="row h-100 m-0 p-0">
                <div class="col h-100 m-0 p-0" style="min-width: 85%; background-color: black; position: relative;">
                    <transition name="fade">
                        <div class="h-100" style="position: relative">
                            <img
                                style="position: relative; height: 100%; width: 100%; object-fit: contain"
                                :src="work.img_src"
                                class="d-block"
                            />
                        </div>
                    </transition>
                </div>
                <div class="col h-100">
                    <div style="position: absolute; top: 0" class="pt-3">
                        <h5>UnRealArt Exhibition</h5>
                        <p>
                            All the series seen on the other screens are original works created by Artificial Intelligence based on simple text prompts.<br>
                            <br>
                            No images, design or editing were involved.<br>
                            <br>
                            There are 258 works in 41 series created by 12 artists, rotating every 30 seconds.<br>
                        </p>
                        <h5>Try it yourself!</h5>
                        <p>
                            Scan the QR Code below to create your own AI work from a simple prompt. Once completed, the work will be shown here. The experience takes about 2 minutes.
                        </p>
                        <QRCodeVue3
                            class="mb-3"
                            :value="create_url"
                            :width="150"
                            :height="150"
                            :backgroundOptions="{ color: '#bbb' }"
                            :dotsOptions="{
                                type: 'rounded',
                                color: '#000',
                            }"
                        />

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
