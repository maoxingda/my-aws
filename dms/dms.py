"""
日常常用小工具
PaginatorName = [
    "describe_certificates",
    "describe_connections",
    "describe_endpoint_types",
    "describe_endpoints",
    "describe_event_subscriptions",
    "describe_events",
    "describe_orderable_replication_instances",
    "describe_replication_instances",
    "describe_replication_subnet_groups",
    "describe_replication_task_assessment_results",
    "describe_replication_tasks",
    "describe_schemas",
    "describe_table_statistics",
]
"""
import sys

import boto3
# from util.format import print


def find_task_by_table(table_name):
    """
    查找同步某个表的所有任务
    :param table_name: 表名称
    :return: None
    """
    drt_paginator = dms_client.get_paginator('describe_replication_tasks')
    for tasks in drt_paginator.paginate():
        for task in tasks['ReplicationTasks']:
            dts_paginator = dms_client.get_paginator('describe_table_statistics')
            for stats in dts_paginator.paginate(ReplicationTaskArn=task['ReplicationTaskArn']):
                for stat in stats['TableStatistics']:
                    if table_name in stat['TableName']:
                        print(task['ReplicationTaskIdentifier'])


if __name__ == '__main__':
    dms_client = boto3.client('dms')

    find_task_by_table('ali_provider_conf')

