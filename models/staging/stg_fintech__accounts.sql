with source as (

    select * from {{ source('fintech_raw', 'raw_accounts') }}

),

renamed as (

    select
        account_id,
        customer_id,
        account_type,
        upper(currency) as currency,
        cast(opened_date as date) as opened_date,
        nullif(closed_date, '') as closed_date_text,
        try_cast(nullif(closed_date, '') as date) as closed_date,
        status,
        status = 'active' as is_active

    from source

)

select * from renamed