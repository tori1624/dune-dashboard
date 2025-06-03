with eth_vault as (
    select
        addr,
        'hypeETH' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x9E3C0D2D70e9A4BF4f9d5F0A6E4930ce76Fed09e
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x9E3C0D2D70e9A4BF4f9d5F0A6E4930ce76Fed09e
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
), 
btc_vault as (
    select
        addr,
        'hypeBTC' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x9920d2075A350ACAaa4c6D00A56ebBEeD021cD7f
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x9920d2075A350ACAaa4c6D00A56ebBEeD021cD7f
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
),
usdt_vault as (
    select
        addr,
        'hypeUSD' as vault_type,
        sum(amount) as deposited
    from 
        (select 
            "to" as addr, 
            value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x340116F605Ca4264B8bC75aAE1b3C8E42AE3a3AB
        UNION ALL 
        select 
            "from" as addr, 
            -value / 1e6 as amount
        from erc20_ethereum.evt_transfer
        where contract_address = 0x340116F605Ca4264B8bC75aAE1b3C8E42AE3a3AB
        )
    where addr <> 0x0000000000000000000000000000000000000000
    group by 1, 2
    having sum(amount) > 0
),
total_addr as (
    select distinct addr 
    from (select addr from eth_vault 
          union all
          select addr from btc_vault
          union all
          select addr from usdt_vault
    )
)

select
    count(*) as total_addr
from total_addr
