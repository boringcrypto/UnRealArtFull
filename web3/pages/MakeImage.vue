<script setup lang="ts">
import { computed, inject, ref, watch } from "vue"
import { useRoute } from "vue-router"
import Image from "../components/Image.vue"
import Data from "../data-web3"
import Menu from "../components/Menu.vue";
import axios from "axios";
import Cookies from "js-cookie"

const app = inject("app") as typeof Data
const author = ref("")
const name = ref("")
const description = ref("")

const prompt = ref("")
const style = ref("--test --creative")
const full_prompt = computed(() => {
    let p = prompt.value
    var re = /[a-zA-Z'0-9, ]+/g;
    p = (p.match(re || []) || []).join('');
    p = p + ", " + style.value
    p = p + " --ar 3:2"
    p.replaceAll("  ", " ")
    return p
})

const moods = [
    "Cheerful",
    "Reflective",
    "Gloomy",
    "Humorous",
    "Melancholy",
    "Idyllic",
    "Whimsical",
    "Romantic",
    "Mysterious",
    "Ominous",
    "Calm",
    "Lighthearted",
    "Hopeful",
    "Angry",
    "Fearful",
    "Tense",
    "Lonely"
]

const suggestions = [
    "happiness",
    "the 4th dimension",
    "the end of the world",
    "kitchen sink",
    "pattern",
    "space",
    "skyline", 
    "apple", 
    "fairy with wings",
    "portrait",
    "cyborg",
    "still life", 
    "lush garden", 
    "rolling hills", 
    "mountain cliff", 

    "epic",
    "dramatic lighting",
    "futuristic",
    "old and worn",
    "intricate details",

    "35mm",
    "isomorphic",
    "fish eye lens",
    "selfie",
    "bird's eye view"
]

const add = (suggestion: string) => {
    prompt.value = prompt.value + (prompt.value ? ", " : "") + suggestion
}

const styles = {
    "Pixar": "pixar style, cute, adorable, cinematic, intricate detail, dramatic lighting --testp",
    "Herman Brood": "herman brood --test --creative",
    "Van Gogh": "van gogh --test --creative",
    "Basquiat": "jean-michel basquiat --test --creative",
    "Line Art": "line art --test",
    "Vector": "vector --test",
    "Halftone": "halftone --test",
    "Watercolor": "watercolor --test",
    "Oil painting": "oil painting --test",
    "Technical drawing": "intricate technical drawing, schematic blueprint, old, weathered --test",
    "Anime": "ghost in the shell, kentaro miura --test",
    "Anime/fantasy": "ghost in the shell, karol bak --test",
    "Steampunk": "steampunk --test",
    "Cyberpunk": "cyberpunk --test",
    "Pop Art": "pop art --test",
    "Japanese": "japanese art --test",
    "Graffiti": "graffiti, street art --test",
    "Clip Art": "clip art --test",
    "Seamless Tiles": "--test --tile",
    "Pixel Art": "pixel art --test",
    "Children's Book": "children's book illustration --test",
    "Doodle": "doodle --test",
    "Octane Render": "octane render, photorealistic, 8k --testp",
    "Other (artistic)": "--test --creative",
    "Other (realistic)": "photorealistic, 8k --testp",
}

const request_image = async () => {
    const res = await axios.get(app.bot + "request/" + full_prompt.value)
    app.request = res.data
    Cookies.set("r", app.request.request_number)
}

const accept = async() => {
    const res = await axios.get(app.bot + "publish/" + app.request?.request_number + "/" + author.value + "/" + name.value + "/" + description.value)
    app.request = res.data
}

const reject = () => {
    app.request = {}
}

const again = () => {
    app.request = {}
}
</script>

<template>
    <div>
        <Menu></Menu>
        <div style="max-width: 800px" class="mx-auto m-3">
            <div v-if="!app.request.request_number">
                <div class="mb-2">
                    <h3>What would you like to see?</h3>
                    <b-form-input type="text" size="lg" v-model="prompt" placeholder="Enter some words here" />
                    <b-form-text>
                        Describe what you would like to create.
                        Or click some words below to add them.
                    </b-form-text><br>
                    <b-button v-for="suggestion in suggestions" @click="add(suggestion)" class="m-1">{{ suggestion }}</b-button>
                </div>
                <div v-if="prompt">
                    <h3 class="mt-3">Style</h3>
                    <b-form-select v-model="style">
                        <b-form-select-option v-for="v, s in styles" :value="v">{{ s }}</b-form-select-option>
                    </b-form-select>

                    <b-button class="my-3 w-100" @click="request_image" size="lg">Preview work!</b-button>

                    <h5 class="mt-3">Actual prompt used with Midjourney (AI software)</h5>
                    <p>
                        {{ full_prompt }}
                    </p>
                </div>
            </div>

            <div v-else-if="app.request.prompt">
                <img class="w-100" v-if="app.request.img_src" :src="app.request.img_src">

                <h3 class="mt-3">
                    <span v-if="app.request.status == 'Waiting'">
                        Starting image generation...
                        <span v-if="app.queue">{{ app.queue }} in the queue before you.</span>
                    </span>

                    <span v-if="app.request.status == 'Painting'">
                        Generating... {{ app.request.percentage }}% complete<br>
                        <b-form-text>
                            Your text prompt has been sent to MidJourney. 
                            MidJourney is one of many Artificial Intelligence text to image generators.
                            Other well known platforms are DALL-E 2 and Dream Studio (Stable Diffusion).
                        </b-form-text>
                    </span>

                    <span v-if="app.request.status == 'Upscaling'">
                        Upscaling... {{ app.request.percentage }}% complete<br>
                        <b-form-text>
                            The low resolution version of your image is ready, the AI is now generating a higher resolution image for the big screen.
                        </b-form-text>
                    </span>

                    <span v-if="app.request.status == 'Published'">
                        <b-button class="my-3 me-3" @click="again" size="lg">Start Again</b-button>
                    </span>

                    <span v-if="app.request.status == 'Error'">
                        {{ app.request.error }}<br>
                        <br>
                        <b-button class="my-3 me-3" @click="again" size="lg">Start Again</b-button>
                    </span>
                </h3>

                <div v-if="app.request.status == 'Finished'" class="w-100">
                    <h3>Publish it to the big screen?</h3>
                    <b-button class="my-3 me-3" @click="reject" size="lg">Nope</b-button>
                    <b-button class="my-3 ms-3" @click="accept" size="lg">Yes!</b-button>
                </div>

                <div class="mb-2">
                    <h3>Author</h3>
                    <b-form-input type="text" size="lg" v-model="author" placeholder="Enter you name/handle" />
                </div>

                <div class="mb-2">
                    <h3>Title</h3>
                    <b-form-input type="text" size="lg" v-model="name" placeholder="Enter a short title for the work" />
                    <b-form-text>A short name for the work.</b-form-text>
                </div>
            </div>
            <div v-else>
                <h3>Existing session found, loading...</h3>
            </div>
        </div>
    </div>
</template>

<style></style>
