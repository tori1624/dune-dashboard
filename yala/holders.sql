with yu as (
    select address
         , 'YU' as coin_type
         , sum(amount) as amount
    from 
        (select "to" as address
              , value / 1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xE868084cf08F3c3db11f4B73a95473762d9463f7
        
         union all 
        
         select "from" as address
              , -value / 1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xE868084cf08F3c3db11f4B73a95473762d9463f7
        )
    where address <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
), 
ybtc as (
    select address
         , 'YBTC' as coin_type
         , sum(amount) as amount
    from 
        (select "to" as address
              , value / 1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x27A70B9F8073efE5A02998D5Cc64aCdc9e0Ba589
        
         union all 
        
         select "from" as address
              , -value / 1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x27A70B9F8073efE5A02998D5Cc64aCdc9e0Ba589
        )
    where address <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
)


select 'YU' as coin_type
     , count(distinct address) as address_count
from yu

union all

select 'YBTC' as coin_type
     , count(distinct address) as address_count
from ybtc

order by coin_type
;
