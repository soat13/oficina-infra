aws_region = "us-east-1"

cluster_name = "fiap-eks-cluster-hom"

kubernetes_version = "1.33"

vpc_cidr = "10.0.0.0/16"

availability_zones_count = 2

kms_deletion_window = 7

cluster_endpoint_public_access = true

cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]


enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

log_retention_days = 7

node_instance_types = ["t3.medium"]

node_ami_type = "AL2023_x86_64_STANDARD"

node_capacity_type = "ON_DEMAND"

node_disk_size = 20

node_desired_size = 2

node_max_size = 4

node_min_size = 1

node_max_unavailable = 1

node_labels = {
  Environment = "hom"
  ManagedBy   = "terraform"
  Workload    = "general"
}

existing_cluster_role_arn = "arn:aws:iam::409721164017:role/LabRole"

existing_node_role_arn = "arn:aws:iam::409721164017:role/LabRole"

auth_lambda_invoke_arn   = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:409721164017:function:IdentityFunction/invocations"
existing_lambda_role_arn = "arn:aws:iam::409721164017:role/LabRole"

lambda_zip_path = "../bin/authorizer.zip"

attach_iam_policies = false

create_iam_policies = false

sqs_queues = {
  "repairorder-diagnostics-finished"              = {}
  "repairorder-canceled"                          = {}
  "estimate-created"                              = {}
  "estimate-approved"                             = {}
  "estimate-rejected"                             = {}
  "estimate-canceled"                             = {}
  "product-stock-insufficient-detected"           = {}
  "estimate-product-stock-reduction-confirmed"    = {}
  "repairorder-product-stock-reduction-confirmed" = {}
  "payment-request"                               = {}
  "payment-link-request"                          = {}
  "payment-status-changed"                        = { fifo_queue = true, create_dlq = false }
}

sns_topics = {
  "payment-status-changed" = {
    fifo_topic  = true
    subscribers = ["payment-status-changed", "payment-link-request"]
  }
  "product-stock-reduction-confirmed" = {
    subscribers = [
      "estimate-product-stock-reduction-confirmed",
      "repairorder-product-stock-reduction-confirmed",
    ]
  }
}

dynamodb_tables = {
  "users" = {
    hash_key = "id"
    attributes = [
      { name = "id", type = "S" },
      { name = "document", type = "S" },
      { name = "email", type = "S" }
    ]
    global_secondary_indexes = [
      {
        name            = "document-index"
        hash_key        = "document"
        projection_type = "ALL"
      },
      {
        name            = "email-index"
        hash_key        = "email"
        projection_type = "ALL"
      }
    ]
  }
  "payments" = {
    hash_key  = "pk"
    range_key = "sk"
    attributes = [
      { name = "pk", type = "S" },
      { name = "sk", type = "S" },
      { name = "gsi1pk", type = "S" },
      { name = "gsi1sk", type = "S" }
    ]
    global_secondary_indexes = [
      {
        name            = "gsi1"
        hash_key        = "gsi1pk"
        range_key       = "gsi1sk"
        projection_type = "ALL"
      }
    ]
  }
}

tags = {
  Environment = "hom"
  ManagedBy   = "terraform"
  Project     = "oficina"
}
