with tETH as (
    select
        addr,
        'tETH' as type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xa1150cd4A014e06F5E0A6ec9453fE0208dA5adAb
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xa1150cd4A014e06F5E0A6ec9453fE0208dA5adAb
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
),

tBTC as (
    select
        addr,
        'tBTC' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x6b6b870C7f449266a9F40F94eCa5A6fF9b0857E4
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x6b6b870C7f449266a9F40F94eCa5A6fF9b0857E4
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
),

tUSDe as (
    select
        addr,
        'tUSDe' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xA01227A26A7710bc75071286539E47AdB6DEa417
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0xA01227A26A7710bc75071286539E47AdB6DEa417
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
),

total_addr as (
    select distinct addr 
    from (select addr from tETH 
          union all
          select addr from tBTC
          union all
          select addr from tUSDe
    )
)


select
    count(*) as total_addr
from total_addr
