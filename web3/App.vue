<script setup lang="ts">
import { ref, inject, watch } from "vue"
import Data, { loadNewSeries } from "./data-web3"
import { UnRealArtV2__factory } from "../typechain-types"
import { Network } from "../sdk/Network"
import { connectors } from "../sdk/NetworkConnectors"
import * as IPFS from "ipfs-http-client"
import { useRoute } from "vue-router"
import { ethers } from "ethers"
// @ts-ignore
import Cookies from "js-cookie"
import axios from "axios"

const app = inject("app") as typeof Data
const route = useRoute()

watch(
    () => route.query,
    () => {
        if (route.query.g && ethers.utils.isAddress(route.query.g as string)) {
            Cookies.set("g", route.query.g as string)
        }
        const g = Cookies.get("g")
        if (g && ethers.utils.isAddress(g)) {
            app.gallery = g
        }
    }
)

const g = Cookies.get("g")
if (g && ethers.utils.isAddress(g)) {
    app.gallery = g
}

app.request.request_number = Cookies.get("r")

const contract = UnRealArtV2__factory.connect(app.contract.address, app.network.provider)

const showQueue = ref(false)
watch(
    () => app.web3.active.length,
    (value) => {
        showQueue.value = value > 0
    }
)

const updateRequest = async () => {
    if (app.request.request_number && (!app.request.done || app.request.accepted)) {
        const res = await axios.get(app.bot + "check/" + app.request.request_number)
        app.request = res.data
        console.log(app.request)
    }
}

const setup = async () => {
    const projectId = "2EM0rRSPLVa1Tz9VokxlzHYdwR6"
    const projectSecret = "88b89157de2c00f3a2e75ff31f71d0d7"

    app.ipfs = await IPFS.create({
        host: "ipfs.infura.io",
        port: 5001,
        protocol: "https",
        headers: {
            Authorization: "Basic " + btoa(projectId + ":" + projectSecret),
        },
    })

    await loadNewSeries()

    setInterval(loadNewSeries, 5 * 60 * 1000)
    setInterval(updateRequest, 500)
}

setup()
</script>

<template>
    <router-view v-slot="{ Component }" style="height: 100%">
        <suspense>
            <div class="h-100">
                <component :is="Component" class="h-100" />
            </div>
            <template #fallback> Loading... </template>
        </suspense>
    </router-view>

    <b-modal v-model="showQueue" title="Transactions" hideFooter centered>
        <div v-for="info in app.web3.active">{{ info.description }} - {{ info.status }}</div>
    </b-modal>
</template>

<style></style>
