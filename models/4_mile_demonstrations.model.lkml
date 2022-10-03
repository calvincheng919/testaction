#connection: "ecommerce_bq"
connection: "looker-private-demo"

# include all the views
include: "/views/**/*.view"
# include all the lookml files
include: "/models/entities/*.lkml"
fiscal_month_offset: 6

persist_with: 4_mile_demonstrations_default_datagroup

explore: order_items {
  label: "Orders Users Products"

  access_filter: {
    field: users.country
    user_attribute: demo_4mile
  }

  sql_always_where: ${users.state} is not null ;;

  conditionally_filter: {
    filters: [order_items.created_year: "last 3 years"]
    unless: [created_date]
  }

  aggregate_table: sales {
    materialization: {
      datagroup_trigger: orders_datagroup
    }
    query: {
      dimensions: [order_items.created_date,
        users.country,users.state,products.brand,
        users.gender,users.age_group,users.traffic_source]
      measures: [order_items.total_sales,order_items.total_sales_pop]
    }
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

  join: repeat_purchase_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${order_items.order_id} = ${repeat_purchase_orders.order_id} ;;
  }

  join: events {
    sql_on: ${events.id} = ${products.id} ;;
    relationship: many_to_one
  }
}

explore: brand_affinity {
  required_access_grants: [can_view_brand_affinity]

   always_filter: {
    filters: {
      field: brand_affinity.product_b_id
      value: "-NULL"
    }
  }

  join: product_a {
    from: products
    view_label: "Product A Details"
    relationship: many_to_one
    sql_on: ${brand_affinity.product_a_id} = ${product_a.id} ;;
  }

  join: product_b {
    from: products
    view_label: "Product B Details"
    relationship: many_to_one
    sql_on: ${brand_affinity.product_b_id} = ${product_b.id} ;;
  }
}