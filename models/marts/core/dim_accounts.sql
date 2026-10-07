with accounts as (

    select * from {{ ref('stg_fintech__accounts') }}

),

customers as (

    select * from {{ ref('stg_fintech__customers') }}

),

final as (

    select
        a.account_id,
        a.customer_id,
        a.account_type,
        a.currency,
        a.opened_date,
        a.closed_date,
        a.status,
        a.is_active,
        c.full_name as customer_name,
        c.customer_segment

    from accounts as a
    inner join customers as c
        on a.customer_id = c.customer_id

)

select * from final