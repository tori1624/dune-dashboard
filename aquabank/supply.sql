with busdt_supply as (
    select 
        date_trunc('day', evt_block_time) as dt,
        sum(amount) as amount
    from 
        (select 
             evt_block_time,
             cast(value as double)/1e6 as amount
        from erc20_avalanche_c.evt_transfer
        where contract_address = 0x3C594084dC7AB1864AC69DFd01AB77E8f65B83B7 -- bUSDT CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select 
            evt_block_time,
            -cast(value as double)/1e6 as amount
        from erc20_avalanche_c.evt_transfer
        where contract_address = 0x3C594084dC7AB1864AC69DFd01AB77E8f65B83B7
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),

summary as (
    select 
        dt, 
        sum(amount) over(order by dt asc) as busdt_supply
    from busdt_supply
)


select 
    dt, 
    busdt_supply,
    busdt_supply / 1e3 as busdt_k
from summary
where dt >= date '2025-08-27'
order by dt desc;
