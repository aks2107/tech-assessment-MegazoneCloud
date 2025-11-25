# Secure and Scalable Multi-Tier VPC Foundation
This project uses Terraform to deploy a production-grade, 3-tier network architecture (Web, App, Data) in AWS. Terraform is used to define the Infrastructure as Code (IaC) and is designed for High Availability across two Availability Zones and implements network isolation.

## Architecture Diagram
```mermaid
graph TB
    %% --- AZ 1 ---
    subgraph "Availability Zone 1 (us-east-1a)"
        direction TB
        subgraph "Public Subnet 1 (10.0.0.0/24)"
            NAT1[NAT Gateway 1]
            BASTION[Bastion Host]
        end
        
        subgraph "App Subnet 1 (10.0.2.0/24)"
            APP1[App Tier 1]
        end
        
        subgraph "Data Subnet 1 (10.0.4.0/24)"
            DB1[Data Tier 1]
        end
    end
    
    %% --- AZ 2 ---
    subgraph "Availability Zone 2 (us-east-1b)"
        direction TB
        subgraph "Public Subnet 2 (10.0.1.0/24)"
            NAT2[NAT Gateway 2]
            ALB_NODE[Load Balancer]
        end
        
        subgraph "App Subnet 2 (10.0.3.0/24)"
            APP2[App Tier 2]
        end
        
        subgraph "Data Subnet 2 (10.0.5.0/24)"
            DB2[Data Tier 2]
        end
    end

    %% --- External ---
    INTERNET((Internet)) ==>|HTTPS 443| IGW[Internet Gateway]
    IGW --> NAT1 & NAT2
    IGW --> BASTION & ALB_NODE

    %% --- Internal Traffic ---
    BASTION -.->|SSH 22| APP1 & APP2 & DB1 & DB2
    ALB_NODE -.->|HTTPS 443| APP1 & APP2
    APP1 & APP2 -.->|MySQL 3306| DB1 & DB2

    %% --- Outbound Updates ---
    APP1 & APP2 -->|Updates| NAT1 & NAT2

    %% --- Styling ---
    classDef public fill:#E1F5FE,stroke:#0277BD,stroke-width:2px,color:#000
    classDef private fill:#FFF3E0,stroke:#EF6C00,stroke-width:2px,color:#000
    classDef data fill:#E8EAF6,stroke:#283593,stroke-width:2px,color:#000
    
    class BASTION,NAT1,NAT2,ALB_NODE,IGW public
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