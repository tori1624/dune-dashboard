with btc as (
    select day
         , amount as balance
         , amount_usd
    from balances_bitcoin.satoshi_day
    where wallet_address = 'bc1pdwu79dady576y3fupmm82m3g7p2p9f6hgyeqy0tdg7ztxg7xrayqlkl8j9'
),
eth as (
    select date_trunc('day', block_time) as day
         , max(balance) as balance
    from tokens_ethereum.balances
    where 1=1
    and address = 0xBEa9f7FD27f4EE20066F18DEF0bc586eC221055A
    and token_standard = 'native'
    group by 1
),
sol as (
    select day
         , sol_balance as balance
    from solana_utils.daily_balances
    where 1=1
    and address = '9SLPTL41SPsYkgdsMzdfJsxymEANKr5bYoBsQzJyKpKS'
),
summary as (
    select day
         , sum(b.balance) over(order by day asc) as btc_deposit
         , sum(e.balance) over(order by day asc) as eth_deposit
         , sum(s.balance) over(order by day asc) as sol_depoist
    from btc b
    left join eth e using(day)
    left join sol s using(day)
)

select *
from summary
