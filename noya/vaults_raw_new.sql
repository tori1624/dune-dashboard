with vaults as (
    select * from (values
        ('nmorpho_usd', 0xF66EF32fdFf3AD46f3565CC2B36eba60feDd6F3A, 1e6),
        ('nmorpho_eth', 0xE768B9Ec3d8303CDE9eeb688faAa7bbd5297c58e, 1e18),
        ('nmorpho_usd_loop', 0x533669842F5262115f8eC887C0ECf5BA15f4d4Fc, 1e6),
        ('nmorpho_eth_loop', 0xdB3d1cA229420dC7e736E504F29dcFe3d5A0358e, 1e18),
        ('naave_usd', 0x872d81409619C9faC8A9978f9b2a0C1F1833Ac4a, 1e6),
        ('naave_usd_loop', 0x0e5E96f07526Ed56fA73ff08b85388D2501C7c22, 1e6),
        ('naave_eth_loop', 0x45fda213Be5a54605249254Ef729F071F86aa80b, 1e18)
    ) as t(vault_type, contract_address, divisor)
),

raw_transfers as (
    select
        date_trunc('day', evt_block_time) as dt,
        v.vault_type,
        case
            when e."from" = 0x0000000000000000000000000000000000000000 then cast(e.value as double) / v.divisor
            when e."to"   = 0x0000000000000000000000000000000000000000 then -cast(e.value as double) / v.divisor
            else 0
        end as amount
    from erc20_base.evt_transfer e
    join vaults v on e.contract_address = v.contract_address
    where
        (e."from" = 0x0000000000000000000000000000000000000000 or e."to" = 0x0000000000000000000000000000000000000000)
),

daily_amounts as (
    select
        dt,
        vault_type,
        sum(amount) as daily_amount
    from raw_transfers
    group by dt, vault_type
),

all_dates as (
    select distinct dt from daily_amounts
),

all_combinations as (
    select dt, vault_type
    from all_dates, vaults
),

filled_data as (
    select
        c.dt,
        c.vault_type,
        coalesce(d.daily_amount, 0) as daily_amount
    from all_combinations c
    left join daily_amounts d
        on c.dt = d.dt and c.vault_type = d.vault_type
),

cumulative as (
    select
        dt,
        vault_type,
        sum(daily_amount) over (partition by vault_type order by dt) as cum_amount
    from filled_data
)


select
    dt,
    max(case when vault_type = 'nmorpho_usd' then cum_amount end) as nmorpho_usd,
    max(case when vault_type = 'nmorpho_eth' then cum_amount end) as nmorpho_eth,
    max(case when vault_type = 'nmorpho_usd_loop' then cum_amount end) as nmorpho_usd_loop,
    max(case when vault_type = 'nmorpho_eth_loop' then cum_amount end) as nmorpho_eth_loop,
    max(case when vault_type = 'naave_usd' then cum_amount end) as naave_usd,
    max(case when vault_type = 'naave_usd_loop' then cum_amount end) as naave_usd_loop,
    max(case when vault_type = 'naave_eth_loop' then cum_amount end) as naave_eth_loop
from cumulative
group by dt
order by dt
;
