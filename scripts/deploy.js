// scripts/deploy.js

async function main() {
  // We get the contract to deploy
  const MetaSaga = await ethers.getContractFactory("MetaSaga");

  // Replace 'MyTokenName' and 'MTK' with your desired token name and symbol
  const tokenName = "MetaSagaToken";
  const tokenSymbol = "mst";

  // Deploy contract
  const metaSaga = await MetaSaga.deploy(tokenName, tokenSymbol, "0x40bd754b9715251Ba7E903a9586e919Ed23549eF");

  await metaSaga.deployed();

  console.log("MetaSaga deployed to:", metaSaga.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
      console.error(error);
      process.exit(1);
  });
