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
nmorpho_eth as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xe133fb96ba6F4C35280FdD6a7E6381694d8B8347 -- NOYA Morpho ETH CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0xe133fb96ba6F4C35280FdD6a7E6381694d8B8347
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
bnmorpho_eth as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x168E80D05ee1d63aAcb682e0Def1B02BC4d45de8 -- Bonding NOYA Morpho ETH CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x168E80D05ee1d63aAcb682e0Def1B02BC4d45de8
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
nmorpho_usd_loop as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xB1bb9583f5A74CED10e413Cc44245e05843BADEE -- NOYA Morpho USD Looping CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e6 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0xB1bb9583f5A74CED10e413Cc44245e05843BADEE
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
bnmorpho_usd_loop as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xA04FCCc48AeB3C0Fbc5c6F8d98dB8f6be3f65979 -- Bonding NOYA Morpho USD Looping CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e6 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0xA04FCCc48AeB3C0Fbc5c6F8d98dB8f6be3f65979
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
nmorpho_eth_loop as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x062e9eE0eeBF0EDdfC2Dd79DAd905F3B4C7838cB -- NOYA Morpho ETH Looping CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x062e9eE0eeBF0EDdfC2Dd79DAd905F3B4C7838cB
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
bnmorpho_eth_loop as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x5b08789eD14F37ffA67236088D03692528A96c5c -- Bonding NOYA Morpho ETH Looping CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x5b08789eD14F37ffA67236088D03692528A96c5c
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
)


select dt
     , sum(nu.amount) over(order by dt asc) as nmorpho_usd
     , sum(bu.amount) over(order by dt asc) as bnmorpho_usd
     , sum(ne.amount) over(order by dt asc) as nmorpho_eth
     , sum(be.amount) over(order by dt asc) as bnmorpho_eth
     , sum(nul.amount) over(order by dt asc) as nmorpho_usd_loop
     , sum(bul.amount) over(order by dt asc) as bnmorpho_usd_loop
     , sum(nel.amount) over(order by dt asc) as nmorpho_eth_loop
     , sum(bel.amount) over(order by dt asc) as bnmorpho_eth_loop
from nmorpho_usd nu
left join bnmorpho_usd bu using(dt)
left join nmorpho_eth ne using(dt)
left join bnmorpho_eth be using(dt)
left join nmorpho_usd_loop nul using(dt)
left join bnmorpho_usd_loop bul using(dt)
left join nmorpho_eth_loop nel using(dt)
left join bnmorpho_eth_loop bel using(dt)
;
