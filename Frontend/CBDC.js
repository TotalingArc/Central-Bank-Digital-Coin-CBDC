// src/CBDC.js
import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import CBDC from './CBDC.json';

const CBDC_ADDRESS = "YOUR_SMART_CONTRACT_ADDRESS_HERE";

const CBDCApp = () => {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [contract, setContract] = useState(null);
  const [account, setAccount] = useState(null);
  const [balance, setBalance] = useState(0);
  const [interestRate, setInterestRate] = useState(0);
  const [amount, setAmount] = useState('');

  useEffect(() => {
    const loadBlockchainData = async () => {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(CBDC_ADDRESS, CBDC.abi, signer);
      
      const accounts = await provider.send("eth_requestAccounts", []);
      const account = accounts[0];

      const balance = await contract.balanceOf(account);
      const interestRate = await contract.interestRateBasisPoints();

      setProvider(provider);
      setSigner(signer);
      setContract(contract);
      setAccount(account);
      setBalance(ethers.utils.formatEther(balance));
      setInterestRate(interestRate.toNumber());
    };

    loadBlockchainData();
  }, []);

  const handleStake = async () => {
    const tx = await contract.stakeTreasuryBonds(ethers.utils.parseEther(amount));
    await tx.wait();
    alert('Staked successfully');
  };

  const handleUnstake = async () => {
    const tx = await contract.unstakeTreasuryBonds(ethers.utils.parseEther(amount));
    await tx.wait();
    alert('Unstaked successfully');
  };

  const handleClaim = async () => {
    const tx = await contract.claimTreasuryBonds();
    await tx.wait();
    alert('Claimed successfully');
  };

  return (
    <div>
      <h1>Central Bank Digital Coin (CBDC)</h1>
      <p>Account: {account}</p>
      <p>Balance: {balance} CBDC</p>
      <p>Interest Rate: {interestRate / 100}%</p>
      <input 
        type="text" 
        placeholder="Amount to stake/unstake" 
        value={amount} 
        onChange={(e) => setAmount(e.target.value)} 
      />
      <button onClick={handleStake}>Stake</button>
      <button onClick={handleUnstake}>Unstake</button>
      <button onClick={handleClaim}>Claim Rewards</button>
    </div>
  );
};

export default CBDCApp;
