select
    b.date,
    b.tvl as bridged_tvl,
    u.total_tvl as unit_tvl,
    b.tvl + u.total_tvl as total_tvl
from query_5475036 b
left join query_5251219 u on b.date = u.day
where b.date = date_trunc('day', b.date)
order by b.date desc;
