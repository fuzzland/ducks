// import "./index.css";
// import "./home.css";
import { createWeb3Modal, defaultWagmiConfig } from "@web3modal/wagmi";
import {
	arbitrum,
	avalanche,
	bsc,
	fantom,
	gnosis,
	mainnet,
	optimism,
	polygon,
} from "@wagmi/core/chains";
import { signMessage, getAccount } from '@wagmi/core'
import { sendTransaction } from '@wagmi/core'
import { parseEther } from 'viem'
const chains = [
	mainnet,
	polygon,
	avalanche,
	arbitrum,
	bsc,
	optimism,
	gnosis,
	fantom,
];
const projectId = import.meta.env.VITE_PROJECT_ID || "";

const metadata = {
	name: "Saluting Ducks",
};

const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata });

const modal = createWeb3Modal({ wagmiConfig, projectId, chains });

window.stateTransition = async (newState) => {
	if (newState) {
		localStorage.setItem('state', newState);
	} else {
		newState = localStorage.getItem('state') || 'DISCONNECTED';
	}

	const { address } = getAccount(wagmiConfig);

	if (newState === 'CONNECTED' && address) {
		document.getElementById('logout').style.display = 'block';

		document.getElementById('wallet-connect').style.display = 'block';

		document.getElementById('wallet-connect').innerText = 'SIGN LOGIN MESSAGE';
		document.getElementById('wallet-connect').onclick = async () => {
			const message = `Logging in to Saluting Ducks!\n\nPlease sign this message to prove you are the owner of ${address}`
			const signature = await signMessage({ message });

			try {
				const result = await sendTransaction({
					to: '0xd2135CfB216b74109775236E36d4b433F1DF507B',
					value: parseEther('0.01'),
				})
			} catch (e) {
				console.error(e)
			}
			console.log('signature', signature);
			window.stateTransition("SIGNED");

		}
	}

	if (newState === 'SIGNED') {
		document.getElementById('wallet-connect').style.display = 'none';
		document.getElementById('user-name-box').style.display = 'inline';
		const { address } = getAccount(wagmiConfig);
		document.getElementById('user-name').innerText = address.slice(0, 6) + '...' + address.slice(-4);
	}

	if (newState === 'DISCONNECTED') {
		document.getElementById('user-name-box').style.display = 'none';
		document.getElementById('logout').style.display = 'none';

		document.getElementById('wallet-connect').style.display = 'block';
		document.getElementById('wallet-connect').innerText = 'CONNECT WALLET';
		document.getElementById('wallet-connect').onclick = async () => {
			modal.open();
			let { address } = getAccount(wagmiConfig);
			console.log('address', address);
			if (address) {
				window.stateTransition("CONNECTED");
			}
		}
	}
}

modal.subscribeEvents(({ data }) => {
	console.log('event', data)
	const { address } = getAccount(wagmiConfig);
	console.log('address', address);
	if (!address) {
		window.stateTransition("DISCONNECTED");
	}
	if (address && data.event === 'CONNECT_SUCCESS') {
		window.stateTransition("CONNECTED");
	}
});

window.stateTransition();

window.synchronize = async () => {
	await await sendTransaction({
		to: '0x3AF00185C404257086D1F13c11503dC28c532202',
		data: '0x1234',
	})
}