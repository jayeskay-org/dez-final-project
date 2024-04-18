# dez-final-project

Final project for Data Engineering Zoomcamp 2024 cohort.

## Objective

This project analyzes energy data from the United States Energy Information Administration ("US EIA"). Namely, the goal is to understand the capability of the US energy supply based upon its sources over the past ~20 years.

Preliminary analysis revealed that the most frequently used energy source is coal; thus, a review will be conducted analyzing the distribution of coal consumption across the US and determining the efficiency of respective states' usage.

## Technology

The following tools are used for this project:

- AWS
    - EC2
    - S3
    - IAM
- Terraform (IaC)
- Mage
- dbt
- Snowflake

## Processs

### Generation

Data is maintained by the US EIA and publicly available on its [website](https://www.eia.gov/). Namely, this raw data can be called via API, as outlined [here](https://www.eia.gov/opendata/).

### Ingestion

As mentioned, data is pulled via API, with varying degrees of URL specificity to obtain relevant data. For example,

```python
lvl0 = 'https://api.eia.gov/v2/'
lvl1 = f"{lvl0}electricity/"
lvl2 = f"{lvl1}state-electricity-profiles/"
lvl3 = f"{lvl2}capability/"
lvl4 = f"{lvl3}data/"
```

The ingestion process is handled by Mage, which makes use of: loaders, a transformer, and exporters.

### Storage

Resulting datasets are uploaded as partitioned .parquet files to S3:

- Coal: *coal/consumption_[year].parquet*
- Electricity: *electricity/capability_[year].parquet*

### Transformation

The only transformation performed within Mage is that of standardizing columns to snake case.

Additional transformations are done in dbt.

For coal consumption (see *dbt/us_eia/models/stage/stg_coal_consumption.sql*):

```sql
where
    period > 1999
    and regexp_like(location, '([A-Z]){2}', 'i')
    and location not in ('PR', 'DC', 'US')
    and sector_description not in ('Other Industrial', 'Commercial and Institutional', 'Coke Plants')
```

For electricity capability breakout (see *dbt/us_eia/models/stage/stg_electricity_breakout.sql*), there are 2 notable steps:

Firstly,

```sql
regexp_substr(
    energy_source_description,
    '((Battery)|(Coal)|(Geothermal)|(Hydroelectric)|(Natural Gas)|(Nuclear)|(Other)|(Petroleum)|(Pumped Storage)|(Solar)|(Wind)|(Wood))'
) as energy_source_description_new,
```

Secondly,

```sql
where
    period > 1999
    and energy_source_description != 'All'
```

For electricity capability specific to coal (see *dbt/us_eia/models/stage/stg_electricity_coal.sql*):

```sql
where
    period > 1999
    and producer_type_description = 'All sectors'
    and energy_source_description = 'Coal'
```

Simple aggregations are also performed in models outlined in *final/*, as needed.

Lastly, in comparing consumption versus capability, the output is an efficiency ratio of **normalized capability to normalized consumption**, such that a state is capable of generating 1 unit of electricity per *x* units of consumed coal. The higher, the better.

### Destination

Raw data from S3 is pulled via Snowflake into the `raw` schema.

dbt models result in the creation of tables or views housed in Snowflake, as follows:

- `stage`
    - stg_coal_consumption
    - stg_electricity_breakout
    - stg_electricity_coal
- `final`
    - coal_consumption
    - electricity_breakout
    - electricity_coal
    - coal_consumption_versus_capability

## Analysis

The average electricity capability across all energy sources is calculated in **Metabase**, not SQL. The same applies when narrowed to coal.

Efficiency ratio is calculated based upon normalized coal consumption and normalized electricity capability; **this is performed in SQL**.

## Dashboard

See on Metabase: https://jayeskay.metabaseapp.com/public/dashboard/84653eff-c8e3-4368-ae50-1b5326c91494
