//@ts-ignore
import { require } from "@hyperoracle/zkgraph-lib";
import { Bytes, Event, BigInt } from "@hyperoracle/zkgraph-lib";

var esig_sync = Bytes.fromHexString(
  "0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1",
);
var esig_swap = Bytes.fromHexString(
  "0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822",
);

var token0_decimals = 8;
var token1_decimals = 18;

var token0_factor = BigInt.from(10).pow(token1_decimals);
var token1_factor = BigInt.from(10).pow(token0_decimals);
var decimalbase = BigInt.from(10).pow(4);
function calcRatio(syncEvent: Event): BigInt {
  const source = changetype<Bytes>(syncEvent.data);
  const reserve0 = source.slice(0, 32);
  const reserve1 = source.slice(32, 64);

  const r0 = BigInt.fromBytesBigEndian(reserve0);
  const r1 = BigInt.fromBytesBigEndian(reserve1);
  let ratio = r0
    .times(token0_factor)
    .times(decimalbase)
    .div(r1.times(token1_factor));

  return ratio;
}

export function handleEvents(events: Event[]): Bytes {
  let lastSyncEvent: Event | null = null;

  for (let i = events.length - 1; i >= 0; i--) {
    if (events[i].esig == esig_sync) {
      //   console.log('SYNC event');
      lastSyncEvent = events[i];
      break;
    }
  }

  if (lastSyncEvent == null) {
    // Don't Trigger if there's no event in the block
    require(false);
    return Bytes.empty(); // Omit compile error, never goes here
  } else {
    let ratio = calcRatio(lastSyncEvent);

    // rebalance(uint256)
    //f4993018cf1db379be1053b15816b2c65cb6d0fbf9e77cd3eeba21dd0e135cb5
    let function_selector = Bytes.fromHexString("6ea30ce9");
    // Set payload to the current price0 when triggering destination contract.
    // 32 bytes function selector + 28 bytes ratio
    // 4 bytes selector || 28 bytes parameter. 000000000000000000012345
    let payload = Bytes.fromByteArray(function_selector.concat(Bytes.fromHexString(ratio.toString(16)).padStart(28, 0)));
    return payload;
  }
}
