#This view has population and area stats for Italian provinces


view: italy_province_stats {
  derived_table: {
    sql: SELECT * FROM `lookerdata.covid19_block.italy_province_stats` ;;
    sql_trigger_value: SELECT COUNT(*) FROM `lookerdata.covid19_block.italy_province_stats` ;;
  }

######## PRIMARY KEY ########

  dimension: denominazione_provincia {
    #province name
    type: string
    sql: ${TABLE}.denominazione_provincia ;;
    primary_key: yes
    hidden: yes
  }

######## RAW DIMENSIONS ########

  dimension: area_km2 {
    type: number
    sql: ${TABLE}.area_km2 ;;
    hidden: yes
  }

  dimension: popolazione {
    #population
    type: number
    sql: ${TABLE}.popolazione ;;
    hidden: yes
  }

  dimension: sigla_provincia {
    #province abbreviation
    type: string
    sql: ${TABLE}.sigla_provincia ;;
    hidden: yes
  }

######## MEASURES ########

  measure: population {
    type: sum
    sql: ${popolazione} ;;
    hidden: yes
  }

  measure: land_area {
    type: sum
    sql: ${area_km2} ;;
    hidden: yes
  }



}
