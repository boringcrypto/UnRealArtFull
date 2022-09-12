<script setup lang="ts">
import { ref, inject, watch } from "vue"
import Data from "./data-web3"
import { UnRealArt__factory } from "../typechain-types"
import { Network } from "../sdk/Network"
import { connectors } from "../sdk/NetworkConnectors"
import * as IPFS from "ipfs-http-client"
import { useRoute } from "vue-router"
import { ethers } from "ethers"
// @ts-ignore
import Cookies from "js-cookie"

const app = inject("app") as typeof Data
const route = useRoute()

watch(
    () => route.query,
    () => {
        if (route.query.g && ethers.utils.isAddress(route.query.g as string)) {
            Cookies.set("g", route.query.g as string)
        }
        const g = Cookies.get("g")
        if (g) {
            app.gallery = g
        }
    }
)

const g = Cookies.get("g")
if (g) {
    app.gallery = g
}

const network = new connectors[Network.ETHEREUM]()
const contract = UnRealArt__factory.connect("0x8d41Bd479622B68ecF5E59d68B1a2400bE465052", network.provider)

const showQueue = ref(false)
watch(
    () => app.web3.active.length,
    (value) => {
        showQueue.value = value > 0
    }
)

const loadWeb3 = async () => {
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

    const seriesCount = (await contract.seriesCount()).toNumber()
    for (let i = app.series.length; i < seriesCount; i++) {
        console.log("Loading series " + i)
        const res = await contract.getSerie(i)
        app.series.push({
            creator: res.creator,
            author: res.author,
            name: res.name,
            description: res.description,
            process: res.process,
            price: res.price,
            images: res.artworks,
        })
    }
}

loadWeb3()
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
