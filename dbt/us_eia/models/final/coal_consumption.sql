with stage_data as (
    select
        period as year,
        location as state,
        sum(consumption) as consumption,
        consumption_units
    from
        {{ ref('stg_coal_consumption') }}
    group by
        year,
        state,
        consumption_units
)

select * from stage_data
