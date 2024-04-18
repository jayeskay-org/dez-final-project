import requests
import time
import pandas as pd
from typing import Dict
from pprint import pprint
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


def get_metadata(url, params) -> None:
    response = requests.get(url=url, params=params)
    response.raise_for_status()

    metadata = response.json()['response']

    return metadata


def get_max_results(url: str, params: Dict[str, str]):
    x = params
    x['length'] = 1
    
    response = requests.get(url=url, params=x)
    response.raise_for_status()

    response_dict = response.json()
    max_records = int(response_dict['response']['total'])

    return max_records


def batch_download_api(url: str, params: Dict[str, str], offset=0, length=500):
    x = params
    x['offset'] = offset
    x['length'] = length

    response = requests.get(url=url, params=x, stream=True)
    response.raise_for_status()

    response_dict = response.json()
    response_data = response_dict['response']['data']

    return response_data


@data_loader
def load_data_from_api(*args, **kwargs):
    """
    Template for loading data from API
    """
    lvl0 = 'https://api.eia.gov/v2/'
    lvl1 = f"{lvl0}coal/"
    lvl2 = f"{lvl1}consumption-and-quality/"
    lvl3 = f"{lvl2}data/"

    dt = 1998

    params = {
        'api_key': 'DhEKpp7XL0kxBySag583hXd1ypZw9zLofpTbuGq2',
        'frequency': 'annual',
        'data[0]': 'consumption',
        'start': dt,
        'end': dt,
        'sort[0][column]': 'period',
        'sort[0][direction]': 'asc'
    }

    final = []

    while dt < 2023:
        start = time.time()

        max_records = get_max_results(url=lvl3, params=params)

        record_count = 0
        records = []

        while record_count < max_records:
            records += batch_download_api(
                url=lvl3,
                params=params,
                offset=record_count
            )

            record_count = len(records)

            print(f"year={dt}; results={record_count}; max_records={max_records}")

        end = time.time()

        print(f"duration: {round(end - start, 2)} seconds")

        final += records

        dt += 1

        params['start'], params['end'] = dt, dt

    return pd.DataFrame(final)


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
