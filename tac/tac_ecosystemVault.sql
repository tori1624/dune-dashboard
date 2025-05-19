with eth_price as (
    select date_trunc('day', minute) as dt
         , avg(price) as price
    from prices.usd
    where symbol = 'ETH'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-03-30'
),
btc_price as (
    select date_trunc('day', minute) as dt
         , avg(price) as price
    from prices.usd
    where symbol = 'BTC'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-03-30'
),
tacETH_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x294eecec65A0142e84AEdfD8eB2FBEA8c9a9fbad -- tacETH CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x294eecec65A0142e84AEdfD8eB2FBEA8c9a9fbad
         and to = 0x0000000000000000000000000000000000000000
        ) as raw
    group by 1
    having date_trunc('day', evt_block_time) >= date '2025-03-30'
),
tacBTC_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e8 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x6Bf340dB729d82af1F6443A0Ea0d79647b1c3DDf -- tacBTC CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e8 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x6Bf340dB729d82af1F6443A0Ea0d79647b1c3DDf
         and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
    having date_trunc('day', evt_block_time) >= date '2025-03-30'
),
tacUSD_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x699e04F98dE2Fc395a7dcBf36B48EC837A976490 -- tacUSD CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x699e04F98dE2Fc395a7dcBf36B48EC837A976490
         and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
    having date_trunc('day', evt_block_time) >= date '2025-03-30'
), 
supply_summary as (
    select dt
         , sum(e.amount) over(order by dt asc) as eth_supply
         , sum(b.amount) over(order by dt asc) as btc_supply
         , sum(u.amount) over(order by dt asc) as usd_supply
    from tacETH_supply e
    left join tacBTC_supply b using(dt)
    left join tacUSD_supply u using(dt)
)


select dt
     , s.eth_supply as eth_supply
     , s.eth_supply * e.price as eth_tvl
     , s.btc_supply as btc_supply
     , s.btc_supply * b.price as btc_tvl
     , s.usd_supply
     , s.usd_supply as usd_tvl
     , (s.eth_supply * e.price) + (s.btc_supply * b.price) + s.usd_supply as total_tvl
from supply_summary s
left join eth_price e using(dt)
left join btc_price b using(dt)
order by dt desc
;
