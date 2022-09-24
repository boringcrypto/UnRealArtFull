import { markRaw, reactive } from "vue"
import Web3 from "../sdk/Web3"
import { ethers } from "ethers"
import * as DeployedContract from "../deployments/localhost/UnRealArtV2.json"
import { UnRealArtV2__factory } from "../typechain-types"
import { Network } from "../sdk/Network"
import { connectors } from "../sdk/NetworkConnectors"
import Rand from "rand-seed"
import Cache from "./cache.json"

type Serie = {
    creator: string
    author: string
    name: string
    description: string
    process: string
    price: string
    images: string[]
}

const network = new connectors[Network.ETHEREUM]()
const address = "0xb46DAd35af4b45a7582B5e94128e7509cbEC4fd3" //DeployedContract.address
const contract = UnRealArtV2__factory.connect(address, network.provider)

export type Request = {
    prev_img_src: string
    prompt: string
    percentage: string
    job_id: string
    img_src: string
    request_number: string
    done: boolean
    accepted: boolean
    published: boolean
    author: string
    title: string
    description: string
    error: string
}

const app = reactive({
    title: "UnRealArt",
    name: "UnRealArt",
    web3: new Web3(),
    network: markRaw(network),
    contract: markRaw(contract),

    ipfs: null as any,
    series: Cache as unknown as Serie[],

    serie: 0,
    image: 1,

    request: {} as Request,
    queue: 0,

    gallery: ethers.constants.AddressZero,

    bot: "https://bot.un-real-art.com/",
    //bot: "http://localhost:12345/",

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

export const loadNewSeries = async () => {
    const seriesCount = (await contract.seriesCount()).toNumber()
    for (let i = app.series.length; i < seriesCount; i++) {
        console.log("Loading series " + i)
        const res = await contract.getSerie(i)
        app.series.push({
            creator: res.creator,
            author: res.author,
            name: res.name,
            description: res.description,
            process: res.process,
            price: res.price.toString(),
            images: res.artworks,
        })
    }
    console.log(JSON.stringify(app.series))
    console.log(app.series.map(s => s.images.length).reduce((a, b) => a + b, 0))
}

export default app
