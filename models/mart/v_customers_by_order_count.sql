{{ config(materialized='view')    }}
with completed_orders as (
SELECT po.order_hk FROM {{ ref('pit_order') }} po
inner join {{ ref('sat_order') }}  so 
		on  so.order_hk = po.order_hk 
		and po.sat_order_ldts = so.load_date
where po.as_of_date = date_trunc('day',current_timestamp)
and so.order_status = 'completed' )
, customers as(
SELECT  hc.customer_hk,
		hc.id, 
		sc.email, 
		sc.last_name, 
		sc.first_name 
		FROM  {{ ref('pit_customer') }}  pc
left join {{ ref('hub_customer') }}  hc
		on hc.customer_hk = pc.customer_hk
left join  {{ ref('sat_customer') }} sc 
		on  sc.customer_hk = hc.customer_hk
		and pc.sat_customer_ldts = sc.load_date
where pc.as_of_date = date_trunc('day',current_timestamp)
)
,grouped_orders as(
select customer_hk, count(*) cnt
from {{ ref('link_customer_order') }} lco
inner join completed_orders co 
			on co.order_hk=lco.order_hk
group by customer_hk)
select  customers.id,
		customers.email,
		customers.last_name, 
		customers.first_name, 
		coalesce(cnt,0) order_count
from customers left join grouped_orders 
					on grouped_orders.customer_hk = customers.customer_hk
order by order_count desc, last_name asc