<script setup lang="ts">
import { inject } from "vue"
import Data from "../data-web3"
import CreateSeries from "../components/CreateSeries.vue"
import Menu from "../components/Menu.vue";
const app = inject("app") as typeof Data
</script>

<template>
    <Menu></Menu>
    <div style="max-width: 800px" class="mx-auto mt-3">
        <div v-if="app.web3.connected">
            <div v-if="app.web3.chainId == app.network.chainId && app.web3.connector">
                <div v-if="app.web3.address">
                    <CreateSeries></CreateSeries>
                </div>
                <div v-else>
                    <h3>Not connected</h3>
                    Your {{ app.network.chainName }} wallet (such as MetaMask) isn't jet connected. Press the connect button to connect.<br />
                    <br />
                    <b-button @click="app.web3.connect" class="w-100">Connect</b-button>
                </div>
            </div>
            <div v-else>
                <h3>Wrong network</h3>
                Please connect to {{ app.network.chainName }}
            </div>
        </div>
        <div v-else>
            <h3>No wallet</h3>
            To create series, please install an {{ app.network.chainName }} wallet such as <a href="https://metamask.io/download/" target="_blank">MetaMask</a>
        </div>
    </div>
</template>

<style></style>
