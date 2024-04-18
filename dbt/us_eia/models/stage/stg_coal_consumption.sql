/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

with source_data as (
    select
        period,
        location,
        state_description,
        sector,
        sector_description,
        sum(consumption) as consumption,
        consumption_units,
        'coal_state_consumption' as api_source
    from
        dez_project.raw.coal_consumption
    where
        period > 1999
        and regexp_like(location, '([A-Z]){2}', 'i')
        and location not in ('PR', 'DC', 'US')
        and sector_description not in ('Other Industrial', 'Commercial and Institutional', 'Coke Plants')
    group by
        period,
        location,
        state_description,
        sector,
        sector_description,
        consumption_units,
        api_source
)

select * from source_data
