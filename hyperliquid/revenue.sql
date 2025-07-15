with json_data as (
    select json_parse(http_get('https://api.llama.fi/summary/fees/Hyperliquid?dataType=dailyRevenue')) as parsed_data
),

revenue_data as (
    select json_extract(parsed_data, '$.totalDataChartBreakdown') as breakdown_array
    from json_data
),

final_data as (
    select
        from_unixtime(cast(json_extract_scalar(item, '$[0]') as bigint)) as date,
        json_extract(item, '$[1]["Hyperliquid L1"]["Hyperliquid Spot Orderbook"]') as daily_revenue
    from revenue_data
    cross join unnest(cast(json_extract(breakdown_array, '$') as array(json))) as t(item)
)


select * from final_data
;
