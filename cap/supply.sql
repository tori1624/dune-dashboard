with cusd_supply as (
    select 
        date_trunc('day', evt_block_time) as dt,
        sum(amount) as amount
    from 
        (select 
             evt_block_time,
             cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xcCcc62962d17b8914c62D74FfB843d73B2a3cccC -- cUSD CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select 
            evt_block_time,
            -cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xcCcc62962d17b8914c62D74FfB843d73B2a3cccC
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),

stcusd_supply as (
    select 
        date_trunc('day', evt_block_time) as dt,
        sum(amount) as amount
    from 
        (select 
             evt_block_time,
             cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x88887bE419578051FF9F4eb6C858A951921D8888 -- stcUSD CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select 
            evt_block_time,
            -cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x88887bE419578051FF9F4eb6C858A951921D8888
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),

summary as (
    select 
        dt, 
        sum(u.amount) over(order by dt asc) as cusd_supply, 
        sum(a.amount) over(order by dt asc) as stcusd_supply
    from cusd_supply u
    left join stcusd_supply a using(dt)
)


select 
    dt, 
    cusd_supply,
    cusd_supply / 1e6 as cusd_m,
    stcusd_supply,
    stcusd_supply / 1e6 as stcusd_m
from summary
where dt >= date '2025-08-18'
order by dt desc;
