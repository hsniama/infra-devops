# infra-devops (Terraform + GitHub Actions + OIDC)

Este repositorio aprovisiona la infraestructura requerida para la evaluación de DevOps:
- Azure Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) con 2 nodos
- Red (VNet/Subnet)
- Permisos AcrPull para la identidad kubelet de AKS
- Estado remoto de Terraform almacenado en Azure Storage (autenticación con Azure AD)

## Entornos
- **DEV**: cualquier push a ramas `dev/**` despliega en DEV
- **PROD**: merges/pushes a `main` despliegan en PROD (se recomienda mantener habilitada la aprobación de GitHub Environment)

El estado remoto de Terraform usa llaves separadas:
- `dev/infra.tfstate`
- `prod/infra.tfstate`

## Cómo desplegar (CI/CD)
### DEV
1. Haz push de commits a una rama como `dev/henry`, `dev/sebas`, `dev/desarrolladorX`
2. GitHub Actions ejecuta:
   - `terraform fmt / validate / plan`
   - `terraform apply` (DEV)

### PROD
1. Crea un Pull Request hacia `main`
2. Haz merge a `main`
3. GitHub Actions ejecuta:
   - `terraform plan/apply` usando la configuración de PROD
4. Se necesita dos approve en el Pipeline para desplegar a PROD

## Outputs de Terraform (necesarios para el repositorio de la aplicación)
Después de que el workflow finalice, revisa los logs del job **apply** (step: **Show Terraform outputs**).  
Necesitarás los siguientes valores para el repositorio de microservicios:

- `resource_group_name`
- `aks_name`
- `acr_name`
- `acr_login_server`

## Limpieza
- La infraestructura de DEV puede destruirse usando el workflow manual: `destroy-dev.yml`
- La infraestructura de PROD puede destruirse usando el workflow manual: `destroy-prod.yml`
- El backend de Terraform (almacenamiento del estado) puede eliminarse usando: `scripts/destroy-backend.sh`
