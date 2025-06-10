/*
    Checks that, for any order, that the number of line items in the order_items table
	matches the num_items_ordered column in the orders table.

    Returns all of the rows where we don't get a match

    We could run multiple checks here (e.g. check only 1 user_id per order, or that the shipped_at timestamps
	are all the same for a given order), but this is just an example of a custom test.
*/

{{ config(error_if = '>1') }} -- default for stg test is warn, this bypass it if >1 line, otherwise warn

WITH order_details AS (
    SELECT
        order_id,
        COUNT(*) AS num_of_items_in_order

    FROM {{ ref('stg_ecommerce__order_items')}}
    GROUP BY 1
)

SELECT
    o.*,
    od.*,

FROM {{ ref('stg_ecommerce__orders')}} AS o
FULL OUTER JOIN order_details AS od USING (order_id)
WHERE
    o.order_id IS NULL
    OR od.order_id IS NULL
    OR o.num_of_items_in_ordered != od.num_of_items_in_order