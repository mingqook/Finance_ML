import sys
import websockets
import asyncio 
import json
import pandas as pd
import signal

def signal_handler(signal, frame):
    print('You pressed Ctrl+C!')
    print('Saving data...')
    
    # process as dataframe
    df = pd.DataFrame(data_list)
    #df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
    df = df.set_index('sequential_id')
    #print(df)
    
    # save
    df.to_json(f'btc_tick_{count}.json')
    sys.exit(0)

async def upbit_ws_client():
    uri = "wss://api.upbit.com/websocket/v1"

    async with websockets.connect(uri) as websocket:
        subscribe_fmt = [ 
            {"ticket":"test"},
            {
                "type": "trade",
                "codes":["KRW-BTC"],
                "isOnlyRealtime": True
            },
            {"format":"DEFAULT"}
        ]
        subscribe_data = json.dumps(subscribe_fmt)
        await websocket.send(subscribe_data)
        
        global count
        global data_list
        count = 1
        data_list = list()

        while True:
            data = await websocket.recv()
            data = json.loads(data)
            data_list.append(data)
            if count % 100 == 0:
                print(f'Saving data: count {count}')
                #df = 
            count += 1
            signal.signal(signal.SIGINT, signal_handler)
            


async def main():
    print('Start receiving data...')
    await upbit_ws_client()

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
#asyncio.run(main())
