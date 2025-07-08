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

first_seen as (
    select
        e."to" as addr,
        min(date_trunc('day', e.evt_block_time)) as first_seen_date
    from erc20_base.evt_transfer e
    join vaults v on e.contract_address = v.contract_address
    where e."to" is not null
      and e."to" <> 0x0000000000000000000000000000000000000000
    group by e."to"
),

daily_users as (
    select
        date_trunc('day', e.evt_block_time) as dt,
        e."to" as addr
    from erc20_base.evt_transfer e
    join vaults v on e.contract_address = v.contract_address
    where e."to" is not null
      and e."to" <> 0x0000000000000000000000000000000000000000
),

labeled_users as (
    select
        d.dt,
        d.addr,
        case
            when f.first_seen_date = d.dt then 'new'
            else 'existing'
        end as user_type
    from daily_users d
    join first_seen f on d.addr = f.addr
),

daily_summary as (
    select
        dt,
        count(distinct case when user_type = 'new' then addr end) as new_users,
        count(distinct case when user_type = 'existing' then addr end) as existing_users,
        count(distinct addr) as total_users
    from labeled_users
    group by dt
)


select
    *,
    sum(new_users) over (order by dt) as cumulative_new_users
from daily_summary
order by dt;
