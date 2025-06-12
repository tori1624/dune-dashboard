with eth_price as (
    select date_trunc('day', minute) as day
         , avg(price) as price
    from prices.usd
    where symbol = 'ETH'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-03-25'
),
sol_price as (
    select date_trunc('day', minute) as day
         , avg(price) as price
    from prices.usd
    where symbol = 'SOL'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-05-10'
), 
btc as (
    select day
         , amount
         , amount_usd
    from balances_bitcoin.satoshi_day
    where wallet_address = 'bc1pdwu79dady576y3fupmm82m3g7p2p9f6hgyeqy0tdg7ztxg7xrayqlkl8j9'
),
eth as (
    select date_trunc('day', block_time) as day
         , max(balance) as amount
    from tokens_ethereum.balances
    where 1=1
    and address = 0xBEa9f7FD27f4EE20066F18DEF0bc586eC221055A
    and token_standard = 'native'
    group by 1
),
sol as (
    select day
         , sol_balance as amount
    from solana_utils.daily_balances
    where 1=1
    and address = '9SLPTL41SPsYkgdsMzdfJsxymEANKr5bYoBsQzJyKpKS'
)

select day
     , b.amount as btc_amount
     , b.amount_usd as btc_tvl
     , e.amount as eth_amount
     , e.amount * ep.price as eth_tvl
     , s.amount as sol_amount
     , s.amount * sp.price as sol_tvl
     , b.amount_usd + (e.amount * ep.price) + (s.amount * sp.price) as total_tvl
from btc b
left join eth e using(day)
left join sol s using(day)
left join eth_price ep using(day)
left join sol_price sp using(day)
order by day desc
;
