import React from "react";
import { useAccount, useReadContract } from "wagmi";
import type { Abi } from "viem";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";

import snailTokenAbi from "./abi/snail-token.json";

type Contracts = {
  snailToken: `0x${string}`;
  snailTokenPool: `0x${string}`;
};

const CONTRACTS_BY_CHAIN: Record<number, Contracts> = {
  11155111: {
    snailToken: import.meta.env.VITE_SNAIL_TOKEN_CONTRACT_ETH_SEPOLIA,
    snailTokenPool: import.meta.env.VITE_SNAIL_TOKEN_POOL_CONTRACT_ETH_SEPOLIA,
  },
  84532: {
    snailToken: import.meta.env.VITE_SNAIL_TOKEN_CONTRACT_BASE_SEPOLIA,
    snailTokenPool: import.meta.env.VITE_SNAIL_TOKEN_POOL_CONTRACT_BASE_SEPOLIA,
  },
};

const Bridge: React.FC = () => {
  const { address, chainId } = useAccount();

  const {
    data: balance,
    isLoading,
    error,
  } = useReadContract({
    abi: snailTokenAbi.abi as Abi,
    address: CONTRACTS_BY_CHAIN[chainId!].snailToken,
    functionName: "balanceOf",
    args: [address],
  }) as { data: number | undefined; isLoading: boolean; error: Error | null };

  const from = chainId === 11155111 ? "Sepolia" : "Base Sepolia";
  const to = chainId === 11155111 ? "Base Sepolia" : "Sepolia";

  const schema = z.object({
    amount: z
      .number({ invalid_type_error: "Must be a number" })
      .min(1, "Must be at least 1")
      .max(balance ?? 0, `Must be at most ${balance}`),
  });
  type FormData = z.infer<typeof schema>;

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  function bridge(data: FormData) {
    console.log("data", data);
  }

  return (
    <div className="flex h-full w-full flex-col items-center justify-center">
      <h1 className="mb-12 text-center text-2xl font-bold">
        Bridge your SNAIL tokens from {from} to {to}
      </h1>

      <form
        onSubmit={handleSubmit(bridge)}
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
            placeholder="Amount to bridge"
            className="rounded-lg border border-white bg-black p-3 text-xl placeholder-gray-400 focus:ring-0 focus:outline-none"
          />
          <button
            type="submit"
            className="cursor-pointer rounded-xl border border-white bg-white p-3 text-xl font-semibold text-black"
          >
            Bridge
          </button>
        </div>
      </form>

      <div className="text-center">
        {!isLoading && !error
          ? `Current balance: ${balance} SNAIL`
          : "Current balance: loading..."}
        {error && <div>error: {error.toString()}</div>}
      </div>
    </div>
  );
};

export default Bridge;
