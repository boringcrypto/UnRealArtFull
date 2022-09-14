<script setup lang="ts">
import { computed, inject } from "vue"
import { useRouter } from "vue-router";
import Data from "../data-web3"

const app = inject("app") as typeof Data
const router = useRouter()
</script>

<template>
    <div class="ms-3 mt-3">
        <h2 style="color: var(--bs-link-color)">
            <router-link to="/"><i class="bi bi-house-fill"></i></router-link>&nbsp;
            <i @click="router.go(-1)" style="cursor: pointer" class="bi bi-arrow-left-circle-fill"></i>
        </h2>
    </div>
</template>
