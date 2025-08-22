with cusd as (
    select 
        address, 
        'cUSD' as coin_type, 
        sum(amount) as amount
    from 
        (select 
             "to" as address, 
             value / 1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address =  0xcCcc62962d17b8914c62D74FfB843d73B2a3cccC
        
         union all 
        
         select 
             "from" as address, 
             -value / 1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address =  0xcCcc62962d17b8914c62D74FfB843d73B2a3cccC
        )
    where address <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
), 

stcusd as (
    select 
        address, 
        'stcUSD' as coin_type, 
        sum(amount) as amount
    from 
        (select 
             "to" as address, 
             value / 1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x88887bE419578051FF9F4eb6C858A951921D8888
        
         union all 
        
         select 
             "from" as address, 
             -value / 1e18 as amount
         from erc20_ethereum.evt_transfer
         where contract_address = 0x88887bE419578051FF9F4eb6C858A951921D8888
        )
    where address <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
)


select 
    'cUSD' as coin_type, 
    count(distinct address) as address_count
from cusd

union all

select 
    'stcUSD' as coin_type, 
    count(distinct address) as address_count
from stcusd

order by coin_type;
