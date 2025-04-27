
# Sentinel APT Hunt Notebook Environment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F<YOUR_GITHUB_ACCOUNT>%2Fsentinel-apt-hunt%2Fmain%2Ftemplates%2Fazuredeploy.json)

## Overview
This repository bootstraps a Microsoft Sentinel notebook environment—complete with Azure Machine Learning support, MSTICPy configuration, and automated Azure AD app registration—
to accelerate advanced‑persistent‑threat (APT) hunting.

**Features**

* One‑click **Deploy to Azure** button  
* `01_setup_environment.ipynb` ready for Microsoft Sentinel Notebooks **or** Azure ML Compute  
* Bash script to create and configure the Azure AD App Registration with Microsoft Graph and Log Analytics permissions  
* Template `msticpyconfig.yaml`  
* Optional script to enable Sentinel UEBA/ML behavioral‑analytics rules  
* Requirements file for reproducible Python environments

## Quick start

1. **Deploy** — click the blue button above, choose a resource group/location, and deploy.  
2. **App Registration** — after the deployment finishes, run:  

    ```bash
    scripts/create_app_registration.sh -w <workspace-name> -g <resource-group> -s <subscription-id>
    ```

    The script will print `CLIENT_ID`, `CLIENT_SECRET`, and `TENANT_ID`.
3. **Configure MSTICPy** — copy those values into `config/msticpyconfig.yaml` (or
   rely on Azure CLI/MSI auth by leaving them blank).
4. **Launch Notebook** — open **Microsoft Sentinel ➜ Notebooks** (or
   your Azure ML workspace) and run every cell in `01_setup_environment.ipynb`.  
   The notebook will install libraries, authenticate, run test KQL queries,
   and train an AutoEncoder model for anomaly (APT) detection.

## Repository layout

```
.
├── notebooks/
│   └── 01_setup_environment.ipynb
├── scripts/
│   ├── create_app_registration.sh
│   └── enable_ml_features.sh   # optional – enables UEBA/ML via CLI
├── templates/
│   └── azuredeploy.json
├── config/
│   └── msticpyconfig.yaml
├── requirements.txt
└── README.md
```

## Enabling Sentinel Machine‑Learning Analytics
The ARM template deploys Microsoft Sentinel and turns on **User & Entity Behavior Analytics (UEBA)**.
If you need to (re‑)enable ML analytics later, run:

```bash
./scripts/enable_ml_features.sh -w <workspace-name> -g <resource-group> -s <subscription-id>
```

This script enables **UEBA** and ensures the built‑in **ML Behavior Analytics** rule is turned on.

---

© 2025 Your Name or Company – MIT License
