with vaults as (
    select * from (values
        ('nmorpho_usd', 0xF66EF32fdFf3AD46f3565CC2B36eba60feDd6F3A, 1e6),
        ('bnmorpho_usd', 0xeb06c09D675812570C5cD32c3f08c3A8064af232, 1e6),
        ('nmorpho_eth', 0xE768B9Ec3d8303CDE9eeb688faAa7bbd5297c58e, 1e18),
        ('bnmorpho_eth', 0xD05D1918953005a3DDCA83cF97d89A7A6387502b, 1e18),
        ('nmorpho_usd_loop', 0x533669842F5262115f8eC887C0ECf5BA15f4d4Fc, 1e6),
        ('bnmorpho_usd_loop', 0xDadbf6733aE3f9D6e5994177dD6bf8ECe9b1c723, 1e6),
        ('nmorpho_eth_loop', 0xdB3d1cA229420dC7e736E504F29dcFe3d5A0358e, 1e18),
        ('bnmorpho_eth_loop', 0xa6D252E24cF9ed84C2045586b3799983F720F958, 1e18),
        ('naave_usd', 0x872d81409619C9faC8A9978f9b2a0C1F1833Ac4a, 1e6),
        ('bnaave_usd', 0x6ab6Cdc757c6ACd29edCbDFf3ec02D3496F024B1, 1e6),
        ('naave_usd_loop', 0x0e5E96f07526Ed56fA73ff08b85388D2501C7c22, 1e6),
        ('bnaave_usd_loop', 0x3C25148848af452dFAf5DA595335a1d01Ba14bFe, 1e6),
        ('naave_eth_loop', 0x45fda213Be5a54605249254Ef729F071F86aa80b, 1e18),
        ('bnaave_eth_loop', 0x918a83FA3Ab344C39B807818BE2CfC83C9B0d6c3, 1e18)
    ) as t(vault_type, contract_address, divisor)
),

eth_price as (
    select price
    from prices.usd_latest
    where blockchain = 'tron'
      and symbol = 'ETH'
),

transfers as (
    select t.vault_type, e."to" as addr, value / t.divisor as amount
    from vaults t
    join erc20_base.evt_transfer e
      on e.contract_address = t.contract_address
    
    union all
    
    select t.vault_type, e."from" as addr, -value / t.divisor as amount
    from vaults t
    join erc20_base.evt_transfer e
      on e.contract_address = t.contract_address
),

cleaned as (
    select *
    from transfers
    where addr <> 0x0000000000000000000000000000000000000000
),

aggregated as (
    select
        addr,
        vault_type,
        sum(amount) as balance
    from cleaned
    group by addr, vault_type
    having sum(amount) > 0
),

amount as (
    select
        addr,
        sum(case when vault_type = 'nmorpho_usd'       then balance else 0 end) as nmorpho_usd,
        sum(case when vault_type = 'bnmorpho_usd'      then balance else 0 end) as bnmorpho_usd,
        sum(case when vault_type = 'nmorpho_eth'       then (balance) * (select price from eth_price) else 0 end) as nmorpho_eth,
        sum(case when vault_type = 'bnmorpho_eth'      then (balance) * (select price from eth_price) else 0 end) as bnmorpho_eth,
        sum(case when vault_type = 'nmorpho_usd_loop'  then balance else 0 end) as nmorpho_usd_loop,
        sum(case when vault_type = 'bnmorpho_usd_loop' then balance else 0 end) as bnmorpho_usd_loop,
        sum(case when vault_type = 'nmorpho_eth_loop'  then (balance) * (select price from eth_price) else 0 end) as nmorpho_eth_loop,
        sum(case when vault_type = 'bnmorpho_eth_loop' then (balance) * (select price from eth_price) else 0 end) as bnmorpho_eth_loop,
        sum(case when vault_type = 'naave_usd'         then balance else 0 end) as naave_usd,
        sum(case when vault_type = 'bnaave_usd'        then balance else 0 end) as bnaave_usd,
        sum(case when vault_type = 'naave_usd_loop'    then balance else 0 end) as naave_usd_loop,
        sum(case when vault_type = 'bnaave_usd_loop'   then balance else 0 end) as bnaave_usd_loop,
        sum(case when vault_type = 'naave_eth_loop'    then (balance) * (select price from eth_price) else 0 end) as naave_eth_loop,
        sum(case when vault_type = 'bnaave_eth_loop'   then (balance) * (select price from eth_price) else 0 end) as bnaave_eth_loop
    from aggregated
    group by addr
),

total_amount as (
    select 
        *,
        coalesce(nmorpho_usd,0) + coalesce(bnmorpho_usd,0) +
        coalesce(nmorpho_eth,0) + coalesce(bnmorpho_eth,0) + 
        coalesce(nmorpho_usd_loop,0) + coalesce(bnmorpho_usd_loop,0) + 
        coalesce(nmorpho_eth_loop,0) + coalesce(bnmorpho_eth_loop,0) + 
        coalesce(naave_usd,0) + coalesce(bnaave_usd,0) + 
        coalesce(naave_usd_loop,0) + coalesce(bnaave_usd_loop,0) + 
        coalesce(naave_eth_loop,0) + coalesce(bnaave_eth_loop,0) as total_amount
    from amount
)


select
    row_number() over(order by total_amount desc) as rank, 
    row_number() over(order by total_amount asc)  as number,
    *
from total_amount
where total_amount > 0.1
and addr not in (select contract_address from vaults)
order by rank asc;
