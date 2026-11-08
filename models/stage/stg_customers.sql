{{  config(enabled=True) }}

{%- set yaml_metadata -%}
source_model: 'source_customers'
derived_columns:
  source: "!source_customers_csv"
  first_name: "first_name"
  last_name: "last_name"
  email: "email"
  load_date: 'current_timestamp'
  effective_from: 'current_timestamp'
hashed_columns:
  customer_hk: "id"
  customer_hashdiff:
    is_hashdiff: true
    columns:
      - "first_name"
      - "last_name"
      - "email"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}