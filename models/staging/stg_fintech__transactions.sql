with source as (

    select * from {{ source('fintech_raw', 'raw_transactions') }}

),

renamed as (

    select
        transaction_id,
        account_id,
        nullif(merchant_id, '') as merchant_id,
        cast(transaction_date as date) as transaction_date,
        transaction_type,
        upper(currency) as currency,
        cast(amount as decimal(18,2)) as amount,
        status,
        cast(amount as decimal(18,2)) < 0 as is_debit

    from source

)

select * from renamed