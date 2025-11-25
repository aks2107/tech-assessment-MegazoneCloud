# Secure and Scalable Multi-Tier VPC Foundation
This project uses Terraform to deploy a production-grade, 3-tier network architecture in AWS. It is designed for High Availability across two Availability Zones and implements network isolation.

## Architecture Diagram

```mermaid
graph TD
    User((User)) --> IGW[Internet Gateway]
    IGW --> LB[Load Balancer / Public Tier]
    
    subgraph VPC [AWS VPC 10.0.0.0/16]
        subgraph AZ1 [Availability Zone 1]
            Pub1[Public Subnet 1]
            App1[Private App Subnet 1]
            Data1[Private Data Subnet 1]
            NAT1[NAT Gateway]
            Bastion[Bastion Host]
        end
        
        subgraph AZ2 [Availability Zone 2]
            Pub2[Public Subnet 2]
            App2[Private App Subnet 2]
            Data2[Private Data Subnet 2]
            NAT2[NAT Gateway]
        end
    end

    %% Connections
    LB --> Pub1 & Pub2
    Bastion -.->|SSH Port 22| App1 & App2
    Pub1 --> NAT1
    Pub2 --> NAT2
    
    App1 --> Data1
    App2 --> Data2
    
    NAT1 --> IGW
    NAT2 --> IGW
```