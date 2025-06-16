import type { Address } from "viem";

type Contracts = {
  snailToken: Address;
  ccipRouter: Address;
  linkToken: Address;
};

export const RPC_URLS = {
  sepolia: import.meta.env.VITE_ETH_SEPOLIA_RPC_URL,
  baseSepolia: import.meta.env.VITE_BASE_SEPOLIA_RPC_URL,
};

export const CONTRACTS: Record<number, Contracts> = {
  // Sepolia
  11155111: {
    snailToken: import.meta.env.VITE_SNAIL_TOKEN_CONTRACT_ETH_SEPOLIA,
    ccipRouter: "0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59",
    linkToken: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
  },
  // Base Sepolia
  84532: {
    snailToken: import.meta.env.VITE_SNAIL_TOKEN_CONTRACT_BASE_SEPOLIA,
    ccipRouter: "0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93",
    linkToken: "0xE4aB69C077896252FAFBD49EFD26B5D171A32410",
  },
};

export const CHAIN_SELECTORS = {
  11155111: "10344971235874465080", // Base Sepolia selector when bridging from Eth Sepolia
  84532: "16015286601757825753", // Eth Sepolia selector when bridging from Base Sepolia
};
