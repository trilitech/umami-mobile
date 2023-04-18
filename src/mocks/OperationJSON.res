let tezTransactionsRaw = `
[
	{
		"type": "transaction",
		"id": 518156314476544,
		"level": 3340021,
		"timestamp": "2023-04-11T07:13:43Z",
		"block": "BLMF3QfBipTiZg4D8o7q35Rz4mZ1cG2wNKeqcrKN38dTVx2ktTJ",
		"hash": "ooVDmsrcnqjBYVfYxSujpcZBMCqhwoHNr4xoh4Le4McbdSnhk3m",
		"counter": 27315093,
		"sender": {
			"address": "tz1SgK78wg4ug6Y6P5R2DH5j8BAeVMfHcNaC"
		},
		"gasLimit": 10300,
		"gasUsed": 1001,
		"storageLimit": 300,
		"storageUsed": 0,
		"bakerFee": 1420,
		"storageFee": 0,
		"allocationFee": 0,
		"target": {
			"alias": "Upbit 12",
			"address": "tz1beW9AVJjE9QpTGYVPdtZCF5w1NPknMJ3T"
		},
		"amount": 1398580,
		"status": "applied",
		"hasInternals": false
	},
	{
		"type": "transaction",
		"id": 518149468323840,
		"level": 3339993,
		"timestamp": "2023-04-11T07:06:20Z",
		"block": "BM3LUdjsTMw6mt9upGf4nFHg1KNk1VHPRjmXeTKJ5tnyeMoKgqx",
		"hash": "oooRbGcps3F7zv3gcvo52EYPuboX2N4wNV7if1adTcxFi38Tr83",
		"counter": 83867919,
		"sender": {
			"address": "tz1VreUox3xqG7o5xbU1U69APw1hj1Y4xKCt"
		},
		"gasLimit": 10300,
		"gasUsed": 1001,
		"storageLimit": 300,
		"storageUsed": 0,
		"bakerFee": 1420,
		"storageFee": 0,
		"allocationFee": 0,
		"target": {
			"alias": "Upbit 12",
			"address": "tz1beW9AVJjE9QpTGYVPdtZCF5w1NPknMJ3T"
		},
		"amount": 414528974,
		"status": "applied",
		"hasInternals": false
	},
	{
		"type": "transaction",
		"id": 518149208276992,
		"level": 3339992,
		"timestamp": "2023-04-11T07:06:05Z",
		"block": "BM1XRWJB9nD1kgJa4SvtZWfTFGYdGbCrpZzncYd9BETkMBBPTgf",
		"hash": "ontw4Sb7ikohCUDcYhHfY8fuBCA9oExjDSRdT2w4JrnBZRzpBxc",
		"counter": 82000886,
		"sender": {
			"address": "tz1PwVFw6GjLyVmz3uM3tthLRmQZf6xZiH93"
		},
		"gasLimit": 10300,
		"gasUsed": 1001,
		"storageLimit": 300,
		"storageUsed": 0,
		"bakerFee": 1420,
		"storageFee": 0,
		"allocationFee": 0,
		"target": {
			"alias": "Upbit 12",
			"address": "tz1beW9AVJjE9QpTGYVPdtZCF5w1NPknMJ3T"
		},
		"amount": 75997159,
		"status": "applied",
		"hasInternals": false
	}
]`

let tokenTransactionsRaw = `
[
	{
		"id": 477509260935170,
		"level": 3194247,
		"timestamp": "2023-03-03T16:43:14Z",
		"token": {
			"id": 477204073938945,
			"contract": {
				"alias": "McLaren F1 Team 23/23 Collectibles",
				"address": "KT1BRADdqGk2eLmMqvyWzqVmPQ1RCBCbW5dY"
			},
			"tokenId": "1",
			"standard": "fa2",
			"totalSupply": "119634",
			"metadata": {
				"id": "1",
				"name": "1/23 McLaren F1 Collectible",
				"tags": [
					"Sports"
				],
				"minter": "tz2W1hS4DURJckg7iZaLXL18kh8C3SJuUaxv",
				"formats": [
					{
						"uri": "ipfs://QmQCBWyUJ3iaw8LfBDSHDKAfjjr9EcEheFdbLXNqBKNdiT",
						"mimeType": "video/mp4"
					},
					{
						"uri": "ipfs://QmSnANJhxw1Jb36hspXxayDVnma5ec48xi4Qq1iuzqzxcr",
						"mimeType": "image/png",
						"dimensions": {
							"unit": "px",
							"value": "1260x1780"
						}
					},
					{
						"uri": "ipfs://QmTB8g67SKZ2JQJVjNjSpXQSjWdCCgPcjDgmG4VuTxFF3R",
						"mimeType": "image/png",
						"dimensions": {
							"unit": "px",
							"value": "248x350"
						}
					}
				],
				"creators": [
					"tz2W1hS4DURJckg7iZaLXL18kh8C3SJuUaxv"
				],
				"decimals": "0",
				"displayUri": "ipfs://QmSnANJhxw1Jb36hspXxayDVnma5ec48xi4Qq1iuzqzxcr",
				"publishers": [
					"Tezos"
				],
				"artifactUri": "ipfs://QmQCBWyUJ3iaw8LfBDSHDKAfjjr9EcEheFdbLXNqBKNdiT",
				"description": "The first in the McLaren F1 Team 23/23 series, this Bahrain GP digital collectible incorporates famous landmarks and code stamps of the track and air temperature at the hottest Formula 1 race ever experienced in 2005. Collect all 23/23 to be in with a chance to receive an exclusive race experience and keep your eyes peeled for smaller collections and rewards. Powered by Tezos and brought to you by Tezos ecosystem companies. Terms apply: https://collectibles.mclaren.com/policies/terms",
				"thumbnailUri": "ipfs://QmTB8g67SKZ2JQJVjNjSpXQSjWdCCgPcjDgmG4VuTxFF3R",
				"isTransferable": true,
				"isBooleanAmount": true,
				"shouldPreferSymbol": false
			}
		},
		"to": {
			"address": "tz2P2UEjxQLWHvasvf2rR5LT8kbDgHJcxPqg"
		},
		"amount": "1",
		"transactionId": 477509260935168
	}
]`
