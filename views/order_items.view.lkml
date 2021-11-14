view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      month_name
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: shipping_days {
    type: number
    sql: DATEDIFF( day, ${shipped_date}, ${delivered_date} );;
  }

  dimension: is_returned {
    type: yesno
    sql: ${returned_date} is not NULL;;
  }



  measure: count {
    type: count
    drill_fields: [detail*]
  }


  measure: Total_Sale_Price {
    description: "Total sales from items sold"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: Average_Sale_Price {
    description: "Average sale price of items sold"
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: Cumulative_Total_Sales {
    description: "Cumulative total sales from items sold (also known as a running total)"
    type: running_total
    sql: ${Total_Sale_Price} ;;
    value_format_name: usd
  }


  measure: Total_Gross_Revenue {
    label: "Total Gross Revenue"
    description: "Total revenue from completed sales (cancelled and returned orders excluded)"
    type: sum
    sql:  ${sale_price} ;;
    filters: [status: "-Returned, -Cancelled"]
    value_format_name: usd
  }

  measure: Total_Cost {
    label: "Total Cost"
    description: "Total cost of items sold from inventory"
    type: sum
    sql: ${inventory_items.cost} ;;
    value_format_name: usd
  }

  measure: Average_Cost {
    label: "Average Cost"
    description: "Average cost of items sold from inventory"
    type: average
    sql: ${inventory_items.cost} ;;
    value_format_name: usd
  }

  measure: Total_Gross_Margin_Amount {
    label: "Total Gross Margin Amount"
    description: "Total difference between the total revenue from completed sales and the cost of the goods that were sold"
    sql: ${Total_Gross_Revenue} - ${Total_Cost} ;;
    value_format_name: usd
  }

  measure: Average_Gross_Margin {
    label: "Average Gross Margin"
    description: "Average difference between the total revenue from completed sales and the cost of the goods that were sold"
    type: average
    sql: ${sale_price} - ${inventory_items.cost};;
    value_format_name: usd
  }

  measure: Gross_Margin_Perc {
    label: "Gross Margin %"
    description: "Total Gross Margin Amount / Total Gross Revenue"
    sql: ${Total_Gross_Margin_Amount} / NULLIF(${Total_Gross_Revenue}, 0) ;;
    value_format_name: percent_1
  }

  measure: Number_of_Items_Returned {
    label: "Number of Items Returned"
    description: "Number of items that were returned by dissatisfied customers"
    type: count_distinct
    sql: ${inventory_item_id} ;;
    filters: [is_returned: "yes"]
    value_format_name:  decimal_0
  }
  measure: Number_of_Items_Sold {
    label: "Number of Items Sold"
    description: "Number of items sold"
    type: count_distinct
    sql: ${inventory_item_id} ;;
    value_format_name:  decimal_0
  }

  measure: Item_Return_Rate {
    label: "Item Return Rate"
    description: "Number of Items Returned / total number of items sold"
    sql: ${Number_of_Items_Returned} } / NULLIF(${Number_of_Items_Sold }}, 0) ;;
    value_format_name: percent_1
  }

  measure: Number_of_Customers_Returning_Items {
    label: "Number of Customers Returning Items"
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [is_returned: "yes"]
    value_format_name:  decimal_0
  }

  measure: Number_of_Customers {
    label: "Number of Customers"
    description: "Number of users"
    type: count_distinct
    sql: ${user_id} ;;
    value_format_name:  decimal_0
  }

  measure: Perc_of_Users_with_Returns {
    label: "% of Users with Returns"
    description: "Number of Customer Returning Items / total number of customers"
    sql: ${Number_of_Customers_Returning_Items} / NULLIF(${Number_of_Customers}}, 0);;
    value_format_name: percent_0
  }

  measure: Average_Spend_per_Customer {
    label: "Average Spend per Customer"
    description: "Total Sale Price / total number of customers"
    sql: ${Total_Sale_Price} / NULLIF(${Number_of_Customers}, 0) ;;
    value_format_name: usd
  }





  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      inventory_items.product_name,
      inventory_items.id,
      users.last_name,
      users.id,
      users.first_name
    ]
  }
}
