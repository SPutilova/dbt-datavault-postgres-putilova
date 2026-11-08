{{  config(enabled=True) }}

{%- set yaml_metadata -%}
source_model: 'source_orders'
derived_columns:
  source: "!source_orders_csv"
  order_date: "order_date"
  order_status: "status"
  load_date: 'current_timestamp'
  effective_from: 'current_timestamp'
hashed_columns:
  order_hk: "id"
  customer_hk: "user_id"
  customer_order_hk: ["user_id", "id"]
  order_hashdiff:
    is_hashdiff: true
    columns:
      - "order_date"
      - "order_status"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}