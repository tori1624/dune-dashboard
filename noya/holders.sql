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
nmorpho_eth as (
    select
        addr,
        'nmorpho_eth' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xe133fb96ba6F4C35280FdD6a7E6381694d8B8347
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xe133fb96ba6F4C35280FdD6a7E6381694d8B8347
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
), 
bnmorpho_eth as (
    select
        addr,
        'bnmorpho_eth' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x168E80D05ee1d63aAcb682e0Def1B02BC4d45de8
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x168E80D05ee1d63aAcb682e0Def1B02BC4d45de8
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
),
nmorpho_usd_loop as (
    select
        addr,
        'nmorpho_usd_loop' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xB1bb9583f5A74CED10e413Cc44245e05843BADEE
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xB1bb9583f5A74CED10e413Cc44245e05843BADEE
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
), 
bnmorpho_usd_loop as (
    select
        addr,
        'bnmorpho_usd_loop' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xA04FCCc48AeB3C0Fbc5c6F8d98dB8f6be3f65979
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0xA04FCCc48AeB3C0Fbc5c6F8d98dB8f6be3f65979
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
),
nmorpho_eth_loop as (
    select
        addr,
        'nmorpho_eth_loop' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x062e9eE0eeBF0EDdfC2Dd79DAd905F3B4C7838cB
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x062e9eE0eeBF0EDdfC2Dd79DAd905F3B4C7838cB
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
), 
bnmorpho_eth_loop as (
    select
        addr,
        'bnmorpho_eth_loop' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x5b08789eD14F37ffA67236088D03692528A96c5c
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_base.evt_transfer
        where contract_address = 0x5b08789eD14F37ffA67236088D03692528A96c5c
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
          union all
          select addr from nmorpho_eth
          union all
          select addr from bnmorpho_eth
          union all
          select addr from nmorpho_usd_loop
          union all
          select addr from bnmorpho_usd_loop
          union all
          select addr from nmorpho_eth_loop
          union all
          select addr from bnmorpho_eth_loop
    )
)

select
    count(*) as total_addr
from total_addr
