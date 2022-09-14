<script setup lang="ts">
import { inject, ref } from "vue"
import Image from "../components/Image.vue"
import Data from "../data-web3"
import Menu from "../components/Menu.vue";
const seed = Math.floor(Math.random() * 1000000)

const app = inject("app") as typeof Data
</script>

<template>
    <Menu></Menu>
    <div class="mx-md-3">
        <h2 class="text-center">All Series</h2>
        <div v-for="serie, s in app.series" class="mb-3 mx-1">
            <div class="row" v-if="app.series[s]">
                <Image
                    v-for="i in app.randomListWithSeed(seed, serie.images.length).slice(0, 3)"
                    class="col"
                    style="width: 25%"
                    :series="s"
                    :image="i"
                    isLink
                    hideQR
                ></Image>
            </div>
            <router-link :to="'/series/' + s" v-if="serie">{{ serie.name || "Untitled" }}</router-link>
        </div>

        <div class="text-center">
            <h2 class="text-center">Add your own artworks</h2>
            You can add your own series of AI artworks. These may be shown in galleries, including the one at NDSM Treehouse in Amsterdam.<br />
            <router-link to="/manager"><b-button class="my-3">Add Artwork</b-button></router-link>
        </div>

        <br />
    </div>
</template>

<style></style>
