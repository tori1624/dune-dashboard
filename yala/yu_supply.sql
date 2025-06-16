with yu_supply as (
    select date_trunc('day', evt_block_time) as dt
         , sum(amount) as amount
    from 
        (select evt_block_time
              , cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xE868084cf08F3c3db11f4B73a95473762d9463f7 -- YU
        and "from" = 0x0000000000000000000000000000000000000000
        
        union all 
        
        select evt_block_time
             , -cast(value as double)/1e18 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xE868084cf08F3c3db11f4B73a95473762d9463f7
        and to = 0x0000000000000000000000000000000000000000
        ) as raw 
    group by 1
)


select dt
     , sum(amount) over(order by dt asc) as total_supply
from yu_supply
order by dt desc
;
