import React from "react";
import ReactDOM from "react-dom/client";

import "./index.css";
import "@rainbow-me/rainbowkit/styles.css";

import { RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { WagmiProvider, createConfig, http } from "wagmi";
import { sepolia, baseSepolia } from "wagmi/chains";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";

import App from "@/App";
import { RPC_URLS } from "@/constants/web3";

export const config = createConfig({
  chains: [sepolia, baseSepolia],
  transports: {
    [sepolia.id]: http(RPC_URLS.sepolia),
    [baseSepolia.id]: http(RPC_URLS.baseSepolia),
  },
});

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          <App />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  </React.StrictMode>,
);
