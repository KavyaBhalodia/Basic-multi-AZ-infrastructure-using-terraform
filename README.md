# Basic-multi-AZ-infrastructure-using-terraform
 Infrastructure as code: Multi-AZ AWS setup with EC2, Load Balancer, VPC, and S3 using Terraform.
<img width="468" alt="image" src="https://github.com/KavyaBhalodia/Basic-multi-AZ-infrastructure-using-terraform/assets/87963890/bd5ff864-9e33-4610-bf0f-456f2d73f200">
1. Create a VPC Resource: We start by creating a Virtual Private Cloud (VPC) to isolate and control our AWS resources, providing a secure and isolated network environment.

2. Create 2 Subnets in ap-south1a and ap-south1b Region: Subnets allow us to segment our VPC into smaller, isolated networks. Creating subnets in different Availability Zones (ap-south1a and ap-south1b) ensures high availability and fault tolerance.

3. Create an Internet Gateway for Connection: An Internet Gateway enables communication between the VPC and the internet. This step is necessary for resources within our VPC to access external services or for external traffic to reach our VPC.

4. Create a Route Table for Routing Traffic to Target Groups: Route tables determine how network traffic is directed within the VPC. By creating a custom route table, we can specify how traffic is routed, such as directing it to target groups for load balancing.

5. Associate Route Table with Subnets: To control the routing behavior within our VPC, we associate the route table created in step 4 with the relevant subnets. This ensures traffic within these subnets follows the routing rules.

6. Create a Security Group for Allowing HTTP Traffic: Security groups act as virtual firewalls for EC2 instances. Creating a security group to allow HTTP traffic (port 80) is essential to permit web traffic to reach our resources.

7. Create Bucket A: Creating an S3 bucket allows us to store and manage data securely in AWS. It can be used for various purposes like static website hosting or data storage.

8. Create Load Balancer with Target Group and AWS Load Balancer Listener: A load balancer distributes incoming traffic across multiple instances to ensure high availability and fault tolerance. We create a load balancer, configure it with a target group (for routing requests to specific instances), and set up a listener to handle incoming traffic.

