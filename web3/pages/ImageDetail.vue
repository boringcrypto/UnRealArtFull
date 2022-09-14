<script setup lang="ts">
import { computed, inject, ref, watch } from "vue"
import { useRoute } from "vue-router"
import Image from "../components/Image.vue"
import Data from "../data-web3"
import { UnRealArtV2__factory } from "../../typechain-types"
import { BigNumber, ethers } from "ethers"
import Menu from "../components/Menu.vue"
const app = inject("app") as typeof Data
const contract = computed(() =>
    app.web3.provider ? UnRealArtV2__factory.connect(app.contract.address, app.web3.provider!.getSigner()) : null
)

const route = useRoute()
const series = ref(parseInt(route.params.series as string))
const image = ref(parseInt(route.params.image as string))
const serie = computed(() => app.series[series.value])
const forSale = ref(true)
const isOwned = ref(false)

const load = (newParams: any) => {
    series.value = parseInt(newParams.series as string)
    image.value = parseInt(newParams.image as string)
    if (serie.value && series.value >= 0) {
        const id = BigNumber.from(series.value).mul("1000000").add(image.value)
        app.contract.balanceOf(serie.value.creator, id).then((balance: BigNumber) => {
            forSale.value = balance.eq("1")
        })
        if (app.web3.address) {
            app.contract.balanceOf(app.web3.address, id).then((balance: BigNumber) => {
                isOwned.value = balance.eq("1")
            })
        }
    }
}
load(route.params)

watch(
    () => [route.params, app.series.length, app.web3.update],
    (params) => load(params[0])
)

const buy = async () => {
    await contract.value!.buy(series.value, image.value, app.gallery || ethers.constants.AddressZero, {
        value: serie.value.price,
    })
}
</script>

<template>
    <Menu></Menu>
    <div v-if="serie">
        <div class="m-3">
            <Image :series="series" :image="image" hide-q-r></Image>
        </div>
        <div style="max-width: 480px" class="ms-3 ms-lg-auto me-3">
            <div class="float-end">
                <div v-if="app.web3.chainId == app.network.chainId && app.web3.connector">
                    <div v-if="app.web3.address">
                        <b-button v-if="app.web3.address != serie.creator && forSale" @click="buy">Buy</b-button>
                    </div>
                    <div v-else>
                        <b-button @click="app.web3.connect">Connect</b-button>
                    </div>
                </div>
            </div>
            <h5>
                <strong>{{ serie.name || "Untitled" }} {{ image + 1 }}</strong>
                <span v-if="serie.author"
                    ><br /><small>by {{ serie.author }}</small></span
                >
            </h5>
            <p>This is part of a series of {{ serie.images.length }} artworks.</p>
            <p v-if="serie.description">{{ app.series[series].description }}</p>
            <p v-if="serie.process">Process: {{ serie.process }}</p>
            <p v-if="forSale">Price: {{ BigNumber.from(serie.price).div("1000000000000").toNumber() / 1000000 }} ETH</p>

            <div v-if="app.web3.connected">
                <div v-if="app.web3.chainId != app.network.chainId && app.web3.connector">
                    To buy this artwork, please switch your wallet to {{ app.network.chainName }}.
                </div>
                <div v-else-if="app.web3.address == serie.creator">You are the creator of this artwork.</div>
                <div v-else-if="isOwned">You are the owner of this artwork.</div>
            </div>
            <div v-else>
                To buy this artwork, please install an {{ app.network.chainName }} wallet such as
                <a href="https://metamask.io/download/" target="_blank">MetaMask</a>
            </div>
        </div>
    </div>
</template>

<style></style>
