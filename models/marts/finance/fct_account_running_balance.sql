with posted_transactions as (

    select *
    from {{ ref('fct_transactions') }}
    where status = 'posted'

),

daily_net_movement as (

    select
        account_id,
        transaction_date,
        sum(amount) as net_amount,
        count(*) as transaction_count

    from posted_transactions
    group by 1, 2

),

running_balance as (

    select
        account_id,
        transaction_date,
        net_amount,
        transaction_count,
        sum(net_amount) over (
            partition by account_id
            order by transaction_date
            rows between unbounded preceding and current row
        ) as running_balance

    from daily_net_movement

)

select * from running_balance