import "hardhat-deploy"
import { DeployFunction } from "hardhat-deploy/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"

const deployFunction: DeployFunction = async function ({ deployments, getChainId, getNamedAccounts }: HardhatRuntimeEnvironment) {
    const { deploy } = deployments
    const chainId = parseInt(await getChainId())
    const { deployer } = await getNamedAccounts()

    await deploy("UnRealArtV2", {
        from: deployer,
        args: [],
        log: true,
        deterministicDeployment: false,
    })
}

export default deployFunction
