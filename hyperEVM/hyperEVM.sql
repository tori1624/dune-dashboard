with eth_price as (
    select date_trunc('day', minute) as dt
         , avg(price) as price
    from prices.usd
    where symbol = 'ETH'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-03-25'
),
btc_price as (
    select date_trunc('day', minute) as dt
         , avg(price) as price
    from prices.usd
    where symbol = 'BTC'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-03-25'
),
hypeETH_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x9E3C0D2D70e9A4BF4f9d5F0A6E4930ce76Fed09e -- hypeETH CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x9E3C0D2D70e9A4BF4f9d5F0A6E4930ce76Fed09e
         and to = 0x0000000000000000000000000000000000000000
        ) as raw
    group by 1
    having date_trunc('day', evt_block_time) >= date '2025-03-25'
),
hypeBTC_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e8 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x9920d2075A350ACAaa4c6D00A56ebBEeD021cD7f -- hypeBTC CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e8 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x9920d2075A350ACAaa4c6D00A56ebBEeD021cD7f
         and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
    having date_trunc('day', evt_block_time) >= date '2025-03-25'
),
hypeUSD_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x340116F605Ca4264B8bC75aAE1b3C8E42AE3a3AB -- hypeUSD CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x340116F605Ca4264B8bC75aAE1b3C8E42AE3a3AB
         and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
    having date_trunc('day', evt_block_time) >= date '2025-03-25'
), 
supply_summary as (
    select dt
         , sum(e.amount) over(order by dt asc) as eth_supply
         , sum(b.amount) over(order by dt asc) as btc_supply
         , sum(u.amount) over(order by dt asc) as usd_supply
    from hypeETH_supply e
    left join hypeBTC_supply b using(dt)
    left join hypeUSD_supply u using(dt)
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
