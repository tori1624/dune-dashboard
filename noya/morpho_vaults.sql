select *
     , bnmorpho_usd/nmorpho_usd as nu_bonding_ratio
     , bnmorpho_eth/nmorpho_eth as ne_bonding_ratio
     , bnmorpho_usd_loop/nmorpho_usd_loop as nul_bonding_ratio
     , bnmorpho_eth_loop/nmorpho_eth_loop as nel_bonding_ratio
     , nmorpho_usd/1000000 as nu_cap_ratio
     , nmorpho_eth/400 as ne_cap_ratio
     , case
         when (nmorpho_usd_loop/100000) > 1 then 1
         else (nmorpho_usd_loop/100000)
       end as nul_cap_ratio
     , nmorpho_eth_loop/40 as nel_cap_ratio
from query_5346169
order by dt desc
;
