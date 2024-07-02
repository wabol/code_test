import boto3
import logging
import os

# Initiallize client
ec2_client = boto3.client('ec2')
sns_clinet = boto3.client('sns')

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Lambda function
def lambda_handler(event, context):
    instance_id = os.environ['EC2_INSTANCE_ID']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    # Restart instance
    try:
        ec2_client.reboot_instances(InstanceIds=[instance_id])
        logger.info(f'Successfully restarted EC2 Instance:{instance_id}')

        # Send notification to SNS
        message =f'EC2 instance {instance_id} has been restart due to Sumo Logic alert.'
        sns_clinet.publish(
            TopicArn = sns_topic_arn,
            Message = message,
            Subject = 'EC2 Instance Restart Notification'
        )
        logger.info('Notification sent to SNS topic')

    except Exception as e:
        logger.error(f'Error restaring EC2 instance: {str(e)}')
        raise

    return {
        'statusCode': 200,
        'boday': 'EC2 instance restart initiated and notifications sent'

    }
    