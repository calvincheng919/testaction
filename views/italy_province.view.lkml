#This view pulls in data about cases for italian provinces

view: italy_province {
  derived_table: {
    sql:
    -- First roll the province-level data up to the region level
    WITH region_rollup AS (
      SELECT
        date(date) as date
        , region_code AS region_code
        -- Because of Trento/Bolzano, we need the denominazione as well as the codice
        , name
        , SUM(confirmed_cases) as province_cases
      FROM `bigquery-public-data.covid19_italy.data_by_province`
      GROUP BY 1, 2, 3),
    unioned_provinces as (SELECT
      date(ir.date) as date
      , ir.region_name
      , ir.region_code
      -- Since we're looking for data that isn't specified in the province-level, use this
      , "In fase di definizione/aggiornamento" as province_name
      , '' as province_abbreviation
      , ir.total_confirmed_cases - rr.province_cases as confirmed_cases
    FROM
      `bigquery-public-data.covid19_italy.data_by_region` ir
      -- Join the regional data to the province-level rollup on date, region code and region name
      LEFT JOIN region_rollup rr ON
        date(rr.date) = date(ir.date)
        AND rr.region_code = ir.region_code
        AND ir.region_name = rr.name
    WHERE
      -- Next find the rows in which the sum of province data doesn't match the regional data
      ir.total_confirmed_cases - rr.province_cases <> 0
    UNION ALL
    -- Now union the few rows that we had to create with the actual province-level data
    SELECT
      date(date) as date
      , name
      , region_code AS region_code
      , province_name
      , province_abbreviation
      , confirmed_cases
    FROM
      `bigquery-public-data.covid19_italy.data_by_province`
    WHERE
      not (province_name = "In fase di definizione/aggiornamento" AND confirmed_cases = 0))
    SELECT
      date
      , region_name
      , region_code
      , province_name
      , province_abbreviation
      , confirmed_cases
      , confirmed_cases - coalesce(LAG(confirmed_cases, 1) OVER (PARTITION BY province_name, region_name ORDER BY date ASC),0) as new_confirmed_cases
    FROM
      unioned_provinces
    ;;
    sql_trigger_value: SELECT COUNT(*) FROM `bigquery-public-data.covid19_italy.data_by_province`;;
  }

######## PRIMARY KEY ########

  dimension: pk {
    primary_key: yes
    sql: concat(${region_name}, ${province_name}, ${reporting_date}) ;;
    hidden: yes
  }

  dimension: region_fk {
    sql: concat(${region}, ${region_code}, ${reporting_date}) ;;
    hidden: yes
  }

######## RAW DIMENSIONS ########

  dimension_group: reporting {
    type: time
    datatype: date
    timeframes: [
      date,
    ]
    sql: ${TABLE}.date ;;
    hidden: yes
  }

  dimension: region_name {
    #denominazione_regione
    type: string
    sql: ${TABLE}.region_name ;;
    hidden: yes
    description: "The name of the region in Italy, with Trento and Bolzano named separately (IT: Denominazione Regione)"
  }

  dimension: region_code {
    #codice_regione
    type: number
    sql: ${TABLE}.region_code ;;
    hidden: yes
    description: "The ISTAT code of the region in Italy, (IT: Codice della Regione)"
    drill_fields: [italy_province.denominazione_provincia]
  }

  dimension: province_name {
    #denominazione_provincia
    type: string
    sql: ${TABLE}.province_name ;;
    hidden: yes
    label: "Raw Province Name"
    description: "The name of the province in Italy, (IT: Denominazione Provincia)"
  }

  dimension: province_abbreviation {
    #sigla_provincia
    type: string
    sql: ${TABLE}.province_abbreviation ;;
    description: "The initials of the province in Italy, (IT: Sigla Provincia)"
  }

  dimension: confirmed_cases {
    type: number
    hidden: yes
    label: "Total cases"
    sql: ${TABLE}.confirmed_cases ;;
  }

  dimension: new_confirmed_cases {
    #totale_casi_nuovi
    type: number
    hidden: yes
    label: "New cases"
    sql: ${TABLE}.new_confirmed_cases ;;
  }


######## NEW DIMENSIONS ########

  dimension: province {
    #nome_pro
    type: string
    sql:  CASE
            WHEN UPPER(${province_name}) = "IN FASE DI DEFINIZIONE/AGGIORNAMENTO"
            THEN "Not Specified"
            ELSE ${province_name}
          END
             ;;
    map_layer_name: province_italiane
    label: "Province Name"
    description: "The name of the province in Italy, (IT: Denominazione Provincia)"
  }

  dimension: region {
    #nome_reg
    type: string
    sql: CASE
          WHEN ${region_name} = 'P.A. Bolzano'
          THEN 'Bolzano'
          WHEN ${region_name} = 'P.A. Trento'
          THEN 'Trento'
          WHEN ${region_name} in ('Emilia Romagna', 'Emilia-Romagna')
          THEN 'Emilia-Romagna'
          WHEN ${region_name} = "Valle d'Aosta"
          THEN 'Valle d’Aosta'
          ELSE ${region_name}
        END
          ;;
    hidden: yes
  }


######## NEW MEASURES ########

## If date selected, report on total cases (running total) for the given date(s)
## Otherwise report on total cases (running total) for most recent date
  measure: total_cases {
    type: sum
    sql:  {% if italy.reporting_date._is_selected %}
            ${confirmed_cases}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${confirmed_cases} ELSE NULL END
          {% endif %};;
    label: "Total cases"
    description: "Running total of confirmed cases (IT: Totale casi), avail by region or province"
    group_label: "Total cases"
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }

  measure: total_cases_pp {
    type: number
    sql: 1000 * ${total_cases}/NULLIF(${population}, 0) ;;
    label: "Total cases (per thousand)"
    group_label: "Total cases"
    value_format_name: decimal_2
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }

  measure: new_cases_province {
    type: sum
    sql:  ${new_confirmed_cases};;
    hidden: yes
  }


  measure: population {
    description: "The total estimated population"
    type: number
    sql: ${italy_province_stats.population} ;;
    label: "Population"
    value_format_name: decimal_0
    hidden: yes
  }






}
