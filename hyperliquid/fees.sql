with json_data as (
    select json_parse(http_get('https://api.llama.fi/summary/fees/Hyperliquid')) as parsed_data
),

fees_data as (
    select json_extract(parsed_data, '$.totalDataChartBreakdown') as breakdown_array
    from json_data
),

final_data as (
    select
        from_unixtime(cast(json_extract_scalar(item, '$[0]') as bigint)) as date,
        json_extract(item, '$[1]["Hyperliquid L1"]["Hyperliquid Spot Orderbook"]') as daily_fees
    from fees_data
    cross join unnest(cast(json_extract(breakdown_array, '$') as array(json))) as t(item)
),

ma_data as (
    select
        date,
        cast(daily_fees as double) as fees,
        lag(cast(daily_fees as double)) over (order by date) as prev_day_fees,
        avg(cast(daily_fees as double)) over (order by date rows between 29 preceding and current row) as thirty_day_ma
    from final_data
)


select
    date,
    fees,
    round(thirty_day_ma, 2) as ma_fees
from ma_data
where date = date_trunc('day', date)
and date >= date '2025-01-01'
order by date desc;
