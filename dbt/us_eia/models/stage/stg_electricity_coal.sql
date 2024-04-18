/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

with source_data as (
    select
        *,
        'electricity_state_profiles' as api_source
    from
        dez_project.raw.electricity_capability
    where
        period > 1999
        and producer_type_description = 'All sectors'
        and energy_source_description = 'Coal'
)

select * from source_data
