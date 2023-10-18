import boto3

# Initialize AWS clients
ec2_client = boto3.client('ec2')
cloudwatch_client = boto3.client('cloudwatch')

# Constants
INSTANCE_ID = 'i-0abcd1234efgh5678'
ALARM_THRESHOLD = 80.0  # Alarm threshold of 80% CPU utilization

def lambda_handler(event, context):
    if not is_resource_healthy():
        trigger_ssm_remediation()

def is_resource_healthy():
    # Check if the EC2 instance is running
    response = ec2_client.describe_instances(InstanceIds=[INSTANCE_ID])
    state = response['Reservations'][0]['Instances'][0]['State']['Name']

    if state != 'running':
        return False

    # Check the EC2 instance's CPU utilization over the past 5 minutes
    metric = cloudwatch_client.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'cpuUtilization',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/EC2',
                        'MetricName': 'CPUUtilization',
                        'Dimensions': [{'Name': 'InstanceId', 'Value': INSTANCE_ID}]
                    },
                    'Period': 300,  # 5 minutes
                    'Stat': 'Average'
                },
                'ReturnData': True
            }
        ],
        StartTime='2023-10-01T00:00:00Z',  # Adjust this dynamically to your desired timeframe
        EndTime='2023-10-02T00:00:00Z'     # Adjust this dynamically as well
    )

    # Ensure there are data points before checking the value
    if metric['MetricDataResults'][0]['Values']:
        avg_cpu_utilization = metric['MetricDataResults'][0]['Values'][0]

        if avg_cpu_utilization > ALARM_THRESHOLD:
            return False

    return True

def trigger_ssm_remediation():
    ssm_client = boto3.client('ssm')
    response = ssm_client.start_automation_execution(
        DocumentName='YourSSMDocumentName',
        Parameters={
            'yourParameterKey': ['yourParameterValue']
        }
    )