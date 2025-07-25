with vaults as (
    select * from (values
        (0xF66EF32fdFf3AD46f3565CC2B36eba60feDd6F3A, 'nmorpho_usd'),
        (0xE768B9Ec3d8303CDE9eeb688faAa7bbd5297c58e, 'nmorpho_eth'),
        (0x533669842F5262115f8eC887C0ECf5BA15f4d4Fc, 'nmorpho_usd_loop'),
        (0xdB3d1cA229420dC7e736E504F29dcFe3d5A0358e, 'nmorpho_eth_loop'),
        (0x872d81409619C9faC8A9978f9b2a0C1F1833Ac4a, 'naave_usd'),
        (0x0e5E96f07526Ed56fA73ff08b85388D2501C7c22, 'naave_usd_loop'),
        (0x45fda213Be5a54605249254Ef729F071F86aa80b, 'naave_eth_loop')
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
        sum(case when vault_type = 'nmorpho_eth_loop' then (deposited / 1e12) * (select price from eth_price) else 0 end) as nmorpho_eth_loop,
        sum(case when vault_type = 'naave_usd' then deposited else 0 end) as naave_usd,
        sum(case when vault_type = 'naave_usd_loop' then deposited else 0 end) as naave_usd_loop,
        sum(case when vault_type = 'naave_eth_loop' then (deposited / 1e12) * (select price from eth_price) else 0 end) as naave_eth_loop
    from aggregated
    group by addr
),

total_amount as (
    select 
        *,
        nmorpho_usd 
          + nmorpho_eth 
          + nmorpho_usd_loop 
          + nmorpho_eth_loop 
          + naave_usd
          + naave_usd_loop
          + naave_eth_loop as total_amount
    from amount
)


select
    row_number() over(order by total_amount desc) as rank, 
    row_number() over(order by total_amount asc) as number,
    *
from total_amount
where total_amount > 0.01
and addr != 0x5c9898196aea4fbd6756227b88d9b4c518df9eb5
order by 1 asc
;
