with url_table as (
    select * from (values
        ('HYPE', 'https://api.coingecko.com/api/v3/coins/hyperliquid/market_chart?vs_currency=usd&days=365'),
        ('BTC',  'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=365'),
        ('BNB',  'https://api.coingecko.com/api/v3/coins/binancecoin/market_chart?vs_currency=usd&days=365'),
        ('BGB',  'https://api.coingecko.com/api/v3/coins/bitget-token/market_chart?vs_currency=usd&days=365')
    ) as t(coin, url)
), 

json_data as (
    select
        coin,
        json_parse(http_get(url)) as parsed_data
    from url_table
),

price as (
    select 
        coin,
        from_unixtime(cast(json_extract_scalar(item, '$[0]') as bigint) / 1000) as date,
        cast(json_extract_scalar(item, '$[1]') as double) as price
    from json_data,
         unnest(cast(json_extract(parsed_data, '$.prices') as array(json))) as t(item)
),

price_daily as (
    select *
    from price
    where date = date_trunc('day', date)
    and date >= date '2025-01-01' 
),

final_data as (
    select
        date,
        max(case when coin = 'HYPE' then price end) as HYPE_price,
        max(case when coin = 'BTC' then price end) as BTC_price,
        max(case when coin = 'BNB' then price end) as BNB_price,
        max(case when coin = 'BGB' then price end) as BGB_price
    from price_daily
    group by date
)

select *
from final_data
left join query_5471484 using(date)
order by date desc;
