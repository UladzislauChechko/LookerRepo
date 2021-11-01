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
      year
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
    description: "Total revenue from completed sales (cancelled and returned orders excluded)"
    type: sum
    sql:  ${sale_price} ;;
    filters: [is_returned: "no"]
    value_format_name: usd
  }






  measure: Gross_Margin_Perc {
    description: "Total Gross Margin Amount / Total Gross Revenue"
    sql: ${Total_Gross_Margin_Amount }/${Total_Gross_Revenue } ;;
    value_format_name: percent_1
  }

  measure: Number_of_Items_Returned {
    description: "Number of items that were returned by dissatisfied customers"
    type: count
    sql: ${inventory_item_id} ;;
    filters: [is_returned: "yes"]
    value_format_name:  decimal_0
  }
  measure: Number_of_Items_Sold {
    description: "Number of items sold"
    type: count
    sql: ${inventory_item_id} ;;
    value_format_name:  decimal_0
  }

  measure: Item_Return_Rate {
    description: "Number of Items Returned / total number of items sold"
    sql: ${Number_of_Items_Returned} }/${Number_of_Items_Sold } ;;
    value_format_name: percent_1
  }



  measure: Number_of_Customers_Returning_Items {
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [is_returned: "yes"]
    value_format_name:  decimal_0
  }

  measure: Number_of_Customers {
    description: "Number of users"
    type: count_distinct
    sql: ${user_id} ;;
    value_format_name:  decimal_0
  }


  measure: Perc_of_Users_with_Returns {
    description: "Number of Customer Returning Items / total number of customers"

    sql: ${Number_of_Customers_Returning_Items} /${Number_of_Customers };;
    value_format_name: percent_0
  }

  measure: Average_Spend_per_Customer {
    description: "Total Sale Price / total number of customers"
    sql: ${Total_Sale_Price}/${Number_of_Customers} ;;
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
