-- with json_data as (
--     select json_parse(http_get('https://api.llama.fi/protocol/hyperliquid')) as parsed_data
-- ),

-- tvl as (
--     select 
--         from_unixtime(cast(json_extract_scalar(tvl, '$.date') as bigint)) as date,
--         cast(json_extract_scalar(tvl, '$.totalLiquidityUSD') as double) as tvl
--     from json_data
--     cross join unnest(cast(json_extract(parsed_data, '$.tvl') as array(json))) as t(tvl)
-- )

-- select * from tvl;

with json_data as (
    select json_parse(http_get('https://api.llama.fi/v2/historicalChainTvl/Hyperliquid%20L1')) as parsed_data
),

tvl as (
    select 
        from_unixtime(cast(json_extract_scalar(tvl, '$.date') as bigint)) as date,
        cast(json_extract_scalar(tvl, '$.tvl') as double) as tvl
    from json_data
    cross join unnest(cast(parsed_data as array(json))) as t(tvl)
)

select * from tvl
where date >= date '2024-12-01'
order by date desc;
