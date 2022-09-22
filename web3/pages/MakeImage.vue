<script setup lang="ts">
import { computed, inject, ref, watch } from "vue"
import { useRoute } from "vue-router"
import Image from "../components/Image.vue"
import Data from "../data-web3"
import Menu from "../components/Menu.vue";
import axios from "axios";
import { title } from "process";
import Cookies from "js-cookie"

const app = inject("app") as typeof Data
const author = ref("")
const name = ref("")
const description = ref("")

const prompt = ref("fairy with wings in a mystical chinese garden, victoria secret, colorful butterflies, god rays, green ethereal mist, intricate tattoos, detailed symmetrical face, photorealism, 8k --testp --ar 3:2")

const request_image = async () => {
    const res = await axios.get(app.bot + "request/" + prompt.value)
    app.request = res.data
    Cookies.set("r", app.request.request_number)
}

const accept = async() => {
    const res = await axios.get(app.bot + "upscale/" + app.request?.request_number + "/" + author.value + "/" + name.value + "/" + description.value)
    app.request = res.data
}

const reject = () => {
    app.request = {}
}
</script>

<template>
    <div>
        <Menu></Menu>
        <div style="max-width: 800px" class="mx-auto m-3">
            <div v-if="!app.request.request_number">
                <div class="mb-2">
                    <h3>Prompt</h3>
                    <b-form-input type="text" size="lg" v-model="prompt" />
                    <b-form-text>A short name for the series.</b-form-text>
                </div>

                <b-button class="my-3 w-100" @click="request_image" size="lg">Create Artwork!</b-button>
            </div>
            <div v-else-if="app.request.prompt">
                <img class="w-100" v-if="app.request.img_src" :src="app.request.img_src">

                <h3>
                    <span v-if="!app.request.img_src">
                        Starting image generation...
                    </span>

                    <span v-else-if="!app.request.done">
                        Generating... {{ app.request.percentage }}% complete
                    </span>

                    <span v-else-if="!app.request.accepted">
                    </span>

                    <span v-else-if="!app.request.published">
                        Publishing...
                    </span>
                </h3>

                <div v-if="!app.request.accepted">
                    <div class="mb-2">
                        <h3>Author</h3>
                        <b-form-input type="text" size="lg" v-model="author" placeholder="Enter you name/handle" />
                        <b-form-text>For twitter handles, use the @ notation (@Boring_Crypto). You can also use just a name/handle.</b-form-text>
                    </div>

                    <div class="mb-2">
                        <h3>Title</h3>
                        <b-form-input type="text" size="lg" v-model="name" placeholder="Enter a short title for the work" />
                        <b-form-text>A short name for the series.</b-form-text>
                    </div>

                    <div class="mb-2">
                        <h3>Description <small>(optional)</small></h3>
                        <b-form-textarea size="lg" v-model="description" placeholder="Optionally enter a description" />
                        <b-form-text>A description for the series, such as the inspiration or meaning behind it.</b-form-text>
                    </div>

                    <div v-if="app.request.done && !app.request.accepted" class="w-100">
                        <h3>Do you like it?</h3>
                        <b-button class="my-3 me-3" @click="reject" size="lg">Nope</b-button>
                        <b-button class="my-3 ms-3" @click="accept" size="lg">Yes!</b-button>
                    </div>
                </div>
            </div>
            <div v-else>
                <h3>Existing session found, loading...</h3>
            </div>
        </div>
    </div>
</template>

<style></style>
