# terraform-aws-infra

Production-ready AWS infrastructure provisioned with Terraform. Covers VPC, EC2, S3, and EKS using a modular structure.

## Architecture

```
                         ┌─────────────────────────────────────┐
                         │              AWS VPC                │
                         │          (10.0.0.0/16)              │
                         │                                     │
                         │  ┌──────────────┐ ┌──────────────┐  │
             Internet ───┼─►│ Public Subnet│ │ Public Subnet│  │
                         │  │  AZ-1        │ │  AZ-2        │  │
                         │  │  EC2 + IGW   │ │              │  │
                         │  └──────────────┘ └──────────────┘  │
                         │                                     │
                         │  ┌──────────────┐ ┌──────────────┐  │
                         │  │Private Subnet│ │Private Subnet│  │
                         │  │  AZ-1        │ │  AZ-2        │  │
                         │  │  EKS Nodes   │ │  EKS Nodes   │  │
                         │  └──────────────┘ └──────────────┘  │
                         └─────────────────────────────────────┘
                                         │
                              ┌──────────┴──────────┐
                              │         │           │
                           ┌──┴──┐   ┌──┴──┐    ┌───┴──┐
                           │ EC2 │   │ EKS │    │  S3  │
                           └─────┘   └─────┘    └──────┘
```

## Modules

| Module | Resources |
|--------|-----------|
| `modules/vpc` | VPC, public/private subnets, route tables, IGW, NAT gateway |
| `modules/ec2` | EC2 instance, security group, IAM role (SSM access) |
| `modules/s3` | S3 bucket with versioning, encryption, lifecycle policy |
| `modules/eks` | EKS cluster, node group, IAM roles, launch template |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- AWS account with permissions for EC2, EKS, S3, IAM, VPC

## Quick start

```bash
# 1. Clone the repo
git clone https://github.com/s-r-kashyap/terraform-aws-infra.git
cd terraform-aws-infra

# 2. Create your tfvars file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Initialise Terraform
terraform init

# 4. Preview changes
terraform plan

# 5. Apply
terraform apply
```

## What gets created

```
VPC
├── 2 public subnets  (EC2, load balancers)
├── 2 private subnets (EKS worker nodes)
├── Internet Gateway
├── Route tables
└── NAT Gateway (optional, set enable_nat_gateway = true)

EC2
├── t3.micro instance (Amazon Linux 2023)
├── Security group (SSH, HTTP, HTTPS)
├── IAM role with SSM Session Manager
└── Encrypted gp3 root volume

S3
├── Versioning enabled
├── Public access blocked
├── AES-256 encryption at rest
└── Lifecycle policy (delete old versions after 30 days)

EKS
├── Kubernetes 1.29 cluster
├── Managed node group (t3.medium)
├── Cluster logging (api, audit, authenticator)
├── Encrypted node volumes (gp3, 50GB)
└── IMDSv2 enforced on nodes
```

## Connect to EKS after apply

```bash
aws eks update-kubeconfig --region ap-south-1 --name <cluster-name>
kubectl get nodes
```

## CI/CD

The `.github/workflows/terraform.yml` pipeline runs on every PR:
- `terraform fmt` — checks formatting
- `terraform validate` — validates configuration
- `terraform plan` — posts plan output as a PR comment

Add these secrets to your GitHub repo settings:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Folder structure

```
terraform-aws-infra/
├── main.tf                        # Root module — calls all sub-modules
├── variables.tf                   # All input variables
├── outputs.tf                     # Key outputs (IDs, IPs, endpoints)
├── terraform.tfvars.example       # Example vars — copy to terraform.tfvars
├── .gitignore
├── .github/
│   └── workflows/
│       └── terraform.yml          # GitHub Actions CI pipeline
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── s3/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── eks/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Cost estimate (ap-south-1, dev config)

| Resource | Approx cost/month |
|----------|------------------|
| EC2 t3.micro | ~$8 |
| EKS cluster | ~$72 (control plane) |
| EKS nodes (2x t3.medium) | ~$60 |
| S3 (minimal usage) | ~$1 |
| NAT Gateway (if enabled) | ~$32 |

> Tip: Run `terraform destroy` when not using dev environments to avoid charges.

## Security highlights

- All S3 buckets: public access blocked + AES-256 encryption
- EC2: IMDSv2 enforced, SSM access instead of open SSH
- EKS nodes: encrypted volumes, IMDSv2 enforced
- Secrets never committed — use `terraform.tfvars` (gitignored)

---

## Author

Shashank R Kashyap — [LinkedIn](https://linkedin.com/in/shashank-r-kashyap-656480149) · DevOps Engineer
