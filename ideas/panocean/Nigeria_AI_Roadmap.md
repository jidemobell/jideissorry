# Nigeria AI Roadmap — Pan Ocean Digital Transformation

## Practical AI for Nigerian Oil & Gas Operations

**Document Purpose:** Reference guide for AI opportunities — grounded in Nigerian operational reality, not Silicon Valley theory.  
**Author:** Olajide Olaniyan  
**Date:** March 2026

---

## Guiding Principle

> **Don't build AI for AI's sake. Build AI for Nigerian realities.**

Every initiative here passes three tests:
1. Does it solve a real, costly problem at Pan Ocean today?
2. Can it be built with data and infrastructure that actually exists?
3. Could another Nigerian operator pay for it within 3 years?

---

## Nigerian Operational Context

Any AI system built for Pan Ocean must be designed around these realities:

| Reality | Design Implication |
|---|---|
| Intermittent internet at remote sites | Offline-first; edge inference where possible |
| Power instability | Async processing; graceful degradation |
| Low bandwidth (especially field locations) | Lightweight models; local inference; sync when connected |
| NUPRC/DPR regulatory framework | Compliance logic baked in, not bolted on |
| Nigerian Content Act requirements | Data collection structured for NCA reporting from day one |
| Naira currency & FX exposure | Price and operate in Naira; minimise dollar-denominated cloud costs |
| Data quality legacy issues | Assume dirty data; build cleaning pipelines before ML |
| Trust and explainability culture | AI recommendations must explain themselves to be accepted |

---

## AI Opportunity Matrix

### Tier 1: Start Here (High ROI, Achievable with Existing Data)

#### 1. Predictive Maintenance — OOGP Gas Plant (Highest Priority Asset)

**Problem:** The Ovade-Ogharefe Gas Plant (OOGP) is Pan Ocean's most complex and highest-consequence asset — a 200MMscf/d cryogenic facility with 29 LPG storage tanks holding up to ~439,000 gallons of propane and LPG. Equipment failures (compressors, cryogenic units, storage pressure systems) at this scale are extremely costly and potentially dangerous. The plant was expanded to full capacity only in 2022 — maintenance pattern data from the new cryogenic systems is still building up, making this the ideal moment to instrument fully before problems begin.

**AI Solution:**
- Instrument compressors, cryogenic processing units, LPG storage tanks, and flow lines with vibration, temperature, and pressure sensors
- Train time-series anomaly detection models on sensor readings + SAP maintenance logs
- Output: Failure probability scores, recommended maintenance windows, escalation alerts

**Data Required:** Existing SAP maintenance logs, any existing SCADA feeds, equipment OEM specs and fault codes

**Tech Stack:** Python, scikit-learn / PyTorch, TSAI or Prophet for time-series, InfluxDB or TimescaleDB for sensor data, Azure IoT Hub for ingestion

**Expected ROI:** Reduction in unplanned downtime (even one avoided plant shutdown justifies the full project), extension of equipment lifespan, reduction in emergency part procurement

**Commercial Potential:** HIGH — every gas plant operator in Nigeria has this problem. Build at OOGP; package as "FieldMaintain" SaaS.

---

#### 2. Regulatory Reporting Automation — NUPRC/DPR Returns

**Problem:** Quarterly and annual regulatory submissions require pulling data from multiple systems (SAP, spreadsheets, manual records), formatting it to NUPRC templates, and submitting. It takes teams days per submission cycle.

**AI Solution:**
- Build data extraction pipelines from SAP and operational systems
- Use LLM-based template filling to auto-populate required report sections
- Add validation rules based on NUPRC submission requirements
- Output: Draft submissions ready for human review and sign-off

**Data Required:** SAP data, existing regulatory templates, past approved submissions (for training/validation)

**Tech Stack:** Python, LangChain or direct OpenAI/local LLM API, SAP data connectors, PDF generation library

**Expected ROI:** Days → hours per submission cycle; fewer errors; audit trail

**Commercial Potential:** HIGH — this is painful for every operator, and foreign software vendors are terrible at Nigerian regulatory specifics. Package as "RegulatoryReport".

---

#### 3. Nigerian Content Compliance Tracker

**Problem:** Tracking, calculating, and reporting Nigerian Content Act compliance (local spend %, local employment %, training documentation) is manual, error-prone, and creates significant audit risk.

**AI Solution:**
- Integrate with SAP procurement data and HR system
- Auto-classify suppliers and spend by Nigerian Content category using NLP/classification models
- Generate compliance reports in NCA-required format
- Flag gaps early (before audit)

**Data Required:** SAP procurement records, HR employee data, vendor master lists

**Tech Stack:** Python, spaCy or fine-tuned BERT for text classification, SAP data connectors

**Expected ROI:** Audit readiness; reduced compliance risk; staff time savings

**Commercial Potential:** HIGH — mandatory for all operators; most are doing this manually today. Package as "NigerianContent.ai".

---

### Tier 2: Build Next (Medium Complexity, Requires Data Preparation)

#### 4. Document Intelligence — Drilling Reports & Well Logs

**Problem:** Years of drilling reports, well logs, geological surveys, and contracts exist as PDFs or paper scans. Finding specific data (a well's pressure history, a vendor's contract terms) takes hours.

**AI Solution:**
- OCR pipeline to digitise historical paper documents
- LLM-based document classification and metadata extraction
- Semantic search (RAG architecture) so engineers can query: *"What was the average wellhead pressure on Well X during 2018–2019?"*
- Output: Searchable, structured knowledge base of Pan Ocean's operational history

**Data Required:** Existing document archives (digital and physical)

**Tech Stack:** Python, Tesseract / AWS Textract for OCR, LangChain + vector database (Chroma, Weaviate, or pgvector), local LLM (Llama3, Mistral) for sensitive data

**Note on Security:** Well data and production history is commercially sensitive. Use locally-hosted LLMs (not cloud APIs) for this application.

**Expected ROI:** Engineer productivity; faster decision-making; institutional knowledge preservation

**Commercial Potential:** MEDIUM — valuable for large operators; less compelling as a standalone product, but strong as part of a larger platform.

---

#### 5. Operations Dashboard with Anomaly Detection

**Problem:** Management has no real-time view across drilling operations, production output, and logistics. Reports are generated periodically, so problems are identified late.

**AI Solution:**
- Unified data integration layer pulling from SAP, SCADA, and operational systems
- Real-time dashboard (web and mobile) with configurable KPIs
- Anomaly detection layer that flags deviations from expected operational parameters
- Alert system with escalation logic

**Data Required:** SCADA feeds, SAP operational data, logistics/dispatch records

**Tech Stack:** Python (FastAPI backend), React or React Native (frontend), TimescaleDB, Grafana or custom dashboards, statistical anomaly detection

**Expected ROI:** Faster management response to operational issues; reduced losses from late problem detection

**Commercial Potential:** MEDIUM-HIGH — package as "WellWatch" SaaS. Configurability is key.

---

#### 6. Amukpe-Escravos Pipeline (AEPP) Integrity & Security Intelligence

**Problem:** The AEPP is Pan Ocean's 20"×67km crude oil pipeline to Escravos (160,000 bopd capacity), built using CHDD to resist vandalism — but 67km through the Niger Delta still presents exposure. Critically, the AEPP also serves third-party injectors on a tariff basis, meaning metering accuracy and tamper detection are direct *revenue* issues, not just safety concerns.

**AI Solution:**
- **Integrity monitoring:** Flow meter anomaly detection across all injection and delivery points — flag pressure drops, flow irregularities, and metering discrepancies indicative of a theft tap or structural issue
- **Encroachment detection:** Satellite imagery change detection (monthly comparison) along the 67km Right of Way corridor to identify new construction, dig activity, or vegetation clearance near the pipeline
- **Third-party reconciliation:** Automated metering and tariff billing for injector volumes — compare injected vs. delivered with full audit trail
- Alert system with GPS coordinates for field response teams

**Data Required:** SCADA flow meter readings, full AEPP route GPS coordinates, satellite imagery (Planet Labs, Airbus Defence, or NASRDA), existing tariff/injection records from SAP

**Tech Stack:** Python, GDAL/rasterio for satellite imagery, YOLO or similar CV for drone footage, GIS integration, statistical process control for flow anomaly detection

**Note:** Satellite imagery partnership required (Planet Labs, Airbus Defence, or NASRDA). NASRDA (National Space Research and Development Agency) is the preferred Nigerian-first option.

**Expected ROI:** Crude theft prevention (hundreds of millions of Naira per avoided incident); metering accuracy directly protects tariff revenue from third-party injectors

**Commercial Potential:** HIGH — every operator with long-haul Niger Delta pipelines faces identical problems. AEPP is a ready-made, 67km reference deployment. Package as "FieldWatch".

---

### Tier 3: Longer-Term Vision

#### 7. Production Optimisation

**Problem:** Well and field performance is managed based on experience and periodic review rather than continuous optimisation.

**AI Solution:**
- Reinforcement learning or optimisation models trained on historical production data
- Recommendations for well scheduling, injection rates, choke settings
- Simulation environment for testing operational decisions without field risk

**Prerequisites:** Requires significant data quality improvement work first. Not a good starting point.

**Commercial Potential:** VERY HIGH when proven — but requires 18+ months of data pipeline work before ML is viable.

---

#### 8. Procurement & Supply Chain Optimisation

**Problem:** Procurement for remote field operations involves significant lead times, FX exposure for imported parts, and frequent emergency orders at premium cost.

**AI Solution:**
- Demand forecasting for spare parts based on maintenance schedules and equipment age
- Supplier risk scoring using historical delivery performance
- FX exposure dashboard for imported goods with hedging recommendations

**Prerequisites:** Clean procurement data from SAP; vendor master list quality improvement.

---

## Roadmap Timeline

```
Year 1
├── Q1–Q2: Data Audit (SAP, SCADA, OOGP sensor data, AEPP metering records)
│           Predictive Maintenance Pilot — OOGP compressors (one asset class)
│           Regulatory Reporting Automation (MVP covering OML-98 + OML-147 NUPRC returns)
│           AEPP Tariff Reconciliation System (immediate revenue assurance value)
│
├── Q3–Q4: Nigerian Content Tracker (Phase 1 — aligned with PIA HCDT obligations)
│           Unified Operations Dashboard (OML-98 + OML-147 + OOGP + AEPP)
│           Predictive Maintenance Expansion (full OOGP cryogenic units + LPG storage)
│
Year 2
├── Q1–Q2: Document Intelligence (OML-98 well logs back to 1976 — digitise 50 years of data)
│           AEPP Pipeline Security Pilot (flow anomaly detection + satellite encroachment)
│           Package Regulatory Reporting as external product (RegulatoryReport)
│
├── Q3–Q4: WellWatch dashboard commercialisation
│           NigerianContent.ai launch to first external customer (likely another indigenous operator)
│           OML-147 production optimisation (data collection phase complete)
│
Year 3
├── Full commercialisation: FieldMaintain (OOGP-proven), NigerianContent.ai, RegulatoryReport, WellWatch, FieldWatch (AEPP-proven)
│   OML production optimisation (if data quality sufficient)
│   Explore gas market adjacency: NIPP/power sector operators as new customer segment
```

---

## Technology Stack Recommendations

### Languages
- **Python** — AI/ML, data pipelines, backend APIs
- **Java / Spring Boot** — enterprise integrations (SAP connectors, existing IBM-stack comfort)
- **TypeScript / React** — web dashboards and internal tools
- **React Native or Flutter** — mobile access to dashboards

### Cloud Platform
- **Microsoft Azure** (extend existing hybrid cloud investment)
- Azure ML for model training and deployment
- Azure IoT Hub for sensor data ingestion
- Azure Blob for document storage

### AI/ML
- **scikit-learn** for classical ML (predictive maintenance baseline)
- **PyTorch** for deep learning (time-series models, NLP)
- **LangChain** for LLM-based document intelligence
- **Locally hosted LLMs** (Llama3, Mistral via Ollama) for sensitive operational data
- **Hugging Face** models for NLP classification tasks

### Data Infrastructure
- **TimescaleDB or InfluxDB** for time-series sensor data
- **PostgreSQL with pgvector** for document embeddings (RAG)
- **Apache Airflow** for pipeline orchestration
- **dbt** for data transformation

### Integration
- **SAP APIs / RFC connectors** for enterprise data
- **Microsoft Graph API** for SharePoint workflow integration
- **SCADA system APIs** (vendor-specific)

---

## Key Principle: Build for Resilience

All systems must handle:
- **No internet for hours or days** at remote locations — offline queuing, sync on reconnect
- **Power outages** — async processing, no data loss on disconnection
- **Low bandwidth** — compressed payloads, differential sync, edge inference for time-sensitive AI
- **Limited local IT support** — auto-recovery, good observability, clear runbooks

This is not a limitation — it is your competitive advantage over foreign software vendors.

---

## Gotcha Moments — Common Objections Addressed

| Objection | Response |
|---|---|
| "AI won't work with our data quality" | Correct. Which is why data audit and cleaning is Phase 0, not Phase 2. We build the pipeline first. |
| "We tried automation before and it failed" | Those solutions were built for different realities. Ours are built here, for here. |
| "SAP already does this" | SAP does 20% of this for 200% of the cost, in a way designed for Germany. We do the rest. |
| "How do we maintain it without you?" | We hire and train a team. We document everything. We don't create dependency. |
| "Is it secure enough for operational data?" | Sensitive data stays local. We use locally hosted models. Azure only for non-sensitive workloads. |
| "Other companies won't trust software from an oil company" | They trust Pan Ocean more than a foreign consultancy that's never seen a Nigerian flow station. |

---

*This document is a living reference. Update as priorities are clarified through stakeholder conversations.*
