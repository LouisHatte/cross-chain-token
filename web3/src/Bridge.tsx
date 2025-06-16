import React, { useState } from "react";
import { useForm } from "react-hook-form";
import { useAccount, usePublicClient, useWalletClient } from "wagmi";
import { sepolia } from "wagmi/chains";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { formatEther, type Address } from "viem";
import { waitForTransactionReceipt } from "viem/actions";

import { useTokenBalance, getAllowance, getCCIPFee } from "@/interactions/read";
import { approve, useBridge } from "@/interactions/write";
import { buildMessage } from "@/utils/ccip";
import { CONTRACTS } from "@/constants/web3";

const Bridge: React.FC = () => {
  const publicClient = usePublicClient();
  const { data: walletClient } = useWalletClient();

  const { address: a, chainId: c } = useAccount();
  const address = a as Address;
  const chainId = c as number;

  const [isBridging, setIsBridging] = useState(false);

  const { data: balance } = useTokenBalance(chainId, address);
  const { bridge, hash: bridgeHash } = useBridge();

  const from = chainId === sepolia.id ? "Sepolia" : "Base Sepolia";
  const to = chainId === sepolia.id ? "Base Sepolia" : "Sepolia";

  const schema = z.object({
    amount: z
      .number()
      .min(1, "Must be at least 1 wei")
      .max(100_000, "Must be at most 100,000 wei"),
  });
  type FormData = z.infer<typeof schema>;

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  async function handleBridge(data: FormData) {
    if (!publicClient || !walletClient) return;

    try {
      setIsBridging(true);

      const amountInWei = BigInt(data.amount);

      const allowance = await getAllowance(publicClient, chainId, address);
      if (allowance < amountInWei) {
        const approveHash = await approve(
          walletClient,
          chainId,
          CONTRACTS[chainId].snailToken,
          amountInWei,
        );
        await waitForTransactionReceipt(publicClient, {
          hash: approveHash,
        });
      }

      const message = buildMessage(chainId, address, amountInWei);
      const ccipFee = await getCCIPFee(publicClient, chainId, message);

      await approve(
        walletClient,
        chainId,
        CONTRACTS[chainId].linkToken,
        ccipFee,
      );

      await bridge(chainId, message);

      setIsBridging(false);
    } catch (err) {
      console.error("error: ", err);
      setIsBridging(false);
    }
  }

  return (
    <div className="flex h-full w-full flex-col items-center justify-center">
      <h1 className="mb-12 text-center text-2xl font-bold">
        Bridge your SNAIL tokens from {from} to {to}
      </h1>

      <form
        onSubmit={handleSubmit(handleBridge)}
        className="mb-6 flex flex-col gap-2"
      >
        <div className="min-h-[24px] text-red-600">
          {errors.amount?.message}
        </div>
        <div className="flex gap-4">
          <input
            type="text"
            autoFocus
            {...register("amount", { valueAsNumber: true })}
            placeholder="Amount in wei"
            className="rounded-lg border border-white bg-black p-3 text-xl placeholder-gray-400 focus:ring-0 focus:outline-none"
          />
          <button
            type="submit"
            disabled={isBridging}
            className="cursor-pointer rounded-xl border border-white bg-white p-3 text-xl font-semibold text-black disabled:cursor-not-allowed disabled:bg-gray-300"
          >
            Bridge
          </button>
        </div>
      </form>

      <div className="text-center">
        Current balance: {balance ? formatEther(balance) : 0} SNAIL
        <div className="mt-4 text-sm text-gray-400">
          {bridgeHash && <div>Bridge tx: {bridgeHash}</div>}
        </div>
      </div>
    </div>
  );
};

export default Bridge;
