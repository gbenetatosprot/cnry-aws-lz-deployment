#----------------------------------------------------------------------------------------------------------------------
# FAILOVER IAM ROLE AND PROFILE CREATION
#----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "hapolicy" {
  name        = "hapalo"
  path        = "/"
  description = "hapalo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeInstances",
          "ec2:DetachNetworkInterface",
          "ec2:AttachNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "hapalo"
  assume_role_policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
       },
      ]
    })
  }
  
  
  resource "aws_iam_policy_attachment" "ec2_policy_role" {
    name                                    = "ec2_attachment"
    roles                                   = [aws_iam_role.ec2_role.name]
    policy_arn                              = aws_iam_policy.hapolicy.arn
   }
   
  resource "aws_iam_instance_profile" "ec2_profile" {
    name                                    = "ec2_profile"
    role                                    = aws_iam_role.ec2_role.name
   }