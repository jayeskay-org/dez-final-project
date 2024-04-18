/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

with stage_data as (
    select
        period as year,
        state_description as state,
        energy_source_description_new as energy_source_description,
        capability,
        capability_units
    from
        {{ ref('stg_electricity_breakout') }}
    order by
        year,
        state,
        energy_source_description
)

select * from stage_data
