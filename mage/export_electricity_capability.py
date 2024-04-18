from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.s3 import S3
from pandas import DataFrame
from os import path

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

BUCKET = 'dez2024-project-data-lake'
PREFIX = 'electricity/capability'

@data_exporter
def export_data_to_s3(df: DataFrame, **kwargs) -> None:
    """
    Template for exporting data to a S3 bucket.
    Specify your configuration settings in 'io_config.yaml'.

    Docs: https://docs.mage.ai/design/data-loading#s3
    """
    config_path = path.join(get_repo_path(), 'io_config.yaml')
    config_profile = 'default'

    for year in df['period'].unique():
        df_partitioned = df[df['period'] == year]

        S3.with_config(ConfigFileLoader(config_path, config_profile)).export(
            data=df_partitioned,
            bucket_name=BUCKET,
            object_key=f"{PREFIX}_{year}.parquet"
        )
