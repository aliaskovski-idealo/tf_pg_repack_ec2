# https://diagrams.mingrammer.com/docs/nodes/aws

from diagrams import Cluster, Diagram
from diagrams.aws.compute import LambdaFunction
from diagrams.aws.database import RDS
from diagrams.aws.security import SecretsManager
from diagrams.aws.management import Cloudwatch, CloudwatchAlarm
from diagrams.aws.integration import SimpleNotificationServiceSnsTopic
from diagrams.saas.chat import Teams
import os

# Generate the diagram
print("\nGenerating Diagram...")
with Diagram("Architecture", show=False):

    with Cluster("aws"):

        with Cluster("account"):
            secret_manager = SecretsManager("secret manager")
            cloudwatch = Cloudwatch("cloudwatch")
            cw_alarm = CloudwatchAlarm("alarm")
            ms_teams = Teams("ms_teams")
            with Cluster("vpc"):
                with Cluster("private subnet"):
                    lambda_function = LambdaFunction("password rotation")
                    postgres_cluster = RDS("Postgres")

    lambda_function >> secret_manager
    lambda_function >> postgres_cluster
    postgres_cluster >> secret_manager
    postgres_cluster >> cloudwatch >> cw_alarm >> ms_teams

print("Succesfully generated diagram in path: "+os.getcwd()+"\n")