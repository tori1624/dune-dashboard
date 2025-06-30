with eth_price as (
    select date_trunc('day', minute) as dt
         , avg(price) as price
    from prices.usd
    where symbol = 'ETH'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-06-05'
)

select *
     , (bnmorpho_usd/nmorpho_usd)*100 as nu_bonding_ratio
     , (bnmorpho_eth/nmorpho_eth)*100 as ne_bonding_ratio
     , (bnmorpho_usd_loop/nmorpho_usd_loop)*100 as nul_bonding_ratio
     , (bnmorpho_eth_loop/nmorpho_eth_loop)*100 as nel_bonding_ratio
     , (nmorpho_usd/1000000)*100 as nu_cap_ratio
     , (nmorpho_eth/400)*100 as ne_cap_ratio
     , case
         when (nmorpho_usd_loop/100000) > 1 then 100
         else (nmorpho_usd_loop/100000)*100
       end as nul_cap_ratio
     , (nmorpho_eth_loop/40)*100 as nel_cap_ratio
     , nmorpho_eth*e.price as ne_tvl
     , nmorpho_eth_loop*e.price as nel_tvl
     , nmorpho_usd+nmorpho_usd_loop+(nmorpho_eth*e.price)+(nmorpho_eth_loop*e.price) as total_tvl
from query_5346169
left join eth_price e using(dt)
order by dt desc
;
