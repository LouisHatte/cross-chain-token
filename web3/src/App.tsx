import React from "react";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";

import Bridge from "./Bridge";

const App: React.FC = () => {
  const { isConnected } = useAccount();

  return (
    <div className="flex h-screen w-screen flex-col overflow-hidden bg-black p-5 text-white">
      <div className="flex justify-end">
        <ConnectButton />
      </div>
      <div className="flex-1">{isConnected && <Bridge />}</div>
    </div>
  );
};

export default App;
