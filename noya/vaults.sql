with nmorpho_usd as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x8603A9AF9D6812A96dCA4c2C40C5025601DEDcF8 -- NOYA morpho USD CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e6 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x8603A9AF9D6812A96dCA4c2C40C5025601DEDcF8
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
bnmorpho_usd as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xB61E561f62D572197e59880a9F69fc6cb4463115 -- Bonding NOYA morpho USD CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e6 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0xB61E561f62D572197e59880a9F69fc6cb4463115
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
summary as (
    select dt
         , sum(n.amount) over(order by dt asc) as nmorpho_usd
         , sum(b.amount) over(order by dt asc) as bnmorpho_usd
    from nmorpho_usd n
    left join bnmorpho_usd b using(dt)
)

  
select dt
     , nmorpho_usd
     , bnmorpho_usd
     , bnmorpho_usd/nmorpho_usd as bonding_ratio
from summary
order by dt desc
;
