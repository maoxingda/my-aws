import time
from datetime import datetime, timedelta

import boto3


def restore_table_from_cluster_snapshot(
        cluster_identifier,
        snapshot_identifier,
        src_table_name,
        dst_table_name,
):
    # 集群在连续两次恢复快照操作之间必须等待集群状态更新为：Available
    start = datetime.now()

    response = redshift_client.describe_clusters(
        ClusterIdentifier='bi-prod-hc',
    )

    cluster_status = response['Clusters'][0]['ClusterAvailabilityStatus']

    print(f'cluster status: {cluster_status}', f'elapsed: {int((datetime.now() - start).total_seconds())} 秒')

    while cluster_status != 'Available':
        time.sleep(15)

        response = redshift_client.describe_clusters(
            ClusterIdentifier='bi-prod-hc',
        )

        cluster_status = response['Clusters'][0]['ClusterAvailabilityStatus']

        print(f'cluster status: {cluster_status}', f'elapsed: {int((datetime.now() - start).total_seconds())} 秒')

    # 从集群快照恢复表
    response = redshift_client.restore_table_from_cluster_snapshot(
        ClusterIdentifier=cluster_identifier,
        SnapshotIdentifier=snapshot_identifier,
        SourceDatabaseName=src_table_name.split('.')[0],
        SourceSchemaName=src_table_name.split('.')[1],
        SourceTableName=src_table_name.split('.')[2],
        TargetDatabaseName=dst_table_name.split('.')[0],
        TargetSchemaName=dst_table_name.split('.')[1],
        NewTableName=dst_table_name.split(".")[2],
    )
    req_id = response['TableRestoreStatus']['TableRestoreRequestId']

    start = datetime.now()
    while (datetime.now() - start).total_seconds() / 60 < 15:
        response = redshift_client.describe_table_restore_status(
            ClusterIdentifier=cluster_identifier,
            TableRestoreRequestId=req_id,
        )

        status = response['TableRestoreStatusDetails'][0]['Status']

        print(src_table_name, dst_table_name, status, f'elapsed: {int((datetime.now() - start).total_seconds())} 秒')

        if status in ['SUCCEEDED', 'FAILED', 'CANCELED']:
            print(response)
            break

        time.sleep(15)


if __name__ == '__main__':
    redshift_client = boto3.client('redshift')

    tables = [
        # 'ods.db_id_mapping_contract_party_id_mapping',
        #     'ods.db_id_mapping_contract_party_member_id_mapping',
        # 'ods.db_id_mapping_corp_id_mapping',
        #     'ods.db_id_mapping_corp_order_user_id_mapping',
        # 'ods.db_id_mapping_physical_card_pay_order_id_mapping',
        #     'ods.db_id_mapping_qrpay_order_id_mapping',
        # 'ods.db_id_mapping_restaurant_id_mapping',
        # 'ods.db_id_mapping_scanpay_order_id_mapping',
        # 'ods.db_id_mapping_special_account_id_mapping',
        # 'ods.db_id_mapping_user_id_mapping',

        # 'ods.id_mapping_contract_party_id_mapping',
        # 'ods.id_mapping_contract_party_member_id_mapping',
        # 'ods.id_mapping_corp_id_mapping',
        # 'ods.id_mapping_corp_order_user_id_mapping',
        # 'ods.id_mapping_physical_card_pay_order_id_mapping',
        # 'ods.id_mapping_qrpay_order_id_mapping',
        # 'ods.id_mapping_restaurant_id_mapping',
        # 'ods.id_mapping_scanpay_order_id_mapping',
        # 'ods.id_mapping_special_account_id_mapping',
        'ods.id_mapping_user_id_mapping',
    ]

    snapshot_identifier = 'rs:bi-prod-hc-2023-06-05-20-28-50'
    snapshot_created_timestamp = datetime.strptime(snapshot_identifier[14:], '%Y-%m-%d-%H-%M-%S') + timedelta(hours=8)
    suffix = snapshot_created_timestamp.strftime('%Y%m%dT%H%M')

    for table in tables:
        restore_table_from_cluster_snapshot(
            cluster_identifier='bi-prod-hc',
            snapshot_identifier=snapshot_identifier,
            src_table_name=f'prod.{table}',
            dst_table_name=f'prod.temp.{table.split(".")[1]}_{suffix}',
        )
