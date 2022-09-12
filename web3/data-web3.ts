import { markRaw, reactive, toRaw } from "vue"
import Web3 from "../sdk/Web3"
import { BigNumber } from "ethers"
import { UnRealArt__factory } from "../typechain-types"
import { Network } from "../sdk/Network"
import { connectors } from "../sdk/NetworkConnectors"
import Rand from "rand-seed"

const network = new connectors[Network.ETHEREUM]()

type Serie = {
    creator: string
    author: string
    name: string
    description: string
    process: string
    price: BigNumber
    images: string[]
}

export default reactive({
    title: "UnRealArt",
    name: "UnRealArt",
    web3: new Web3(),
    contract: markRaw(UnRealArt__factory.connect("0x8d41Bd479622B68ecF5E59d68B1a2400bE465052", network.provider)),

    ipfs: null as any,
    series: [] as Serie[],

    serie: 0,
    image: 0,

    gallery: "0x0000000000000000000000000000000000000000",

    randomList: (length: number) => {
        const list = Array.from({ length: length }, (v, k) => k)
        for (var j, x, i = list.length; i; j = Math.floor(Math.random() * i), x = list[--i], list[i] = list[j], list[j] = x);
        return list
    },

    randomListWithSeed: (seed: number, length: number) => {
        const list = Array.from({ length: length }, (v, k) => k)
        const rand = new Rand(seed.toString())
        for (var j, x, i = list.length; i; j = Math.floor(rand.next() * i), x = list[--i], list[i] = list[j], list[j] = x);
        return list
    },
})
