with posted_transactions as (

    select *
    from {{ ref('fct_transactions') }}
    where status = 'posted'

),

customers as (

    select * from {{ ref('dim_customers') }}

),

transactions_rollup as (

    select
        customer_id,
        count(*) as transaction_count,
        ABS(SUM(CASE WHEN is_debit THEN amount ELSE 0 END)) as total_spent,
        SUM(CASE WHEN NOT is_debit THEN amount ELSE 0 END) as total_inflow,
        MIN(transaction_date) as first_transaction_date,
        MAX(transaction_date) as last_transaction_date

    from posted_transactions
    group by 1

),

final as (

    select
        c.customer_id,
        c.full_name,
        c.customer_segment,
        coalesce(tr.transaction_count, 0) as transaction_count,
        coalesce(tr.total_spent, 0) as total_spent,
        coalesce(tr.total_inflow, 0) as total_inflow,
        tr.first_transaction_date,
        tr.last_transaction_date


    from customers c
    left join transactions_rollup as tr
        on c.customer_id = tr.customer_id

)

select * from final