with url as (
    select *
    from (
      values
        ('https://api.llama.fi/v2/historicalChainTvl/Hyperliquid%20L1'),
        ('https://api.llama.fi/protocol/hyperliquid'),
        ('https://api.llama.fi/protocol/felix'),
        ('https://api.llama.fi/protocol/hyperlend'),
        ('https://api.llama.fi/protocol/hypurrfi'),
        ('https://api.llama.fi/protocol/hyperbeat'),
        ('https://api.llama.fi/protocol/hyperswap')
    ) as t(url)
),

json_data as (
    select
        case 
            when url like '%Chain%' then 'chain'
            else 'protocol'
        end as category,
        json_parse(http_get(url)) as parsed_data
    from url
),

chain_tvl as (
    select
        coalesce(json_extract_scalar(parsed_data, '$.name'), 'Hyperliquid-L1') as name,
        from_unixtime(cast(json_extract_scalar(tvl, '$.date') as bigint)) as date,
        cast(json_extract_scalar(tvl, '$.tvl') as double) as tvl
    from json_data
    cross join unnest(cast(parsed_data as array(json))) as t(tvl)
    where category = 'chain'
),

protocol_tvl as (
    select
        json_extract_scalar(parsed_data, '$.name') as name,
        from_unixtime(cast(json_extract_scalar(tvl, '$.date') as bigint)) as date,
        cast(json_extract_scalar(tvl, '$.totalLiquidityUSD') as double) as tvl
    from json_data
    cross join unnest(cast(json_extract(parsed_data, '$.tvl') as array(json))) as t(tvl)
    where category = 'protocol'
),

tvl as (
    select * from chain_tvl
    where date >= date '2024-12-01'
    union all
    select * from protocol_tvl
    where date >= date '2024-12-01'
),

tvl_pivot as (
    select 
      date,
      max(case when name = 'Hyperliquid-L1' then tvl end) as HyperliquidL1,
      max(case when name = 'Hyperliquid' then tvl end) as Hyperliquid,
      max(case when name = 'Felix' then tvl end) as Felix,
      max(case when name = 'HyperLend' then tvl end) as HyperLend,
      max(case when name = 'HypurrFi' then tvl end) as HypurrFi,
      max(case when name = 'Hyperbeat' then tvl end) as Hyperbeat,
      max(case when name = 'HyperSwap' then tvl end) as HyperSwap
    from tvl
    group by date
)


select *,
       HyperliquidL1 - coalesce(Hyperliquid, 0) as Total,
       HyperliquidL1 
         - coalesce(Hyperliquid, 0) 
         - coalesce(Felix, 0) 
         - coalesce(HyperLend, 0)
         - coalesce(HypurrFi, 0)
         - coalesce(Hyperbeat, 0)
         - coalesce(HyperSwap, 0) as Others
from tvl_pivot
where date = date_trunc('day', date)
and date > date '2025-04-01'
order by date desc;
