import boto3


def find_db_instance_by_addr(*, server_address):
    """
    查找数据库实例通过数据库地址
    :param server_address: 数据库地址
    :return: None
    """
    di_paginator = rds_client.get_paginator('describe_db_instances')

    for db_instances in di_paginator.paginate():
        for instance in db_instances['DBInstances']:
            if 'Endpoint' in instance and server_address in instance['Endpoint']['Address']:
                print(instance['DBInstanceIdentifier'])


if __name__ == '__main__':
    rds_client = boto3.client('rds')

    find_db_instance_by_addr(server_address='sandbox-common-planet-mysql.choxzj9zxm2u.rds.cn-northwest-1.amazonaws.com.cn')
