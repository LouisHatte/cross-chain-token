import React from "react";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";

const App: React.FC = () => {
  const { isConnected } = useAccount();

  return (
    <div>
      <ConnectButton />
      {isConnected && <>Connected!</>}
      {!isConnected && <>Not connected...</>}
    </div>
  );
};

export default App;
