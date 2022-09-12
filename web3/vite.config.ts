import { defineConfig } from "vite"
import vue from "@vitejs/plugin-vue"

// https://vitejs.dev/config/
export default defineConfig({
    root: "web3",
    plugins: [vue()],
    server: {
        port: 8080,
    },
    optimizeDeps: {
        esbuildOptions: { target: "es2020", supported: { bigint: true } },
    },
})
