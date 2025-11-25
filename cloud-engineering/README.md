# Secure and Scalable Multi-Tier VPC Foundation
This project uses Terraform to deploy a production-grade, 3-tier network architecture (Web, App, Data) in AWS. Terraform is used to define the Infrastructure as Code (IaC) and is designed for High Availability across two Availability Zones and implements network isolation.

## Architecture Diagram
```mermaid
graph TB
    subgraph "AWS Cloud - Region: us-east-1"
        subgraph "Production VPC - 10.0.0.0/16"
            IGW[Internet Gateway<br/>Gateway to Internet]
            
            subgraph "Availability Zone 1 - us-east-1a"
                subgraph "TIER 1: Public Subnet 1<br/>10.0.0.0/24<br/>ACL: Public NACL"
                    NAT1[NAT Gateway 1<br/>Elastic IP Allocated]
                    BASTION[Bastion Host<br/>Amazon Linux 2023<br/>t2.micro]
                end
                
                subgraph "TIER 2: Private App Subnet 1<br/>10.0.2.0/24<br/>ACL: Private NACL"
                    APP1[Application Tier 1<br/>Future App Servers]
                end
                
                subgraph "TIER 3: Private Data Subnet 1<br/>10.0.4.0/24<br/>ACL: Private NACL"
                    DB1[Data Tier 1<br/>Future RDS Instance]
                end
            end
            
            subgraph "Availability Zone 2 - us-east-1b"
                subgraph "TIER 1: Public Subnet 2<br/>10.0.1.0/24<br/>ACL: Public NACL"
                    NAT2[NAT Gateway 2<br/>Elastic IP Allocated]
                    ALB_NODE[Load Balancer Node]
                end
                
                subgraph "TIER 2: Private App Subnet 2<br/>10.0.3.0/24<br/>ACL: Private NACL"
                    APP2[Application Tier 2<br/>Future App Servers]
                end
                
                subgraph "TIER 3: Private Data Subnet 2<br/>10.0.5.0/24<br/>ACL: Private NACL"
                    DB2[Data Tier 2<br/>Future RDS Standby]
                end
            end
        end
    end
    
    %% Traffic Flows
    INTERNET[Internet] ==>|HTTPS 443| IGW
    INTERNET ==>|SSH 22 (Restricted)| IGW
    
    IGW -->|Route Table: Public| BASTION
    IGW -->|Route Table: Public| ALB_NODE
    IGW -->|Route Table: Public| NAT1
    IGW -->|Route Table: Public| NAT2
    
    %% Bastion Access
    BASTION -.->|SSH 22| APP1
    BASTION -.->|SSH 22| APP2
    BASTION -.->|SSH 22| DB1
    BASTION -.->|SSH 22| DB2
    
    %% Application Flow
    ALB_NODE -.->|HTTPS 443| APP1
    ALB_NODE -.->|HTTPS 443| APP2
    
    APP1 -.->|MySQL 3306| DB1
    APP2 -.->|MySQL 3306| DB2
    
    %% Updates Flow (Outbound)
    APP1 -->|Route Table: Private| NAT1
    APP2 -->|Route Table: Private| NAT2
    
    NAT1 --> IGW
    NAT2 --> IGW
    
    %% Styles
    classDef public fill:#E1F5FE,stroke:#0277BD,stroke-width:2px,color:#000
    classDef private fill:#FFF3E0,stroke:#EF6C00,stroke-width:2px,color:#000
    classDef data fill:#E8EAF6,stroke:#283593,stroke-width:2px,color:#000
    classDef security fill:#FCE4EC,stroke:#C2185B,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    
    class BASTION,NAT1,NAT2,ALB_NODE public
    class APP1,APP2 private
    class DB1,DB2 data
```

Implemented using: https://www.mermaidchart.com/

## Security Configurations

1. The VPC is divided into three distinct tiers:

- Public Tier: Hosts the Bastion and NAT Gateways. It has a route to the Internet Gateway.

- Private App Tier: Hosts app logic. It has no direct route to the internet and it uses NAT Gateways for outbound updates.

- Private Data Tier: Hosts databases. It is completely isolated and accepts traffic only from the App Tier.

2. Security Groups

- Bastion SG: Allows SSH only from specific admin IP. (User needs to change to their IP for it to work)

- App SG: Refuses all traffic unless it is from the Load Balancer SG or Bastion SG.

- Data SG: Refuses all traffic unless it is from the App SG.

3. Network ACLs

- Public NACL: Allows internet traffic on SSH.

- Private NACL: Restricts ingress traffic. It only allows traffic coming from VPC CIDR block (10.0.0.0/16). This allows for no external internet traffic that affects the App or Data subnets.

### Contact Information
- Email: abinswar7@gmail.com
- LinkedIn: https://www.linkedin.com/in/aveinn-swar/