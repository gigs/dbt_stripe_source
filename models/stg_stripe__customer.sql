
with base as (

    select * 
    from {{ ref('stg_stripe__customer_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_stripe__customer_tmp')),
                staging_columns=get_customer_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='stripe_union_schemas', 
            union_database_variable='stripe_union_databases') 
        }}

    from base
),

final as (
    
    select 
        id as customer_id,
        account_balance,
        created as created_at,
        currency,
        default_card_id,
        delinquent as is_delinquent,
        description,
        email,
        metadata,
        shipping_address_city,
        shipping_address_country,
        shipping_address_line_1,
        shipping_address_line_2,
        shipping_address_postal_code,
        shipping_address_state,
        shipping_name,
        shipping_phone

        {{ fivetran_utils.source_relation(
            union_schema_variable='stripe_union_schemas', 
            union_database_variable='stripe_union_databases') 
        }}
        
        {% if var('stripe__customer_metadata',[]) %}
        , {{ fivetran_utils.pivot_json_extract(string = 'metadata', list_of_properties = var('stripe__customer_metadata')) }}
        {% endif %}

    from fields
)

select * 
from final
