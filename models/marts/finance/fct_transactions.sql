with enriched as (

    select * from {{ ref('int_transactions_enriched') }}

),

final as (

    select
        transaction_id,
        account_id,
        customer_id,
        merchant_id,
        merchant_name,
        merchant_category,

        transaction_date,
        transaction_type,
        status,
        currency,

        amount,
        is_debit,

        account_type,
        customer_segment,
        customer_country

    from enriched

)

select * from final