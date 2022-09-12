<script setup lang="ts">
import { inject } from "vue"
import Data from "../data-web3"

const app = inject("app") as typeof Data

const create = async () => {}
</script>

<template>
    <div style="max-width: 800px" class="mx-auto mt-3">
        <h1>Collection</h1>

        <h2 class="text-center">Series</h2>
        <div v-for="(serie, i) in app.series" class="mb-5">
            <div class="row">
                <Image class="col" style="width: 25%" :series="i" :image="1" isLink hideQR></Image>
                <Image class="col" style="width: 25%" :series="i" :image="2" isLink hideQR></Image>
                <Image class="col" style="width: 25%" :series="i" :image="3" isLink hideQR></Image>
            </div>
            <h3>{{ serie.name }} ({{ serie.images.length }} works)</h3>
        </div>

        <b-button class="my-3 w-100" @click="create" size="lg">Create Collection</b-button>
    </div>
</template>
