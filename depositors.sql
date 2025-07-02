with vaults as (
    select * from (values
        (0x8603A9AF9D6812A96dCA4c2C40C5025601DEDcF8, 'nmorpho_usd'),
        (0xB61E561f62D572197e59880a9F69fc6cb4463115, 'bnmorpho_usd'),
        (0xe133fb96ba6F4C35280FdD6a7E6381694d8B8347, 'nmorpho_eth'),
        (0x168E80D05ee1d63aAcb682e0Def1B02BC4d45de8, 'bnmorpho_eth'),
        (0xB1bb9583f5A74CED10e413Cc44245e05843BADEE, 'nmorpho_usd_loop'),
        (0xA04FCCc48AeB3C0Fbc5c6F8d98dB8f6be3f65979, 'bnmorpho_usd_loop'),
        (0x062e9eE0eeBF0EDdfC2Dd79DAd905F3B4C7838cB, 'nmorpho_eth_loop'),
        (0x5b08789eD14F37ffA67236088D03692528A96c5c, 'bnmorpho_eth_loop')
    ) as t(contract_address, vault_type)
),

eth_price as (
    select price
    from prices.usd_latest
    where blockchain = 'tron'
    and symbol = 'ETH'
),

transfers as (
    select 
        t.vault_type,
        case when e."to" is not null then e."to" else e."from" end as addr,
        case when e."to" is not null then value / 1e6 else -value / 1e6 end as amount
    from vaults t
    join erc20_base.evt_transfer e
      on e.contract_address = t.contract_address
    where coalesce(e."to", e."from") <> 0x0000000000000000000000000000000000000000
),

aggregated as (
    select
        addr,
        vault_type,
        sum(amount) as deposited
    from transfers
    group by addr, vault_type
    having sum(amount) > 0
),

amount as (
    select
        addr,
        sum(case when vault_type = 'nmorpho_usd' then deposited else 0 end) as nmorpho_usd,
        sum(case when vault_type = 'nmorpho_eth' then (deposited / 1e12) * (select price from eth_price) else 0 end) as nmorpho_eth,
        sum(case when vault_type = 'nmorpho_usd_loop' then deposited else 0 end) as nmorpho_usd_loop,
        sum(case when vault_type = 'nmorpho_eth_loop' then (deposited / 1e12) * (select price from eth_price) else 0 end) as nmorpho_eth_loop
    from aggregated
    group by addr
),

total_amount as (
    select 
        *,
        nmorpho_usd + nmorpho_eth + nmorpho_usd_loop + nmorpho_eth_loop as total_amount
    from amount
)


select
    row_number() over(order by total_amount desc) as rank, 
    row_number() over(order by total_amount asc) as number,
    *
from total_amount
where total_amount > 0
order by 1 asc
;
