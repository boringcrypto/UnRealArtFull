<script setup lang="ts">
import { ethers } from "ethers"
import { inject, ref } from "vue"
import Image from "../components/Image.vue"
import Data from "../data-web3"

const app = inject("app") as typeof Data
const gallery = ref("")
const seed = Math.floor(Math.random() * 1000000)

const prevImage = () => {
    app.image--
    if (app.image < 0) {
        app.serie--
        app.image = app.series[app.serie].images.length - 1
    }
}

const nextImage = () => {
    app.image++
    if (app.image >= app.series[app.serie].images.length) {
        app.serie++
        app.image = 0
    }
}

const prevSeries = () => {
    app.serie--
    app.image = 0
}

const nextSeries = () => {
    app.serie++
    app.image = 0
}
</script>

<template>
    <div class="mx-md-3">
        <div class="text-center my-5">
            <h1>UnRealArt</h1>
        </div>

        <div style="position: relative" class="d-block d-md-none">
            <Image :series="app.serie" :image="app.image" isLink hide-q-r></Image>
        </div>

        <div style="position: relative" class="d-none d-md-block">
            <img class="w-100" style="position: relative" src="/frame.jpg" />
            <Image
                style="position: absolute; top: 18%; right: 20%; left: 20%; bottom: 29%; background-color: black"
                :series="app.serie"
                :image="app.image"
                isLink
                hide-q-r
            ></Image>
        </div>

        <div class="mt-3 mb-5 text-center">
            <b-button @click="prevSeries" :disabled="app.serie == 0">&lt;&lt;</b-button>
            <b-button class="ms-2" @click="prevImage" :disabled="app.image == 0 && app.serie == 0">&lt;</b-button>
            <b-button
                class="ms-2"
                @click="nextImage"
                :disabled="app.serie == app.series.length - 1 && app.image == app.series[app.serie].images.length - 1"
                >&gt;</b-button
            >
            <b-button class="ms-2" @click="nextSeries" :disabled="app.serie == app.series.length - 1">&gt;&gt;</b-button>
        </div>

        <div class="text-center mb-5">
            <h2>What's this?</h2>

            <p style="max-width: 600px" class="mx-auto">
                UnRealArt is a fully decentralized platform that lets anyone upload AI art series to sell as NFTs. Anyone can sell these in
                real-world "galleries" (one or more screens) and receive a 10% commission.<br />
            </p>

            <h2>Pop-up gallery in Amsterdam (NDSM Treehouse)</h2>
            <p style="max-width: 600px" class="mx-auto">
                The UnrealArt exhibition showcases a wide variety of AI art. Every few minutes a new series of artworks is shown. Explore the
                boundaries of creativity and the latest technology in this one-of-a-kind exhibition.<br />
                <br />
                Try your hand at creating your own AI art on the spot. By providing a few prompts you will create your own artworks. We may even
                include them in the exhibition.<br />
                <br />
                Opening Event: 16th of September 4pm-9pm<br />
                Dates: 17-25 September 1pm-7pm<br />
                Location: <a href="https://www.treehousendsm.com/pages/contact" target="_blank" class="me-1">NDSM Treehouse unit M3</a>
                <a href="https://goo.gl/maps/N7xmUoshiVvYUKBR9" target="_blank">Google Maps</a><br />
            </p>
        </div>

        <h2 class="text-center">Highlighted Series <router-link to="/series/all"><small class="text-center">View All</small></router-link></h2>

        <div v-for="s in [0, 1, 2, 3, 4, 5, 6]" class="mb-3 mx-1">
            <div class="row" v-if="app.series[s]">
                <Image
                    v-for="i in app.randomListWithSeed(seed, app.series[s].images.length).slice(0, 3)"
                    class="col"
                    style="width: 25%"
                    :series="s"
                    :image="i"
                    isLink
                    hideQR
                ></Image>
            </div>
            <router-link :to="'/series/' + s" v-if="app.series[s]">{{ app.series[s].name || "Untitled" }}</router-link>
        </div>

        <div class="text-center">
            <h2 class="text-center">Add your own artworks</h2>
            You can add your own series of AI artworks. These may be shown in galleries, including the one at NDSM Treehouse in Amsterdam.<br />
            <router-link to="/manager"><b-button class="my-3">Add Artwork</b-button></router-link>
        </div>

        <div class="text-center">
            <h2 class="text-center">Run a Gallery</h2>
            <p>Got a spare screen? Display AI art and get 10% commission on sales made through the QR code.</p>
            <b-form-input
                class="mx-auto my-3"
                type="text"
                v-model="gallery"
                placeholder="Gallery ETH address"
                style="max-width: 600px"
            ></b-form-input>
            <router-link :to="'/slide/1/' + (gallery || ethers.constants.AddressZero)"><b-button>One</b-button></router-link>
            <router-link class="ms-2" :to="'/slide/2/' + (gallery || ethers.constants.AddressZero)"><b-button>Two</b-button></router-link>
            <router-link class="ms-2" :to="'/slide/3/' + (gallery || ethers.constants.AddressZero)"><b-button>Three</b-button></router-link>
            <router-link class="ms-2" :to="'/slide/4/' + (gallery || ethers.constants.AddressZero)"><b-button>Four</b-button></router-link>
            <router-link class="ms-2" :to="'/slide/5/' + (gallery || ethers.constants.AddressZero)"><b-button>Five</b-button></router-link>
        </div>
        <br />
    </div>
</template>

<style></style>
