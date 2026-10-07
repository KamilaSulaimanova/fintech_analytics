select
    t.transaction_id,
    t.account_id,
    t.transaction_date,
    a.closed_date
from {{ ref('fct_transactions') }} as t
inner join {{ ref('dim_accounts') }} as a
    on t.account_id = a.account_id
where a.closed_date is not null
  and t.transaction_date > a.closed_date
  and t.status = 'posted'