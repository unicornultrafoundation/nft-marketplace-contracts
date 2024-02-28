const { expect } = require('chai');
const { hre, upgrades } = require('hardhat');
const {
  loadFixture,
  time,
} = require('@nomicfoundation/hardhat-toolbox/network-helpers');

describe('Buy', function () {
  async function deployFixture() {
    const [acc1, acc2, acc3, acc4, acc5, acc6, acc7] =
      await ethers.getSigners();

    const contractNFT = await ethers.deployContract('NFT');

    const contractFETH = await ethers.deployContract('FETH');
    await contractFETH.deposit({ value: 100 });

    const factoryERC721NFTMarketplace = await ethers.getContractFactory(
      'ERC721NFTMarketplace'
    );
    const contractERC721NFTMarketplace = await upgrades.deployProxy(
      factoryERC721NFTMarketplace,
      ['0x0000000000000000000000000000000000000000', contractFETH.target],
      {
        initializer: 'initialize',
        kind: 'transparent',
      }
    );

    const factoryERC1155NFTMarketplace = await ethers.getContractFactory(
      'ERC1155NFTMarketplace'
    );
    const contractERC1155NFTMarketplace = await upgrades.deployProxy(
      factoryERC1155NFTMarketplace,
      ['0x0000000000000000000000000000000000000000', contractFETH.target],
      {
        initializer: 'initialize',
        kind: 'transparent',
      }
    );

    const factoryRoyaltiesRegistry = await ethers.getContractFactory(
      'RoyaltiesRegistry'
    );
    const contractRoyaltiesRegistry = await upgrades.deployProxy(
      factoryRoyaltiesRegistry,
      {
        initializer: 'initialize',
        kind: 'transparent',
      }
    );

    const factoryFeeDistributor = await ethers.getContractFactory(
      'FeeDistributor'
    );
    const contractFeeDistributor = await upgrades.deployProxy(
      factoryFeeDistributor,
      [
        contractERC721NFTMarketplace.target,
        contractERC1155NFTMarketplace.target,
        contractRoyaltiesRegistry.target,
        acc2.address,
        250,
        5000,
      ],
      {
        initializer: 'initialize',
        kind: 'transparent',
      }
    );

    await contractNFT.mintBatchNFT(acc3.address, 10);
    await contractERC721NFTMarketplace.setFeeDistributor(
      contractFeeDistributor.target
    );
    await contractERC1155NFTMarketplace.setFeeDistributor(
      contractFeeDistributor.target
    );
    await contractNFT
      .connect(acc3)
      .setApprovalForAll(contractERC721NFTMarketplace.target, true);
    for (let i = 0; i < 10; i++) {
      await contractERC721NFTMarketplace
        .connect(acc3)
        .createAsk(contractNFT.target, i + 1, contractFETH.target, '1000000000000000000');
    }

    return {
      contractNFT,
      contractFETH,
      contractERC721NFTMarketplace,
      contractERC1155NFTMarketplace,
      contractRoyaltiesRegistry,
      contractFeeDistributor,
      acc1,
      acc2,
      acc3,
      acc4,
      acc5,
      acc6,
      acc7,
    };
  }

  it('Should allow users to buy batch ERC721 NFTs', async function () {
    const {
      contractNFT,
      contractFETH,
      contractERC721NFTMarketplace,
      contractERC1155NFTMarketplace,
      contractRoyaltiesRegistry,
      contractFeeDistributor,
      acc1,
      acc2,
      acc3,
      acc4,
      acc5,
      acc6,
      acc7,
    } = await loadFixture(deployFixture);
    // Create an array of 10 elements with each of them is contractNFT.target
    let nfts = new Array(10);
    let tokenIds = new Array(10);

    // Populate array with contract target
    for (let i = 0; i < nfts.length; i++) {
      nfts[i] = contractNFT.target;
      tokenIds[i] = i + 1;
    }

    // await contractFETH.connect(acc4).deposit({ value: '10125000000000000000' });
    // await contractFETH
    //   .connect(acc4)
    //   .approve(contractERC721NFTMarketplace.target, '10125000000000000000');

    // const tx = await contractERC721NFTMarketplace.connect(acc4).buyBatch(nfts, tokenIds);
    // const txReceipt = await tx.wait();
    // const txETH = await contractERC721NFTMarketplace.connect(acc4).buyUsingEthBatch(nfts, tokenIds, {value: 1012});
    await expect(
      contractERC721NFTMarketplace
        .connect(acc4)
        .buyUsingEthBatch(nfts, tokenIds, { value: '10125000000000000000' })
    ).to.changeEtherBalance(acc4, '-10125000000000000000');
    // expect(await contractFETH.balanceOf(acc4.address)).to.equal(980);
    const balance2 = await contractFETH.balanceOf(acc2.address);
    const balance3 = await contractFETH.balanceOf(acc3.address);
    const balance4 = await contractFETH.balanceOf(acc4.address);
    const balanceMarketplace = await contractFETH.balanceOf(
      contractERC721NFTMarketplace.target
    );
    const balanceFeeDistributor = await contractFETH.balanceOf(
      contractFeeDistributor.target
    );
    console.log(
      'balance2: ', balance2,
      ' balance3: ', balance3,
      ' balance4: ', balance4,
      ' balanceMarketplace: ', balanceMarketplace,
      ' balanceFeeDistributor: ', balanceFeeDistributor,
      ' acc3: ', acc3.address,
    );
    // expect(await contractNFT.balanceOf(acc3.address)).to.equal(987);
    // const txETHReceipt = await txETH.wait();
    // const balanceFETH = await contractFETH.balanceOf(acc4.address);
    // const provider = ethers.getDefaultProvider();
    // console.log('provider: ', provider);
    // const balanceETH = await hre.network.provider.getBalance(acc4.address);
    // const balanceNFT = await contractNFT.balanceOf(acc4.address);
    // console.log('txETH: ', txETH, ' txETHReceipt:', txETHReceipt, ' balanceETH: ', balanceETH, ' balanceNFT: ', balanceNFT);
  });
});
