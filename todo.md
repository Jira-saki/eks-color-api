# EKS Color API — Project Flow (Updated 2026-02-27)

## ✅ Completed (Phase 1 & 2)

- FastAPI Application — functional API in `app/main.py` with health checks.
- Dockerization — multi-stage `Dockerfile` optimized for production.
- Modular Infrastructure Design — clean separation between `environments/dev` and `modules/`.
- VPC Module (Hardened) — public/private subnets with NAT Gateway and EKS-required tagging.
- VPC Wiring — successfully exposed `vpc_id` and `subnet_ids` via `outputs.tf`.
- EKS Module (Secure) — configured with Bottlerocket OS, IRSA (OIDC), and KMS encryption.
- Infrastructure Validation — verified successful terraform plan with 58 resources to add.
- Documentation — professional English `README.md` with architecture diagrams.

## 🔄 Next Steps (Phase 2.5 & 3)

1. 🛠️ **Refactor Typo:** Change `herdened` to `hardened` in `dev/main.tf` **(Must do before Apply)**
2. 📦 **Create ECR Module:** Develop `infra/modules/ecr` to store our images.
3. 🔗 **Wiring:** Connect ECR module into `environments/dev/main.tf`.
4. 🚀 **Execution:** Run `terraform apply` (This will change the Audit Log above to [x]).
5. AWS LB Controller Setup — install the controller (via Helm) to enable ALB Ingress functionality.
6. K8s Manifests Development — create `k8s/` manifests (Deployment, Service, Ingress).
7. Application Deployment — deploy FastAPI to EKS and verify pod status and logs.
8. Advanced K8s Features — implement HPA, Resource Quotas, and liveness/readiness probes.
9. Final Testing — end-to-end test via the Public ALB URL.

## 💰 Cost Estimate & Monitoring

| Component           | Estimated Cost (Daily) | Notes                               |
|---------------------|:----------------------:|-------------------------------------|
| EKS Control Plane   | ~$2.40                 | $0.10 per hour                      |
| NAT Gateway         | ~$1.08                 | Hourly charge + data processing     |
| EC2 Nodes (Spot)    | ~$1.00 - $1.50         | 2× t3.medium (highly variable)      |
| **Total**           | **~$4.50 - $5.00**     | Excluding ECR and Data Transfer     |

> **Pro Tip:** Using Spot Instances and Bottlerocket helped us shave off about 30‑40 % of the usual on‑demand cost!

## 🛡️ Security Audit Log [Current Progress]

- [ ] Network: No EKS nodes in Public Subnets.
- [ ] Compute: Read-only root filesystem via Bottlerocket.
- [ ] Data: Envelope encryption for Secrets enabled via AWS KMS.
- [ ] Identity: OIDC enabled for IRSA (Pod-level IAM roles).
