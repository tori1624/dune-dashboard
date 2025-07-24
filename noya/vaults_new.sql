with eth_price as (
    select
        date_trunc('day', minute) as dt,
        avg(price) as price
    from prices.usd
    where symbol = 'ETH'
      and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-07-21'
)

select
    *,
    nmorpho_eth * e.price as nme_tvl,
    nmorpho_eth_loop * e.price as nmel_tvl,
    naave_eth_loop * e.price as nael_tvl,
    nmorpho_usd
      + nmorpho_usd_loop
      + (nmorpho_eth * e.price)
      + (nmorpho_eth_loop * e.price)
      + naave_usd
      + naave_usd_loop
      + (naave_eth_loop * e.price) as total_tvl
from query_5528490
left join eth_price e using (dt)
order by dt desc;
