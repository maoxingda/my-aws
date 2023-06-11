import os
import sys
import time
from datetime import datetime, timedelta
from pprint import pprint

import boto3

from util.corp_wechat import send_message


def find_snapshot(start_time, end_time):
    start_time = datetime.strptime(start_time, '%Y/%m/%d %H:%M') - timedelta(hours=8)
    end_time = datetime.strptime(end_time, '%Y/%m/%d %H:%M') - timedelta(hours=8)

    paginator = client.get_paginator('describe_cluster_snapshots')

    for page in paginator.paginate(ClusterIdentifier=cluster_id, StartTime=start_time, EndTime=end_time):
        for snapshot in page['Snapshots']:
            send_message(f"找到快照：{snapshot['SnapshotIdentifier']}")
            with open('snapshot.log', 'w') as f:
                f.write(snapshot['SnapshotIdentifier'])


def restore_table_from_cluster_snapshot(src_table_name, dst_table_name):
    # 集群在连续两次恢复快照操作之间必须等待集群状态更新为：Available
    start = datetime.now()

    while True:
        response = client.describe_clusters(ClusterIdentifier=cluster_id)

        cluster_status = response['Clusters'][0]['ClusterAvailabilityStatus']

        print(f'cluster status: {cluster_status}', f'elapsed: {int((datetime.now() - start).total_seconds())} 秒')

        if cluster_status == 'Available':
            break

        time.sleep(15)

    # 从集群快照恢复表
    response = client.restore_table_from_cluster_snapshot(
        ClusterIdentifier=cluster_id,
        SnapshotIdentifier=snapshot_id,
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
        response = client.describe_table_restore_status(
            ClusterIdentifier=cluster_id,
            TableRestoreRequestId=req_id,
        )

        status = response['TableRestoreStatusDetails'][0]['Status']

        print(src_table_name, dst_table_name, status, f'elapsed: {int((datetime.now() - start).total_seconds())} 秒')

        if status in ['SUCCEEDED', 'FAILED', 'CANCELED']:
            print(response)
            break

        time.sleep(15)


def restore_from_cluster_snapshot():
    response = client.describe_clusters(ClusterIdentifier=cluster_id)

    client.restore_from_cluster_snapshot(
        ClusterIdentifier=restore_cluster_id,
        SnapshotIdentifier=snapshot_id,
        SnapshotClusterIdentifier=cluster_id,
        ClusterSubnetGroupName=response['Clusters'][0]['ClusterSubnetGroupName'],
        ClusterParameterGroupName=response['Clusters'][0]['ClusterParameterGroups'][0]['ParameterGroupName'],
        VpcSecurityGroupIds=[response['Clusters'][0]['VpcSecurityGroups'][0]['VpcSecurityGroupId']],
    )

    client.get_waiter('cluster_available').wait(ClusterIdentifier=restore_cluster_id)

    send_message(f'从快照（{snapshot_id}）创建集群成功：https://cn-northwest-1.console.amazonaws.cn'
                 f'/redshiftv2/home?region=cn-northwest-1#cluster-details?cluster={restore_cluster_id.lower()}')


if __name__ == '__main__':
    client = boto3.client('redshift')
    cluster_id, dbname = ('bi-sandbox', 'beta') if os.getlogin() == 'root' else ('bi-prod-hc', 'prod')

    # 查找集群快照
    # find_snapshot('2023/06/10 08:00', '2023/06/10 09:00')
    # sys.exit(0)

    # with open('snapshot.log') as f:
    #     snapshot_id = f.read()
    #
    # local_datetime_from_snapshot_id = (datetime.strptime(snapshot_id[-19:], "%Y-%m-%d-%H-%M-%S") + timedelta(hours=8)).strftime('%Y%m%dT%H%M%S')
    # restore_cluster_id = f'{cluster_id}-snapshot-{local_datetime_from_snapshot_id}'

    # 基于已有集群快照创建新的集群
    # restore_from_cluster_snapshot()
    # sys.exit(0)

    # 删除集群
    # client.delete_cluster(ClusterIdentifier=restore_cluster_id, SkipFinalClusterSnapshot=True)
    # sys.exit(0)

    # 从集群快照恢复表
    # tables = [
    #     'dim.client_members',
    # ]
    #
    # for table in tables:
    #     restore_table_from_cluster_snapshot(
    #         src_table_name=f'{dbname}.{table}',
    #         dst_table_name=f'{dbname}.temp.{table.split(".")[1]}_{local_datetime_from_snapshot_id}',
    #     )
    # send_message(f'从集群快照（{snapshot_id}）恢复表完成')
