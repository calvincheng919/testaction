connection: "@{CONNECTION_NAME}"

include: "/explores/*.explore.lkml"
include: "/dashboards/*.dashboard.lookml"

#map layers
include: "/assets/map_layers.lkml"

############ Caching Logic ############

persist_with: covid_data

### PDT Timeframes

datagroup: covid_data {
  max_cache_age: "12 hours"
  sql_trigger:
    SELECT min(max_date) as max_date
    FROM
    (
      SELECT max(cast(date as date)) as max_date FROM `bigquery-public-data.covid19_nyt.us_counties`
      UNION ALL
      SELECT max(cast(date as date)) as max_date FROM `bigquery-public-data.covid19_open_data.compatibility_view`
    ) a
  ;;
}
