import { createApp, reactive } from "vue"
import { createRouter, createWebHashHistory, createWebHistory } from "vue-router"
import { BigNumber } from "ethers"
import BootstrapVue from "bootstrap-vue-3"

import "bootswatch/dist/superhero/bootstrap.min.css"
import "bootstrap-vue-3/dist/bootstrap-vue-3.css"
import "bootstrap-icons/font/bootstrap-icons.css"

import App from "./App.vue"
import Home from "./pages/Home.vue"
import ImageDetail from "./pages/ImageDetail.vue"
import AllSeries from "./pages/AllSeries.vue"
import Series from "./pages/Series.vue"
import SlideShow from "./pages/SlideShow.vue"
import Manager from "./pages/Manager.vue"

import Data from "./data-web3"
import Decimal from "decimal.js-light"

Decimal.config({ precision: 36 })
Decimal.config({ toExpNeg: -1000 })
Decimal.config({ toExpPos: 1000 })

// this is just for debugging
declare global {
    interface Window {
        data: any
    }
}

declare module "decimal.js-light" {
    interface Decimal {
        toInt: (decimals: number) => BigNumber
    }
}

Decimal.prototype.toInt = function (decimals: number) {
    return BigNumber.from(
        this.times(new Decimal("10").pow(new Decimal(decimals.toString())))
            .todp(0)
            .toString()
    )
}

declare module "ethers" {
    interface BigNumber {
        toDec: (decimals?: number) => Decimal
    }
}

BigNumber.prototype.toDec = function (decimals?: number) {
    return new Decimal(this.toString()).dividedBy(new Decimal(10).toPower((decimals || 0).toString()))
}

const BigNumberMax = (...args: BigNumber[]) => args.reduce((m, e) => (e > m ? e : m))
const BigNumberMin = (...args: BigNumber[]) => args.reduce((m, e) => (e < m ? e : m))

declare module "@vue/runtime-core" {
    interface ComponentCustomProperties {
        app: typeof Data
    }
}

async function main() {
    const app = createApp(App)
    await Data.web3.setup()
    window.data = Data
    app.config.globalProperties.app = reactive(Data)
    app.provide("app", app.config.globalProperties.app)

    app.use(
        createRouter({
            history: createWebHashHistory(),
            routes: [
                { path: "/", component: Home },
                { path: "/image/:series/:image", component: ImageDetail },
                { path: "/series/all", component: AllSeries },
                { path: "/series/:series", component: Series },
                { path: "/slide/:screen/:gallery", component: SlideShow },

                { path: "/manager", component: Manager },
            ],
        })
    )
    app.use(BootstrapVue)
    app.mount("#app")
}

main()
