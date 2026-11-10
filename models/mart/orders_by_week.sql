{{ config(materialized='table') }}

{%- set datepart = "week" -%}
{%- set start_date = "TO_DATE('2018/01/01', 'yyyy/mm/dd')" -%}
{%- set end_date = "TO_DATE('2027/01/01', 'yyyy/mm/dd')" -%}

WITH week_start AS (
    {{ dbt_utils.date_spine(datepart=datepart, 
                            start_date=start_date,
                            end_date=end_date) }}
)
, orders as
(select order_hk
		,order_date
		,date_trunc('week', order_date)::date order_week_date
from (
	select  order_hk
		   ,order_date
	   	    ,row_number() over (partition by order_hk order by load_date desc) rn
			from 
			{{ ref('sat_order') }} so)
where rn = 1)
,orders_weekly as (select
order_week_date
		,count(*) cnt
		from
		orders
group by order_week_date)
select coalesce (order_week_date, date_week) week_date
		,coalesce(cnt, 0) cnt
from week_start 
left join orders_weekly 
on week_start.date_week = orders_weekly.order_week_date