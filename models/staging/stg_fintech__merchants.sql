with source as (

    select * from {{ source('fintech_raw', 'raw_merchants') }}

),

renamed as (

    select
        merchant_id,
        merchant_name,
        merchant_category

    from source

)

select * from renamed