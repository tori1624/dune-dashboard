with nmorpho_usd as (
    select
        addr,
        'nmorpho_usd' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x8603A9AF9D6812A96dCA4c2C40C5025601DEDcF8
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x8603A9AF9D6812A96dCA4c2C40C5025601DEDcF8
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
), 
bnmorpho_usd as (
    select
        addr,
        'bnmorpho_usd' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xB61E561f62D572197e59880a9F69fc6cb4463115
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xB61E561f62D572197e59880a9F69fc6cb4463115
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
),
total_addr as (
    select distinct addr 
    from (select addr from nmorpho_usd 
          union all
          select addr from bnmorpho_usd
    )
)

select
    count(*) as total_addr
from total_addr
