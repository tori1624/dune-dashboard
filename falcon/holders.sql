with usdf as (
    select 
        address, 
        'USDf' as coin_type, 
        sum(amount) as amount
    from 
        (select 
             "to" as address, 
             value / 1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xFa2B947eEc368f42195f24F36d2aF29f7c24CeC2
        
         union all 
        
         select 
             "from" as address, 
             -value / 1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xFa2B947eEc368f42195f24F36d2aF29f7c24CeC2
        )
    where address <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
), 

susdf as (
    select 
        address, 
        'sUSDf' as coin_type, 
        sum(amount) as amount
    from 
        (select 
             "to" as address, 
             value / 1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xc8CF6D7991f15525488b2A83Df53468D682Ba4B0
        
         union all 
        
         select 
             "from" as address, 
             -value / 1e6 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0xc8CF6D7991f15525488b2A83Df53468D682Ba4B0
        )
    where address <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
)


select 
    'USDf' as coin_type, 
    count(distinct address) as address_count
from usdf

union all

select 
    'sUSDf' as coin_type, 
    count(distinct address) as address_count
from susdf

order by coin_type;
