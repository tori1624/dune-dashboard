with base as (
    select
        date_trunc('day', evt_block_time) as dt,
        case
            when "from" = 0x0000000000000000000000000000000000000000 then cast(value as double)/1e18
            when "to"   = 0x0000000000000000000000000000000000000000 then -cast(value as double)/1e18
        end as amount,
        case when "from" = 0x0000000000000000000000000000000000000000 then cast(value as double)/1e18 else 0 end as minted,
        case when "to"   = 0x0000000000000000000000000000000000000000 then cast(value as double)/1e18 else 0 end as burned
    from erc20_ethereum.evt_transfer
    where contract_address = 0xfa2b947eec368f42195f24f36d2af29f7c24cec2
      and ( "from" = 0x0000000000000000000000000000000000000000
            or "to" = 0x0000000000000000000000000000000000000000 )
),

net_daily as (
    select
        cast(dt as date) as d,
        sum(amount) as net_flow,
        sum(minted) as mint_amount,
        sum(burned) as burn_amount
    from base
    group by 1
),

bounds as (
    select min(d) as start_d, max(d) as end_d from net_daily
),

calendar as (
    select cast(d as date) as d
    from bounds b
    cross join unnest(sequence(b.start_d, b.end_d, interval '1' day)) as t(d)
),

series as (
    select
        c.d as dt,
        coalesce(n.net_flow, 0) as net_flow,
        coalesce(n.mint_amount, 0) as mint_amount,
        coalesce(n.burn_amount, 0) as burn_amount
    from calendar c
    left join net_daily n on n.d = c.d
)


select
    dt,
    net_flow,
    mint_amount,
    burn_amount,
    sum(net_flow) over (order by dt) as cum_supply
from series
order by dt;
