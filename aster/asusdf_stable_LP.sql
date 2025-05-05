with addLP_hash_df as (
    select hash
    from bnb.transactions
    where substring(data from 1 for 4) = 0x0b4c7e4d -- add liquidity
    and to = 0xd791Be03A4E0E4B9be62adAc8a5Cd4aE2813A2d6 -- asUSDF/USDF
),
rmvLP_hash_df as (
    select hash
    from bnb.transactions
    where substring(data from 1 for 4) = 0x5b36389c -- remove liquidity
    and to = 0xd791Be03A4E0E4B9be62adAc8a5Cd4aE2813A2d6
),
addLP_hash_dt as (
    select hash
    from bnb.transactions
    where substring(data from 1 for 4) = 0x0b4c7e4d 
    and to = 0x85259443fad3dc9EcfaFE62f043A020992f0E4FC -- asUSDF/USDT
),
rmvLP_hash_dt as (
    select hash
    from bnb.transactions
    where substring(data from 1 for 4) = 0x5b36389c
    and to = 0x85259443fad3dc9EcfaFE62f043A020992f0E4FC
),
lp_supply_df as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x917AF46B3C3c6e1Bb7286B9F59637Fb7C65851Fb
        and evt_tx_hash in (select hash from addLP_hash_df)
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x917AF46B3C3c6e1Bb7286B9F59637Fb7C65851Fb
        and evt_tx_hash in (select hash from rmvLP_hash_df)
        ) as raw 
    group by 1
),
lp_supply_dt as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x917AF46B3C3c6e1Bb7286B9F59637Fb7C65851Fb
        and evt_tx_hash in (select hash from addLP_hash_dt)
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x917AF46B3C3c6e1Bb7286B9F59637Fb7C65851Fb
        and evt_tx_hash in (select hash from rmvLP_hash_dt)
        ) as raw 
    group by 1
),
pendle as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x9E515a7115C86d7314159DbdAb41E555d5330Dfe -- sy-asusdf CA
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_bnb.evt_transfer
        where contract_address = 0x9E515a7115C86d7314159DbdAb41E555d5330Dfe
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
),
summary as (
    select dt
         , sum(d.amount) over(order by dt asc) as asUSDF_USDT
         , sum(f.amount) over(order by dt asc) as asUSDF_USDF
         , sum(p.amount) over(order by dt asc) as Pendle
    from lp_supply_dt d
    left join lp_supply_df f using(dt)
    left join pendle p using(dt)
)


select *
     , asUSDF_USDT + asUSDF_USDF + Pendle as total_liquidity
from summary
order by dt desc
;
