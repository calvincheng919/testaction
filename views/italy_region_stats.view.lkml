#This view has population and area stats for Italian regions

view: italy_region_stats {
  derived_table: {
    sql: SELECT *, cast(codice_regione as string) codice_regione_str FROM `lookerdata.covid19_block.italy_region_stats` ;;
    sql_trigger_value: SELECT COUNT(*) FROM `lookerdata.covid19_block.italy_region_stats` ;;
  }

  ######## PRIMARY KEY ########

  dimension: pk {
    # Because of the splitting of Bolzano and Trento, need both code and name of region to be unique
    sql: CONCAT(${codice_regione}, ${denominazione_regione}) ;;
    primary_key: yes
    hidden: yes
  }

######## RAW DIMENSIONS ########

  dimension: area_km2 {
    type: number
    sql: ${TABLE}.area_km2 ;;
    hidden: yes
  }

  # dimension: codice_regione {
  #   #region_code
  #   type: string
  #   sql: ${TABLE}.codice_regione ;;
  #   hidden: yes
  # }

  dimension: codice_regione {
    #region_code
    type: string
    sql: ${TABLE}.codice_regione_str ;;
    hidden: yes
  }

  dimension: denominazione_regione {
    #region_name
    type: string
    sql: ${TABLE}.denominazione_regione ;;
    hidden: yes
  }

  dimension: popolazione {
    #population
    type: number
    sql: ${TABLE}.popolazione ;;
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
