with coal_consumption_max as (
    select
        year,
        state,
        consumption,
        max(consumption) over (
            partition by
                year
        ) as consumption_max,
        
    from
        dez_project.final.coal_consumption
),

coal_consumption_normalized as (
    select
        year,
        state,
        consumption / consumption_max as consumption_normalized
    from
        coal_consumption_max
),

electricity_coal_capability_max as (
    select
        year,
        state,
        capability,
        max(capability) over (
            partition by
                year
        ) as capability_max
    from
        electricity_coal
),

electricity_coal_capability_normalized as (
    select
        year,
        state,
        capability / capability_max as capability_normalized
    from
        electricity_coal_capability_max
),

averaged as (
    select
        coal.state,
        avg(coal.consumption_normalized) as con_norm_avg,
        avg(elec.capability_normalized) as cap_norm_avg
    from
        coal_consumption_normalized coal
        inner join electricity_coal_capability_normalized elec on
            coal.year = elec.year
            and coal.state = elec.state
    group by
        coal.state
)

select
    state,
    cap_norm_avg / con_norm_avg as capability_to_consumption
from
    averaged
