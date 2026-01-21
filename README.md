# Repo: infra-devops (Terraform + GitHub Actions + Azure + OIDC)

## Repositorio - `infra-devops` 

Este repositorio aprovisiona la infraestructura requerida para la aplicación que está en el repo [https://github.com/hsniama/app-devops](https://github.com/hsniama/app-devops):

- Azure Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) con 2 nodos
- Redes (VNets/Subnets)
- Permisos AcrPull para la identidad kubelet de AKS
- Creación de App Registration, Service Principal y Federated creds.
- Estado remoto de Terraform almacenado en Azure Storage (autenticación con Azure AD)

## Infraestructura en Azure 
- **Región**: `eastus` 
- **State (backend)**: 
  - resource_group_name: `rg-tfstate-devops`
    - storage_account_name: `sttfstate2e9f0a4f`
        - container_name:        `tfstate`
            - keys (states separados por ambiente dentro del mismo backend)
                - `dev/infra.tfstate`
                - `prod/infra.tfstate`

  ![Contenedor tfstate](./assets/img/6.png)

- **Infraestructura dev**:
    - resource_group_name: `rg-devops-dev`
        - VNet: `vnet-devops-dev`
            - Azure Container Registry (ACR): `acrdevops1720dev`
            - Azure Kubernetes Service (AKS): `aksdevops1720dev`

    ![Recursos en ambiente DEV](./assets/img/11.png)

- **Infraestructura prod**:
    - resource_group_name: `rg-devops-prod`
        - VNet: `vnet-devops-prod`
            - Azure Container Registry (ACR): `acrdevops1720prod`
            - Azure Kubernetes Service (AKS): `aksdevops1720prod`

    ![Recursos en ambiente PROD](./assets/img/12.png)

## Costos estimados 
- **AKS**: mínimo 2 nodos requeridos Tipo: `Standard_D2_v3` *(no tan económico)* 
- **ACR**: nivel `Basic` 

![Análisis de Costos](./assets/img/13.png)

## Entornos
- **DEV**: cualquier push a ramas `dev/**` despliega en DEV
- **PROD**: merge a `main` despliegan en PROD (se recomienda mantener habilitada la aprobación de GitHub Environment)

    Nota: El estado remoto de Terraform usa llaves separadas:
- `dev/infra.tfstate`

   ![Llave en DEV definida en el archivo backends/dev.hcl](./assets/img/7.png)
    [Ir al archivo backends/dev.hcl](./backends/dev.hcl)

- `prod/infra.tfstate`

   ![Llave en PROD definida en el archivo backends/prod.hcl](./assets/img/8.png)
    [Ir al archivo backends/prod.hcl](./backends/prod.hcl)

## Setup del proyecto

**0. Clonar el repo:**
```bash
git clone https://github.com/hsniama/infra-devops
cd infra-devops
```
**1. Loguearse a una suscripción activa con Azure y ejecutar los siguientes comandos:**
```bash
az login
```
```bash
az account set --subscription "PONER_TU_SUBSCRIPTION_NAME_O_ID"
```
```bash
SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
TENANT_ID="$(az account show --query tenantId -o tsv)"

echo "$SUBSCRIPTION_ID"
echo "$TENANT_ID"

```
**2. Ejecutar el bootstrap de creación del backend remoto de Terraform en Azure:**

El script crea y deja listos estos recursos en *Azure*:
- Resource Group → `rg-tfstate-devops` (o el que definas).
- Storage Account → nombre único tipo `sttfstateXXXX`.
- Blob Container → `tfstate`.
- Versionado de blobs activado.

Primero dar permisos al archivo:
```bash
chmod +x scripts/bootstrap-backend.sh
```
Después ejecutarlo:
```bash
./scripts/bootstrap-backend.sh
```
Nota: Este Script crea los recursos del **State (backend)** mencionados arriba.

Al final imprime las siguientes variables como información del backend en Terraform:
- `STATE_RG=rg-tfstate-devops`
- `STATE_SA=sttfstateXXXX`
- `STATE_CONTAINER=tfstate`

Exportarlas en tu terminal en la ubicación del proyecto de la siguiente manera:
```bash
export STATE_RG=rg-tfstate-devops
export STATE_SA=sttfstateXXXX
export STATE_CONTAINER=tfstate
```
Nota: el valor de `STATE_SA=sttfstateXXXX` debes reemplazarlo por el nombre que te da como resultado la ejecución del script, es decir, las `XXX` son valores generados por el siguiente bloque de codigo del que hace que sea un nombre único y global:

```bash
# Nombre único global (solo minúsculas y números, 3-24 chars)
# Puedes forzarlo exportando STATE_SA antes de correr el script
if [[ -z "${STATE_SA:-}" ]]; then
  RAND="$(openssl rand -hex 4)"
  STATE_SA="sttfstate${RAND}"
fi
```

**3. Configuración de Environments en GitHub**

Se crea los environments en el repo > settings > Environments:
- `dev` 
- `prod`: Se activa el "Required reviewers para que prod no aplique sin aprobación.

![Configuración de los 2 Environments. En prod se tiene un protection rule de "approve" antes de desplegar.](./assets/img/1.png)


**4. Creación del APP Registration + Service principal**

Este script habilita la autenticación segura de *GitHub Actions* contra *Azure* usando OIDC, con permisos suficientes para manejar infraestructura y el backend de Terraform.

Después de ejecutar el script se crea:
- Una App Registration en Azure AD (gh-oidc-infra-devops).
- Un Service Principal que:
    - Asigna permisos de *Owner* en la suscripción.
    - Asigna permisos de *Storage Blob Data Contributor* en el Storage Account del `tfstate`.
- Dos credenciales federadas OIDC para los entornos `dev` y `prod` del repo en GitHub.

Primero dar permisos al archivo:
```bash
chmod +x scripts/bootstrap-oidc.sh
```
Después ejecutarlo:
```bash
./scripts/bootstrap-oidc.sh
```

Al final, imprime las variables necesarias para *GitHub Secrets*:
- `AZURE_CLIENT_ID` → el APP_ID de la aplicación.
- `AZURE_TENANT_ID` → el Tenant ID de tu Azure AD.
- `AZURE_SUBSCRIPTION_ID` → el ID de la suscripción.

Nota: Estas se deben guardar en GitHub > Settings > Secrets & Variables > Actions > Repository Secrets para que los workflows las usen.

**5. Creación de Secrets en GitHub**

Crear los siguientes Secrets (obtenidas en el anterior paso) con sus respectivos valores en repo > settings > secrets & variables > actions > secrets

![Configuración de secrets](./assets/img/2.png)

Y en Actions > Variables, crear las siguientes:

- `AZ_LOCATION` → eastus
- `TF_STATE_CONTAINER` → tfstate
- `TF_STATE_RG` → rg-tfstate-devops
- `TF_STATE_SA` → STATE_SA

![Configuración de variables.](./assets/img/3.png)


## Ejecución de Pipeline

Se tiene el `.github/workflows/terraform.yml`:

![Pipeline ejecutado.](./assets/img/4.png)

Resultado:
- Push a `dev/**` -> Se despliega en el ambiente de DEV.
- PR para merge desde `dev/**` a `main` -> Se despliega en el ambiente de PROD con una aprobación en la fase `apply`.

![Pasando a prod, se necesita un approve en apply.](./assets/img/5.png)

[Ver el Pipeline en .github/workflows/terraform.yml](./.github/workflows/terraform.yml.github/workflows/terraform.yml)

## Outputs de Terraform 
*Estos Outputs son necesarios para el repositorio de la aplicación.*

Después de que el workflow finalice correctamente, revisa los logs del job **apply** (step: Show Terraform outputs), se necesitará los siguientes valores (de acuerdo al ambiente) para el repositorio de microservicios [https://github.com/hsniama/app-devops](https://github.com/hsniama/app-devops):

- `resource_group_name`
- `aks_name`
- `acr_name`
- `acr_login_server`

## Limpieza
- La infraestructura de DEV puede destruirse usando/ejecutando el workflow manual: `./.github/workflows/destroy-dev.yml`
- La infraestructura de PROD puede destruirse usando/ejecutando el workflow manual: `./.github/workflows/destroy-prod.yml`
- El backend de Terraform (almacenamiento del estado) puede eliminarse usando: `./scripts/destroy-backend.sh`

## Anexos

Todos los grupos de Recursos:
![Todos los grupos de recursos creados en la suupscripción.](./assets/img/10.png)

Los dos AKS Clusters de cada ambiente:
![AKS Clusters por ambiente.](assets/img/9.png)