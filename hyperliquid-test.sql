with json_data as (
    select json_parse(http_get('https://api.llama.fi/summary/fees/Hyperliquid?dataType=dailyRevenue')) as parsed_data
)


select * from json_data
limit 10;
