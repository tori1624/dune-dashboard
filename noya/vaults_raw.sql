with vaults as (
    select * from (values
        ('nmorpho_usd',        0x8603A9AF9D6812A96dCA4c2C40C5025601DEDcF8, 1e6),
        ('bnmorpho_usd',       0xB61E561f62D572197e59880a9F69fc6cb4463115, 1e6),
        ('nmorpho_eth',        0xe133fb96ba6F4C35280FdD6a7E6381694d8B8347, 1e18),
        ('bnmorpho_eth',       0x168E80D05ee1d63aAcb682e0Def1B02BC4d45de8, 1e18),
        ('nmorpho_usd_loop',   0xB1bb9583f5A74CED10e413Cc44245e05843BADEE, 1e6),
        ('bnmorpho_usd_loop',  0xA04FCCc48AeB3C0Fbc5c6F8d98dB8f6be3f65979, 1e6),
        ('nmorpho_eth_loop',   0x062e9eE0eeBF0EDdfC2Dd79DAd905F3B4C7838cB, 1e18),
        ('bnmorpho_eth_loop',  0x5b08789eD14F37ffA67236088D03692528A96c5c, 1e18)
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
    max(case when vault_type = 'bnmorpho_usd' then cum_amount end) as bnmorpho_usd,
    max(case when vault_type = 'nmorpho_eth' then cum_amount end) as nmorpho_eth,
    max(case when vault_type = 'bnmorpho_eth' then cum_amount end) as bnmorpho_eth,
    max(case when vault_type = 'nmorpho_usd_loop' then cum_amount end) as nmorpho_usd_loop,
    max(case when vault_type = 'bnmorpho_usd_loop' then cum_amount end) as bnmorpho_usd_loop,
    max(case when vault_type = 'nmorpho_eth_loop' then cum_amount end) as nmorpho_eth_loop,
    max(case when vault_type = 'bnmorpho_eth_loop' then cum_amount end) as bnmorpho_eth_loop
from cumulative
group by dt
order by dt
;
