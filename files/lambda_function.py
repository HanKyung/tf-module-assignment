import pymysql
import os

def lambda_handler(event, context):
    rds_host = os.environ['RDS_HOST']
    name = os.environ['RDS_USER']
    password = os.environ['RDS_PASSWORD']
    db_name = os.environ['RDS_DB']

    connection = pymysql.connect(host=rds_host, user=name, passwd=password, db=db_name)

    with open('./init.sql', 'r') as file:
        sql = file.read()
    
    with connection.cursor() as cursor:
        cursor.execute(sql)
    
    connection.commit()
    connection.close()

    return {
        'statusCode': 200,
        'body': 'Script executed successfully!'
    }
