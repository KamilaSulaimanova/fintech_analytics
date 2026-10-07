with transactions as (

    select * from {{ ref('stg_fintech__transactions') }}

),

accounts as (

    select * from {{ ref('stg_fintech__accounts') }}

),

customers as (

    select * from {{ ref('stg_fintech__customers') }}

),

merchants as (

    select * from {{ ref('stg_fintech__merchants') }}

),

joined as (

    select
        t.transaction_id,
        t.transaction_date,
        t.transaction_type,
        t.status,
        t.currency,
        t.amount,
        t.is_debit,

        a.account_id,
        a.account_type,
        a.status as account_status,

        c.customer_id,
        c.full_name as customer_name,
        c.customer_segment,
        c.country_code as customer_country,

        m.merchant_id,
        m.merchant_name,
        m.merchant_category

    from transactions as t
    inner join accounts as a
        on t.account_id = a.account_id
    inner join customers as c
        on a.customer_id = c.customer_id
    left join merchants as m
        on t.merchant_id = m.merchant_id

)

select * from joined