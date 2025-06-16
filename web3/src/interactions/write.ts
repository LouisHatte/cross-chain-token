import { useWriteContract } from "wagmi";
import type { Abi, Address, WalletClient } from "viem";
import { writeContract } from "viem/actions";

import { CONTRACTS, CHAIN_SELECTORS } from "@/constants/web3";
import type { CCIPMessage } from "@/utils/ccip";

import snailTokenAbi from "@/abi/snail-token.json";
import ccipRouterAbi from "@/abi/ccip-router.json";

/**
 * Approves the CCIP Router to spend a specified amount of tokens on behalf of the user.
 *
 * @param walletClient - The WalletClient instance used to sign and send the transaction.
 * @param chainId - The ID of the blockchain network where the token contract resides.
 * @param address - The address of the token contract (typically the SnailToken).
 * @param amount - The amount of tokens (as a bigint) to approve for spending.
 * @returns A Promise resolving to the transaction result.
 *
 * @example
 * await approve(walletClient, 1, '0xabc...', BigInt(1e18));
 */
export async function approve(
  walletClient: WalletClient,
  chainId: number,
  address: Address,
  amount: bigint,
) {
  return await writeContract(walletClient, {
    chain: walletClient.chain,
    account: walletClient.account!,
    abi: snailTokenAbi.abi as Abi,
    address,
    functionName: "approve",
    args: [CONTRACTS[chainId].ccipRouter, amount],
  });
}

/**
 * Custom React hook for sending cross-chain messages using CCIP.
 *
 * @returns An object containing:
 * - `bridge`: A function to initiate a cross-chain message via `ccipSend`.
 * - `hash`: The transaction hash of the latest bridge operation, if available.
 *
 * @example
 * const { bridge, hash } = useBridge();
 * await bridge(1, message);
 */
export function useBridge() {
  const { writeContractAsync, data: hash } = useWriteContract();

  const bridge = async (chainId: number, message: CCIPMessage) => {
    await writeContractAsync({
      abi: ccipRouterAbi as Abi,
      address: CONTRACTS[chainId].ccipRouter,
      functionName: "ccipSend",
      args: [CHAIN_SELECTORS[chainId as keyof typeof CHAIN_SELECTORS], message],
    });
  };

  return { bridge, hash };
}
