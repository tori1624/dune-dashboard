with usdf_supply as (
    select 
        date_trunc('day', evt_block_time) as dt,
        sum(amount) as amount
    from 
        (select 
             evt_block_time,
             cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xFa2B947eEc368f42195f24F36d2aF29f7c24CeC2 -- USDf CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select 
            evt_block_time,
            -cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xFa2B947eEc368f42195f24F36d2aF29f7c24CeC2
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),

susdf_supply as (
    select 
        date_trunc('day', evt_block_time) as dt,
        sum(amount) as amount
    from 
        (select 
             evt_block_time,
             cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xc8CF6D7991f15525488b2A83Df53468D682Ba4B0 -- sUSDf CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select 
            evt_block_time,
            -cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xc8CF6D7991f15525488b2A83Df53468D682Ba4B0
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),

summary as (
    select 
        dt, 
        sum(u.amount) over(order by dt asc) as usdf_supply, 
        sum(a.amount) over(order by dt asc) as susdf_supply
    from usdf_supply u
    left join susdf_supply a using(dt)
)

select 
    dt, 
    usdf_supply,
    usdf_supply - susdf_supply as nonstaked_usdf,
    susdf_supply, 
    (susdf_supply / usdf_supply) * 100 as staked_ratio
from summary
order by dt desc;
