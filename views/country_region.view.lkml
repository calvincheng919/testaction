#This view pulls data from a static table that maps a country to its global region

view: country_region {
  sql_table_name: `lookerdata.covid19_block.country_region`;;

  dimension: country {
    hidden: yes
    primary_key: yes
    type: string
    map_layer_name: countries
    sql: ${TABLE}.Country ;;
  }

  dimension: region {
    group_label: "Location"
    label: "Region (World)"
    type: string
    sql: ${TABLE}.Region ;;
    drill_fields: [covid_combined.country_region]
  }
}
