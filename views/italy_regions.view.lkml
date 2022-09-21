#This view pulls in data about cases, hospitalizations, and tests for italian regions

view: italy_regions {
  # SRC: https://github.com/pcm-dpc/COVID-19/blob/master/dati-regioni/dpc-covid19-ita-regioni.csv
  derived_table: {
    sql:
    SELECT
      date(ir.date) as date
      , ir.region_name
      , ir.region_code region_code
      , ir.hospitalized_patients_symptoms
      , hospitalized_patients_symptoms - coalesce(LAG(hospitalized_patients_symptoms, 1) OVER (PARTITION BY ir.region_name, ir.region_code ORDER BY ir.date ASC),0) as change_in_hospitalized_patients_symptoms
      , ir.hospitalized_patients_intensive_care
      , hospitalized_patients_intensive_care - coalesce(LAG(hospitalized_patients_intensive_care, 1) OVER (PARTITION BY ir.region_name, ir.region_code ORDER BY ir.date ASC),0) as change_in_hospitalized_patients_intensive_care
      , ir.total_hospitalized_patients
      , total_hospitalized_patients - coalesce(LAG(total_hospitalized_patients, 1) OVER (PARTITION BY ir.region_name, ir.region_code ORDER BY ir.date ASC),0) as change_in_total_hospitalized_patients
      , ir.home_confinement_cases
      , home_confinement_cases - coalesce(LAG(home_confinement_cases, 1) OVER (PARTITION BY ir.region_name, ir.region_code ORDER BY ir.date ASC),0) as change_in_home_confinement_cases
      , ir.total_current_confirmed_cases
      , ir.new_current_confirmed_cases
      , ir.recovered
      , recovered - coalesce(LAG(recovered, 1) OVER (PARTITION BY ir.region_name, ir.region_code ORDER BY ir.date ASC),0) as new_recovered
      , ir.deaths
      , deaths - coalesce(LAG(deaths, 1) OVER (PARTITION BY ir.region_name, ir.region_code ORDER BY ir.date ASC),0) as new_deaths
      , ir.total_confirmed_cases
      , ir.total_confirmed_cases - coalesce(LAG(ir.total_confirmed_cases, 1) OVER (PARTITION BY ir.region_name, ir.region_code ORDER BY ir.date ASC),0) as new_total_confirmed_cases
      , ir.tests_performed
      , tests_performed - coalesce(LAG(tests_performed, 1) OVER (PARTITION BY ir.region_name, ir.region_code ORDER BY ir.date ASC),0) as new_tests_performed
    FROM
      `bigquery-public-data.covid19_italy.data_by_region` ir
    WHERE
      date is not null
      AND region_name is not null
      ;;
    sql_trigger_value: SELECT COUNT(*) FROM `bigquery-public-data.covid19_italy.data_by_region` WHERE region_name is not null ;;
  }


######## PRIMARY KEY ########

  dimension: pk {
    primary_key: yes
    # Need both the name and code of each region because they're reporting Bolzano and Trento on their own rows despite their both being in region 4
    sql: concat(${region}, ${region_code}, ${reporting_date}) ;;
    hidden: yes
  }

######## RAW DIMENSIONS ########

  dimension_group: reporting {
    type: time
    datatype: date
    timeframes: [
      date,
      week,
      month,
    ]
    sql: ${TABLE}.date ;;
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
    description: "The ISTAT code of the region in Italy, (IT: Codice della Regione)"
    drill_fields: [italy_province.province]
  }

  dimension: hospitalized_patients_symptoms {
    #ricoverati_con_sintomi
    type: number
    hidden: yes
    label: "Currently hospitalized patients with symptoms"
    sql: ${TABLE}.hospitalized_patients_symptoms ;;
  }

  dimension: change_in_hospitalized_patients_symptoms {
    #ricoverati_con_sintomi_cambio
    type: number
    hidden: yes
    label: "Change in hospitalized patients with symptoms"
    sql: ${TABLE}.change_in_hospitalized_patients_symptoms ;;
  }

  dimension: hospitalized_patients_intensive_care {
    #terapia_intensiva
    type: number
    hidden: yes
    label: "Current ICU patients"
    sql: ${TABLE}.hospitalized_patients_intensive_care ;;
  }

  dimension: change_in_hospitalized_patients_intensive_care {
    #terapia_intensiva_cambio
    type: number
    hidden: yes
    label: "Change in ICU patients"
    sql: ${TABLE}.change_in_hospitalized_patients_intensive_care;;
  }

  dimension: total_hospitalized_patients {
    #totale_ospedalizzati
    type: number
    hidden: yes
    label: "Total hospitalized"
    sql: ${TABLE}.total_hospitalized_patients ;;
  }

  dimension: change_in_total_hospitalized_patients {
    #totale_ospedalizzati_cambio
    type: number
    hidden: yes
    label: "Change in total hospitalized"
    sql: ${TABLE}.change_in_total_hospitalized_patients ;;
  }

  dimension: home_confinement_cases {
    #isolamento_domiciliare
    type: number
    hidden: yes
    label: "Currently under home quarantine"
    sql: ${TABLE}.home_confinement_cases ;;
  }

  dimension: change_in_home_confinement_cases {
    #isolamento_domiciliare_cambio
    type: number
    hidden: yes
    label: "Change in number under home quarantine"
    sql: ${TABLE}.change_in_home_confinement_cases ;;
  }

  dimension: total_current_confirmed_cases {
    #totale_positivi
    type: number
    hidden: yes
    label: "Total number of current positive cases (Hospitalized patients + Home confinement)"
    sql: ${TABLE}.total_current_confirmed_cases ;;
  }

  dimension: new_current_confirmed_cases {
    #variazione_totale_positivi
    type: number
    hidden: yes
    label: "New amount of active cases (total number of active cases - total number of active cases from the previous day)"
    sql: ${TABLE}.new_current_confirmed_cases ;;
  }

  dimension: recovered {
    #dimessi_guariti
    type: number
    hidden: yes
    sql: ${TABLE}.recovered ;;
  }

  dimension: new_recovered {
    #dimessi_guariti_nuovi
    type: number
    hidden: yes
    label: "Newly recovered"
    sql: ${TABLE}.new_recovered ;;
  }

  dimension: deaths {
    #deceduti
    type: number
    hidden: yes
    label: "Deceased"
    sql: ${TABLE}.deaths ;;
  }

  dimension: new_deaths {
    #deceduti_nuovi
    type: number
    hidden: yes
    label: "Newly deceased"
    sql: ${TABLE}.new_deaths ;;
  }

  dimension: total_confirmed_cases {
    #totale_casi_regione
    type: number
    hidden: yes
    label: "Total cases"
    sql: ${TABLE}.total_confirmed_cases ;;
  }

  dimension: new_total_confirmed_cases {
    #totale_casi_nuovi_regione
    type: number
    hidden: yes
    label: "New cases"
    sql:${TABLE}.new_total_confirmed_cases ;;
  }

  dimension: tests_performed {
    #tamponi
    type: number
    hidden: yes
    label: "Tests"
    sql:${TABLE}.tests_performed ;;
  }

  dimension: new_tests_performed {
    #tamponi_nuovi
    type: number
    hidden: yes
    label: "New tests"
    sql:${TABLE}.new_tests_performed ;;
  }



######## NEW DIMENSIONS ########

#   dimension: is_max_date {
#     type: yesno
#     hidden: no
#     sql: ${reporting_date} =  ${max_italy_date.max_date};;
#   }

  dimension: region {
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
    map_layer_name: regioni_italiani
    label: "Region Name"
    description: "The name of the region in Italy, (IT: Denominazione Regione)"
    drill_fields: [italy_provinces.province]
  }

######## NEW MEASURES ########

## If date selected, report on non-icu hospitalizations for the given date(s)
## Otherwise report on non-icu hospitalizations for most recent date
  measure: currently_hospitalized {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${hospitalized_patients_symptoms}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${hospitalized_patients_symptoms} ELSE NULL END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    label: "Non-ICU hospitalizations"
    description: "Current number of patients hospitalized, excluding in ICU (IT: Ricoverati con sintomi), avail by region only"
    group_label: "Current cases by status"
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }

  measure: hospitalized_non_icu_pp {
    type: number
    sql: 1000* ${currently_hospitalized}/NULLIF(${population}, 0) ;;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    label: "Currently hospitalized (non-ICU) (per thousand)"
    group_label: "Current cases by status"
    value_format_name: decimal_2
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }

#   measure: currently_hospitalized_change {
#     type: sum
#     sql: ${ricoverati_con_sintomi_cambio} ;;
#     label: "Change hospitalized patients"
#     value_format: "#;-#"
#   }

## If date selected, report on icu hospitalizations for the given date(s)
## Otherwise report on icu hospitalizations for most recent date
  measure: icu {
    type: sum
    label: "Current ICU patients"
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${hospitalized_patients_intensive_care}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${hospitalized_patients_intensive_care} ELSE NULL END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    description: "Current number of patients in ICU (IT: Terapia intensiva), avail by region only"
    group_label: "Current cases by status"
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }

  measure: icu_pp {
    type: number
    sql: 1000* ${icu}/NULLIF(${population}, 0) ;;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    label: "Current ICU patients (per thousand)"
    group_label: "Current cases by status"
    value_format_name: decimal_2
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }

#   dimension: terapia_intensiva_cambio {
#     type: number
#     hidden: yes
#     label: "Change in ICU patients"
#   }

## If date selected, report on all hospitalizations for the given date(s)
## Otherwise report on all hospitalizations for most recent date
  measure: total_hospitalized {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${total_hospitalized_patients}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${total_hospitalized_patients} ELSE NULL END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    label: "All hospitalizations"
    description: "Current number of patients hospitalized, including in ICU (IT: Totale ospedalizzati), avail by region only"
    group_label: "Current cases by status"
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }

  measure: change_in_hospitalization {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% else %}
            ${change_in_total_hospitalized_patients}
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Change in total hospitalized"
    description: "Change in number of patients hospitalized from previous period, including in ICU (IT: Totale ospedalizzati cambio), avail by region only"
    group_label: "Current cases by status"
  }

  measure: hospitalized_pp {
    type: number
    sql: 1000* ${total_hospitalized}/NULLIF(${population}, 0) ;;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    label: "Current Hospitalized (incl ICU) (per thousand)"
    group_label: "Current cases by status"
    value_format_name: decimal_2
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }

## If date selected, report on number of people under home quarantine for the given date(s)
## Otherwise report on number of people under home quarantine for most recent date
  measure: home_quarantine {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${home_confinement_cases}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${home_confinement_cases} ELSE NULL END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Currently under home quarantine"
    description: "Positive cases currently at home (IT: Isolamento domiciliare), avail by region only"
    group_label: "Current cases by status"
  }

  measure: home_quarantine_pp {
    type: number
    sql: 1000* ${home_quarantine}/NULLIF(${population}, 0) ;;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Current Home Quarantine (per thousand)"
    group_label: "Current cases by status"
    value_format_name: decimal_2
  }

## If date selected, report on total active cases for the given date(s)
## Otherwise report on total active cases for most recent date
  measure: total_active_cases {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${total_current_confirmed_cases}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${total_current_confirmed_cases} ELSE NULL END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Total number of active cases"
    description: "Count of active cases including hospitalized patients + home confinement (IT: Totale attualmente positive), avail by region only"
    group_label: "Total cases"
  }

  measure: total_active_cases_pp {
    type: number
    sql: 1000* ${total_active_cases}/NULLIF(${population}, 0) ;;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Total Active Cases (per thousand)"
    group_label: "Total cases"
    value_format_name: decimal_2
  }

## If date selected, report on total recovered cases (running total) for the given date(s)
## Otherwise report on total recovered cases (running total) for most recent date
  measure: total_recovered {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${recovered}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${recovered} ELSE NULL END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Recovered"
    description: "Running total of all patients who have recovered (IT: Dimessi guariti), avail by region only"
    group_label: "Resolved cases by status"
  }

  measure: total_recovered_pp {
    type: number
    sql: 1000* ${total_recovered}/NULLIF(${population}, 0) ;;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Total Recovered (per thousand)"
    group_label: "Resolved cases by status"
    value_format_name: decimal_2
  }

  measure: newly_recovered {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% else %}
            ${new_recovered}
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Newly recovered"
    description: "The count of patients who were reported recovered in that day (IT: Dimessi guariti nuovi), avail by region only"
    group_label: "Resolved cases by status"
  }

## If date selected, report on total deaths (running total) for the given date(s)
## Otherwise report on total deaths (running total) for most recent date
  measure: deceased {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${deaths}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${deaths} ELSE NULL END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Deceased"
    description: "Running total of deaths (IT: Deceduti), avail by region only"
    group_label: "Resolved cases by status"
  }

  measure: total_deceased_pp {
    type: number
    sql: 1000* ${deceased}/NULLIF(${population}, 0) ;;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Total Deaths (per thousand)"
    group_label: "Resolved cases by status"
    value_format_name: decimal_2
  }

  measure: newly_deceased {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% else %}
            ${new_deaths}
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Newly deceased"
    description: "The count of deaths by day (IT: Deceduti nuovi), avail by region only"
    group_label: "Resolved cases by status"
  }

  measure: total_cases_region {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${total_confirmed_cases}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${total_confirmed_cases} ELSE NULL END
          {% endif %};;
    hidden: yes
  }

  measure: new_cases_region {
    type: sum
    sql:  ${new_total_confirmed_cases};;
    hidden: yes
  }

## If date selected, report on total new cases for the given date(s)
## Otherwise report on total new cases for most recent date
  measure: new_cases {
    type: number
    sql:  {% if italy_province.province._in_query  or italy_province.province_abbreviation._in_query %}
            ${italy_province.new_cases_province}
          {% else %}
            ${new_cases_region}
          {% endif %};;
      label: "New cases"
      description: "Newly confirmed cases by day (IT: Totale casi nuovi), avail by region or province"
      group_label: "Total cases"
      drill_fields: [italy_province.province]
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    }

## If date selected, report on total tests run (running total) for the given date(s)
## Otherwise report on total tests run (running total) for most recent date
  measure: tests_run {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% elsif reporting_date._is_selected %}
            ${tests_performed}
          {% else %}
            CASE WHEN ${reporting_date} = ${max_italy_date.max_date} THEN ${tests_performed} ELSE NULL END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
    label: "Tests run"
    description: "Running total of tests run (IT: Tamponi), avail by region only"
    group_label: "Testing"
  }

  measure: tests_pp {
    type: number
    sql: 1000* ${tests_run}/NULLIF(${population}, 0) ;;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    label: "Tests run (per thousand)"
    group_label: "Testing"
    value_format_name: decimal_2
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }


  measure: new_tests {
    type: sum
    sql:  {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            NULL
          {% else %}
            CASE WHEN ${new_tests_performed} >=0 THEN ${new_tests_performed} ELSE 0 END
          {% endif %};;
    html: {% if italy_province.province_abbreviation._in_query or italy_province.province._in_query %}
            Metric only available at regional level
          {% else %}
            {{rendered_value}}
          {% endif %};;
    label: "New tests run"
    description: "Count of tests run by day (IT: Tamponi nuovi), avail by region only"
    group_label: "Testing"
    link: {
      label: "Data Source - Protezione Civile"
      url: "https://github.com/pcm-dpc/COVID-19"
      icon_url: "https://pngimage.net/wp-content/uploads/2018/06/repubblica-italiana-png-2.png"
    }
  }


  measure: max_date {
    sql: MAX(${reporting_date}) ;;
    type: date
    label: "Last Updated"
  }

  measure: population {
    type: number
    sql: COALESCE(${italy_province_stats.population}, ${italy_region_stats.population}) ;;
    label: "Population"
    value_format_name: decimal_0

  }

}


view: max_italy_date {
  derived_table: {
   sql: SELECT
    max(date) as max_date
  FROM
     `bigquery-public-data.covid19_italy.data_by_region`
  WHERE
    {% condition italy.reporting_date %} date(date) {% endcondition %} ;;
  }

  dimension: max_date {
    hidden: yes
    type: date
  }

}
