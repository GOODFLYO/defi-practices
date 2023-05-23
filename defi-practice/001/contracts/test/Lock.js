const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ZYN and Vault_start test", function () {
  let ZYN;
  let Vault_start;
  let owner;
  let rep;

  beforeEach(async function () {
    [owner, rep] = await ethers.getSigners();
    // console.log(owner.address,rep.address);

    const MyContractA = await ethers.getContractFactory("ZYN");
    ZYN = await MyContractA.deploy();

    const MyContractB = await ethers.getContractFactory("Vault");
    Vault_start = await MyContractB.deploy(ZYN.address);
    // 部署erc20合约
    await ZYN.deployed();
    // 部署vault合约
    await Vault_start.deployed();
  });

  it("should return correct value from ZYN", async function () {
    // 给自己地址增发1000个币
    await ZYN.mint(owner.address, 1000);
    // 对vault进行approve
    await ZYN.approve(Vault_start.address, 1000);
    // 在vault合约充值
    await Vault_start.deposit(1000);
    // 模拟盈利 vault增发1000
    await ZYN.mint(Vault_start.address, 1000);
    // 提取全部share
    await Vault_start.withdraw(1000);

    // owner的余额应该为2000
    expect(await ZYN.balanceOf(owner.address)).to.equal(2000);
    // owner在vault的shares应该为0
    expect(await Vault_start.balanceOf(owner.address)).to.equal(0);
  });

  it("should return correct value from Vault_start", async function () {
    // Test logic for MyContractB here
  });
});
