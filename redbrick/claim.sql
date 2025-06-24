select *
     , value/1e18 as claimed
from erc20_bnb.evt_transfer
where contract_address = 0xb40f2e5291c3Db45AbB0Ca8DF76F1C21E9f112a9
and "from" = 0x4eE7Caa87791107c89Fd700bEE5E538344ae32DD2
order by evt_block_time desc
limit 10
;
