<script setup lang="ts">
import { computed, inject, ref } from "vue"
import { BigNumber } from "ethers"
import Data from "../data-web3"
import { UnRealArt__factory } from "../../typechain-types"
// @ts-ignore
import UploadImages from "vue-upload-drop-images"
import { useRouter } from "vue-router"

const app = inject("app") as typeof Data
const contract = UnRealArt__factory.connect("0x8d41Bd479622B68ecF5E59d68B1a2400bE465052", app.web3.provider!.getSigner())
const author = ref("")
const name = ref("")
const description = ref("")
const process = ref("")
const price = ref(0.1)
const files = ref([] as any)
const pinned = ref([] as string[])

const addFiles = (f: any) => {
    files.value = f
}

const create = async () => {
    console.log("huh")
    pinned.value = []
    for (let i in files.value) {
        const file = files.value[i]

        const res = await app.ipfs.add(file)

        pinned.value.push(res.path)
    }

    try {
        const tx = await contract.createSeries(
            author.value.replaceAll('"', "'"),
            name.value.replaceAll('"', "'"),
            description.value.replaceAll('"', "'"),
            process.value.replaceAll('"', "'"),
            BigNumber.from(price.value * 1000000).mul("1000000000000"),
            pinned.value
        )
        console.log(tx)
        const receipt = await tx.wait()
        console.log(receipt)
        if (receipt.status == 1) {
            useRouter().push("/")
        }
    } catch {
        pinned.value = []
    }
}
</script>

<template>
    <div>
        <div v-if="!pinned.length">
            <h1>Create Series</h1>
            <p>Connected with {{ app.web3.address }}</p>
            <div class="mb-2">
                <h3>Author</h3>
                <b-form-input type="text" size="lg" v-model="author" />
                <b-form-text>For twitter handles, use the @ notation (@Boring_Crypto). You can also use just a name/handle.</b-form-text>
            </div>

            <div class="mb-2">
                <h3>Name</h3>
                <b-form-input type="text" size="lg" v-model="name" />
                <b-form-text>A short name for the series.</b-form-text>
            </div>

            <div class="mb-2">
                <h3>Description <small>(optional)</small></h3>
                <b-form-textarea size="lg" v-model="description" />
                <b-form-text>A description for the series, such as the inspiration or meaning behind it.</b-form-text>
            </div>

            <div class="mb-2">
                <h3>Process <small>(optional)</small></h3>
                <b-form-textarea size="lg" v-model="process" />
                <b-form-text>What tools were used? DALL-E, midjourney, etc. What prompts were used? Any after editing?</b-form-text>
            </div>

            <div class="mb-2">
                <h3>Price</h3>
                <b-form-input type="number" size="lg" v-model="price" />
                <b-form-text>The price in ETH of each artwork.</b-form-text>
            </div>

            <h2>Images</h2>
            <UploadImages class="ms-0" @changed="addFiles"></UploadImages>
            <b-form-text v-if="files.length && files.length < 5" style="color: red !important">You need at least 5 artworks.</b-form-text>

            <b-button class="my-3 w-100" @click="create" size="lg" :disabled="!author || !name || files.length < 5">Create Series</b-button>
        </div>

        <div v-else class="row">
            <h3>Uploading to IPFS and generating minting transaction</h3>
            <div class="col" v-for="(path, i) in pinned">
                <img :src="'https://unrealart.infura-ipfs.io/ipfs/' + path" style="max-width: 180px" />
            </div>
        </div>
    </div>
</template>
