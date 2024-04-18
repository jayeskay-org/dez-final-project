/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

with stage_data as (
    select
        period as year,
        state_id as state,
        capability,
        capability_units
    from
        {{ ref('stg_electricity_coal') }}
    order by
        year,
        state
)

select * from stage_data
