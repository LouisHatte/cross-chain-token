import type { Address, Hex } from "viem";

import { CONTRACTS } from "@/constants/web3";

type TokenAmount = {
  token: Address;
  amount: bigint;
};

export type CCIPMessage = {
  receiver: Hex;
  data: Hex;
  tokenAmounts: TokenAmount[];
  feeToken: Address;
  extraArgs: Hex;
};

/**
 * Constructs a `CCIPMessage` object for cross-chain token transfers.
 *
 * @param chainId - The ID of the source blockchain network.
 * @param address - The recipient's wallet address on the destination chain.
 * @param amount - The amount of tokens (as a bigint) to send.
 * @returns A `CCIPMessage` object formatted for the `ccipSend` function.
 *
 * The `receiver` address is padded to a 32-byte representation as required by CCIP.
 *
 * @example
 * const message = buildMessage('0xabc...', 1, BigInt(1e18));
 */
export function buildMessage(
  chainId: number,
  address: Address,
  amount: bigint,
): CCIPMessage {
  return {
    receiver: `0x000000000000000000000000${address.slice(2)}`,
    data: "0x",
    tokenAmounts: [
      {
        token: CONTRACTS[chainId].snailToken,
        amount: amount,
      },
    ],
    feeToken: CONTRACTS[chainId].linkToken,
    extraArgs: "0x",
  };
}
