import { useReadContract } from "wagmi";
import type { Abi, Address, PublicClient } from "viem";
import { readContract } from "viem/actions";

import { CONTRACTS, CHAIN_SELECTORS } from "@/constants/web3";
import type { CCIPMessage } from "@/utils/ccip";

import snailTokenAbi from "@/abi/snail-token.json";
import ccipRouterAbi from "@/abi/ccip-router.json";

/**
 * Custom React hook to read the ERC-20 token balance of the SNAIL token on a specific chain.
 *
 * @param chainId - The ID of the blockchain network.
 * @param address - The wallet address whose token balance is being queried.
 * @returns An object containing the token balance `data`.
 *
 * @example
 * const { data: balance } = useTokenBalance(1, "0xabc...");
 */
export function useTokenBalance(chainId: number, address: Address) {
  return useReadContract({
    abi: snailTokenAbi.abi as Abi,
    address: CONTRACTS[chainId].snailToken,
    functionName: "balanceOf",
    args: [address],
  }) as { data: bigint };
}

/**
 * Reads the current ERC-20 allowance granted to the CCIP Router by a given address.
 *
 * @param publicClient - The PublicClient instance used to read the contract.
 * @param chainId - The ID of the blockchain network.
 * @param address - The address of the token owner.
 * @returns A Promise that resolves to a `bigint` representing the allowance amount.
 *
 * @example
 * const allowance = await getAllowance(publicClient, 1, '0xabc...');
 */
export async function getAllowance(
  publicClient: PublicClient,
  chainId: number,
  address: Address,
) {
  return (await readContract(publicClient, {
    abi: snailTokenAbi.abi as Abi,
    address: CONTRACTS[chainId].snailToken,
    functionName: "allowance",
    args: [address, CONTRACTS[chainId].ccipRouter],
  })) as Promise<bigint>;
}

/**
 * Retrieves the estimated CCIP fee for sending a given message.
 *
 * @param publicClient - The PublicClient instance used to read the contract.
 * @param chainId - The ID of the blockchain network.
 * @param message - The CCIPMessage object describing the cross-chain operation.
 * @returns A Promise that resolves to a `bigint` representing the fee amount in the native token.
 *
 * @example
 * const fee = await getCCIPFee(publicClient, 1, message);
 */
export async function getCCIPFee(
  publicClient: PublicClient,
  chainId: number,
  message: CCIPMessage,
) {
  return (await readContract(publicClient, {
    abi: ccipRouterAbi as Abi,
    address: CONTRACTS[chainId].ccipRouter,
    functionName: "getFee",
    args: [CHAIN_SELECTORS[chainId as keyof typeof CHAIN_SELECTORS], message],
  })) as Promise<bigint>;
}
