with eth_price as (
    select date_trunc('day', minute) as dt
         , avg(price) as price
    from prices.usd
    where symbol = 'ETH'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-06-26'
),

btc_price as (
    select date_trunc('day', minute) as dt
         , avg(price) as price
    from prices.usd
    where symbol = 'BTC'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-06-26'
),

tETH_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xa1150cd4A014e06F5E0A6ec9453fE0208dA5adAb -- tETH CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xa1150cd4A014e06F5E0A6ec9453fE0208dA5adAb
         and to = 0x0000000000000000000000000000000000000000
        ) as raw
    group by 1
    having date_trunc('day', evt_block_time) >= date '2025-03-25'
),

tBTC_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x6b6b870C7f449266a9F40F94eCa5A6fF9b0857E4 -- tBTC CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x6b6b870C7f449266a9F40F94eCa5A6fF9b0857E4
         and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
    having date_trunc('day', evt_block_time) >= date '2025-03-25'
),

tUSDe_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xA01227A26A7710bc75071286539E47AdB6DEa417 -- tUSDe CA
         and "from" = 0x0000000000000000000000000000000000000000
        
         union all 
        
         select evt_block_time
              , -cast(value as double)/1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xA01227A26A7710bc75071286539E47AdB6DEa417
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
    from tETH_supply e
    left join tBTC_supply b using(dt)
    left join tUSDe_supply u using(dt)
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
where dt >= date '2025-06-26'
order by dt desc
;
