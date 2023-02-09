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

import boto3


def find_task_by_table(*, table_name):
    """
    查找同步某个表的任务
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


def find_endpoint_by_addr(*, server_address):
    """
    找到端点通过数据库地址
    :param server_address: 数据库地址
    :return: None
    """
    de_paginator = dms_client.get_paginator('describe_endpoints')
    for endpoints in de_paginator.paginate():
        for endpoint in endpoints['Endpoints']:
            if 'ServerName' in endpoint and server_address in endpoint['ServerName']:
                print(endpoint['EndpointArn'])


def find_tasks_by_source_endpoint(*, endpoint_arn):
    """
    查找源端点为endpoint_arn的任务
    :param endpoint_arn: 源端点ID
    :return: None
    """
    drt_paginator = dms_client.get_paginator('describe_replication_tasks')
    for tasks in drt_paginator.paginate():
        for task in tasks['ReplicationTasks']:
            if endpoint_arn in task['SourceEndpointArn']:
                print(task['ReplicationTaskIdentifier'])


if __name__ == '__main__':
    dms_client = boto3.client('dms')

    pass
