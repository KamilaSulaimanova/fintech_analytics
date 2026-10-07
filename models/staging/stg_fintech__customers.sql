with source as (

    select * from {{ source('fintech_raw', 'raw_customers') }}

),

renamed as (

    select
        customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        lower(email) as email,
        upper(country) as country_code,
        customer_segment,
        cast(signup_date as date) as signup_date,
        cast(date_of_birth as date) as date_of_birth

    from source

)

select * from renamed