with eth_price as (
    select date_trunc('day', minute) as day
         , avg(price) as price
    from prices.usd
    where symbol = 'ETH'
    and contract_address is null
    group by 1
    having date_trunc('day', minute) >= date '2025-03-25'
),

solana_prices as (
    select day
         , symbol
         , price
    from prices.usd_daily
    where blockchain = 'solana'
    and symbol in ('SOL', 'FARTCOIN', 'PUMP', 'BONK', 'SPX')
    and day >= date '2025-05-10'
), 

solana_balances as (
    select day
         , case 
             when address = '9SLPTL41SPsYkgdsMzdfJsxymEANKr5bYoBsQzJyKpKS' then 'SOL'
             when address = 'ErJLDKQy1Jna9m1LpbLJEXGiEc6yDFxkBu1mXAEZea5o' then 'FARTCOIN'
             when address = '2REsgfTk2axj41wKXnXWmmwUga28V5o7U9rRBhxCfogq' then 'PUMP'
             when address = '4E6MzXJtafLJxHLGE379ZqaYYZnywEGcK3NadXoGAgXd' then 'BONK'
             when address = '8iAyyLJ4EA8WCTxXhV6XwXfTQeKaZuWDRyrCtMgQTTuz' then 'SPX'
           end as token_symbol
         , case 
             when address = '9SLPTL41SPsYkgdsMzdfJsxymEANKr5bYoBsQzJyKpKS' then sol_balance
             else token_balance
           end as amount
    from solana_utils.daily_balances
    where address in (
        '9SLPTL41SPsYkgdsMzdfJsxymEANKr5bYoBsQzJyKpKS',  -- SOL
        'ErJLDKQy1Jna9m1LpbLJEXGiEc6yDFxkBu1mXAEZea5o',  -- FART
        '2REsgfTk2axj41wKXnXWmmwUga28V5o7U9rRBhxCfogq',  -- PUMP
        '4E6MzXJtafLJxHLGE379ZqaYYZnywEGcK3NadXoGAgXd',  -- BONK
        '8iAyyLJ4EA8WCTxXhV6XwXfTQeKaZuWDRyrCtMgQTTuz'   -- SPX
    )
),

solana_tvl as (
    select b.day
         , b.token_symbol
         , b.amount
         , b.amount * p.price as tvl_usd
    from solana_balances b
    left join solana_prices p on b.day = p.day and b.token_symbol = p.symbol
),

solana_summary as (
    select day
         , sum(case when token_symbol = 'SOL' then amount end) as sol_amount
         , sum(case when token_symbol = 'SOL' then tvl_usd end) as sol_tvl
         , sum(case when token_symbol = 'FARTCOIN' then amount end) as fart_amount
         , sum(case when token_symbol = 'FARTCOIN' then tvl_usd end) as fart_tvl
         , sum(case when token_symbol = 'PUMP' then amount end) as pump_amount
         , sum(case when token_symbol = 'PUMP' then tvl_usd end) as pump_tvl
         , sum(case when token_symbol = 'BONK' then amount end) as bonk_amount
         , sum(case when token_symbol = 'BONK' then tvl_usd end) as bonk_tvl
         , sum(case when token_symbol = 'SPX' then amount end) as spx_amount
         , sum(case when token_symbol = 'SPX' then tvl_usd end) as spx_tvl
         , sum(tvl_usd) as total_solana_tvl
    from solana_tvl
    group by day
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
    where address = 0xBEa9f7FD27f4EE20066F18DEF0bc586eC221055A
    and token_standard = 'native'
    group by 1
)

select day
     , b.amount as btc_amount
     , b.amount_usd as btc_tvl
     , e.amount as eth_amount
     , e.amount * ep.price as eth_tvl
     , ss.sol_amount
     , ss.sol_tvl
     , ss.fart_amount
     , ss.fart_tvl
     , ss.pump_amount
     , ss.pump_tvl
     , ss.bonk_amount
     , ss.bonk_tvl
     , ss.spx_amount
     , ss.spx_tvl
     , ss.total_solana_tvl
     , b.amount_usd + (e.amount * ep.price) + ss.total_solana_tvl as total_portfolio_tvl
from btc b
left join eth e using(day)
left join eth_price ep using(day)
left join solana_summary ss using(day)
where day < current_date
order by day desc;
