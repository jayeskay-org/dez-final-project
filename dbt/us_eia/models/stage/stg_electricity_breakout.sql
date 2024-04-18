/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

with source_data as (
    select
        *,
        regexp_substr(
            energy_source_description,
            '((Battery)|(Coal)|(Geothermal)|(Hydroelectric)|(Natural Gas)|(Nuclear)|(Other)|(Petroleum)|(Pumped Storage)|(Solar)|(Wind)|(Wood))'
        ) as energy_source_description_new,
        'electricity_state_profiles' as api_source
    from
        dez_project.raw.electricity_capability
    where
        period > 1999
        and energy_source_description != 'All'
)

select * from source_data
