with json_data as (
    select json_parse(http_get('https://api.llama.fi/updatedProtocol/hyperliquid-bridge')) as parsed_data
),

bridged_tvl as (
    select 
        from_unixtime(cast(json_extract_scalar(tvl, '$.date') as bigint)) as date,
        cast(json_extract_scalar(tvl, '$.totalLiquidityUSD') as double) as tvl
    from json_data
    cross join unnest(cast(json_extract(parsed_data, '$.chainTvls.Arbitrum.tvl') as array(json))) as t(tvl)
)


select 
    date,
    tvl
from bridged_tvl
where date >= date '2024-01-01'
order by date desc;
