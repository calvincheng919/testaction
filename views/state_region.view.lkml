#This view pulls data from a static table that has information about each state - name, region, abbreviation, etc.


view: state_region {
  sql_table_name: `lookerdata.covid19_block.state_region`;;

  dimension: division {
    hidden: yes
    type: string
    sql: ${TABLE}.Division ;;
  }

  dimension: region {
    group_label: "Location"
    label: "Region (US-Only)"
    type: string
    sql: ${TABLE}.Region ;;
  }

  dimension: state {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.State ;;
    drill_fields: [covid_combined.province_state]
  }

  dimension: state_code {
    hidden: yes
    type: string
    sql: ${TABLE}.StateCode ;;
  }
}
