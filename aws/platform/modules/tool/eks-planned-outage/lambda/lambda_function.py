import boto3

autoscaling = boto3.client("autoscaling")

def lambda_handler(event, context):
    auto_scaling_group_name = event["AutoScalingGroupName"]
    max_size         = event["MaxSize"]
    min_size         = event["MinSize"]
    desired_capacity = event["DesiredCapacity"]

    autoscaling.update_auto_scaling_group(
        AutoScalingGroupName = auto_scaling_group_name,
        MinSize = int(min_size),
        MaxSize = int(max_size),
        DesiredCapacity = int(desired_capacity))
    return {
        'statusCode': 200
    }
