with customers as (

    select * from {{ ref('stg_fintech__customers') }}

),

accounts as (

    select * from {{ ref('stg_fintech__accounts') }}

),

account_rollup as (

    select
        customer_id,
        count(*) as total_accounts,
        count_if(status = 'active') as active_accounts

    from accounts
    group by 1

),

final as (

    select
        c.customer_id,
        c.full_name,
        c.email,
        c.country_code,
        c.customer_segment,
        c.signup_date,
        coalesce(ar.total_accounts, 0) as total_accounts,
        coalesce(ar.active_accounts, 0) as active_accounts

    from customers as c
    left join account_rollup as ar
        on c.customer_id = ar.customer_id

)

select * from final