select
    (case
        when total_amount < 10 then '(1) $0-10'
        when total_amount >= 10 and total_amount < 20 then '(2) $10-20'
        when total_amount >= 20 and total_amount < 50 then '(3) $20-50'
        when total_amount >= 50 and total_amount < 500 then '(4) $50-500'
        else '(5) +$500'
    end) as amount_class,
    count(*) as num_of_depositors
from query_5371282
group by 1
order by 1 asc;
