import pandas as pd
import streamlit as st

st.set_page_config(
    page_title="Cuba, NM — Telecom & KNeW Resource Recovery Dashboard",
    page_icon="📡",
    layout="wide",
)

# -----------------------------------------------------------------------------
# DATA FROM PROVIDED DOCUMENTS
# -----------------------------------------------------------------------------
PROVIDER_DATA = pd.DataFrame(
    [
        {"Provider": "Starlink / Viasat", "Category": "Satellite", "Availability (%)": 100.0},
        {"Provider": "Higher Speed Internet", "Category": "Fixed Wireless", "Availability (%)": 87.4},
        {"Provider": "EarthLink", "Category": "5G Home", "Availability (%)": 86.1},
        {"Provider": "Choice Broadband", "Category": "Fixed Wireless", "Availability (%)": 82.8},
        {"Provider": "Windstream / Kinetic", "Category": "Fiber & DSL", "Availability (%)": 61.0},
        {"Provider": "Ethos Broadband", "Category": "Fixed Wireless", "Availability (%)": 46.1},
        {"Provider": "T-Mobile Home Internet", "Category": "5G FWA", "Availability (%)": 38.7},
        {"Provider": "Verizon 5G Home", "Category": "5G FWA", "Availability (%)": 4.3},
    ]
)

TELECOM_CHALLENGES = {
    "Poor Electrical": (
        "Cuba is especially prone to electrical issues and temporary power outages compared to "
        "other areas in New Mexico, directly interrupting cellular and computer communications "
        "even where cell towers and laptops are present."
    ),
    "Seasonal Monsoons / Weather": (
        "Monsoons and rapidly changing weather disrupt satellite-based connections (causing service "
        "degradation or outages) and slowly degrade terrain, triggering downstream maintenance and "
        "access issues."
    ),
    "Poor Work Terrain / Maintenance / Roaming Livestock": (
        "Rocky/difficult terrain and roaming livestock (which can chew cables or get loose) slow down "
        "crew access, material transport, and routine maintenance required to keep towers and systems running."
    ),
    "Poor Economy": (
        "Creates a feedback loop: limited local funds constrain road/terrain repairs and tower "
        "maintenance, while infrastructure/connectivity gaps hinder economic growth."
    ),
}

BYPRODUCT_DATA = pd.DataFrame(
    [
        {"Product": "Potassium Nitrate (KNO3)", "Use / Type": "Fertilizer", "Annual Yield (metric tons/yr)": 13023},
        {"Product": "Sodium Nitrate (NaNO3)", "Use / Type": "Chile Saltpeter / Preservative", "Annual Yield (metric tons/yr)": 10766},
        {"Product": "Sodium Chloride (NaCl)", "Use / Type": "Salt / Road De-icing Goodwill", "Annual Yield (metric tons/yr)": 7422},
        {"Product": "Calcium Chloride (CaCl2)", "Use / Type": "Food Additive", "Annual Yield (metric tons/yr)": 4294},
        {"Product": "Ammonium Sulfate ((NH4)2SO4)", "Use / Type": "Fertilizer", "Annual Yield (metric tons/yr)": 1981},
        {"Product": "Dolomite (CaMg(CO3)2)", "Use / Type": "Additive / Materials", "Annual Yield (metric tons/yr)": 166},
    ]
)

FEED_CHEMISTRY = pd.DataFrame(
    [
        {"Constituent": "Na", "Concentration (mg/L)": 3417, "Equiv/L": 148.6},
        {"Constituent": "K", "Concentration (mg/L)": 0, "Equiv/L": 0.0},
        {"Constituent": "Ca", "Concentration (mg/L)": 450, "Equiv/L": 22.5},
        {"Constituent": "Mg", "Concentration (mg/L)": 30, "Equiv/L": 2.5},
        {"Constituent": "Bicarbonate", "Concentration (mg/L)": 1340, "Equiv/L": 22.0},
        {"Constituent": "Sulfate", "Concentration (mg/L)": 2033, "Equiv/L": 42.4},
        {"Constituent": "Cl", "Concentration (mg/L)": 3876, "Equiv/L": 109.2},
    ]
)

MILESTONE_RANGES = pd.DataFrame(
    [
        {"Phase": "Permitting", "Target Month (Summary)": "Month 5", "Timeline Range (Gantt)": "5–8 months"},
        {"Phase": "Shovel Ready", "Target Month (Summary)": "Month 11 (within 12 mos)", "Timeline Range (Gantt)": "11–19 months"},
        {"Phase": "Commissioning / Operations", "Target Month (Summary)": "Month 22 (23 mos target)", "Timeline Range (Gantt)": "22–34 months"},
    ]
)

# -----------------------------------------------------------------------------
# HEADER & TOP KPIs
# -----------------------------------------------------------------------------
st.title("Village of Cuba, NM — Telecom & Resource Recovery Dashboard")
st.caption("Interactive overview compiled from Group 13 ECE-220 / Cuba NM project files.")

kpi1, kpi2, kpi3, kpi4 = st.columns(4)
kpi1.metric("Registered Students (2023)", "769")
kpi2.metric("Graduation Rate Shift", "62% → 95%", "+33 pts (2019–2021)")
kpi3.metric("KNeW Water Supply", "528,944 gpd", "vs. 420,000 gpd existing")
kpi4.metric("Total Annual Byproducts", f"{BYPRODUCT_DATA['Annual Yield (metric tons/yr)'].sum():,} t/yr")

st.divider()

# -----------------------------------------------------------------------------
# TABS
# -----------------------------------------------------------------------------
tab1, tab2 = st.tabs(["📡 Telecommunications & Broadband", "💧 KNeW Resource Recovery Facility"])

# --- TAB 1: TELECOM ---
with tab1:
    st.header("Broadband & Telecom Availability")

    col_filter, col_chart = st.columns([1, 2])
    with col_filter:
        categories = sorted(PROVIDER_DATA["Category"].unique())
        selected_categories = st.multiselect(
            "Filter by Technology Category",
            options=categories,
            default=categories,
        )
        min_avail = st.slider("Minimum Geographic Availability (%)", 0.0, 100.0, 0.0, step=5.0)

        filtered_providers = PROVIDER_DATA[
            (PROVIDER_DATA["Category"].isin(selected_categories))
            & (PROVIDER_DATA["Availability (%)"] >= min_avail)
        ].sort_values("Availability (%)", ascending=True)

        st.dataframe(
            filtered_providers.sort_values("Availability (%)", ascending=False),
            use_container_width=True,
            hide_index=True,
        )

    with col_chart:
        st.subheader("Geographic Availability (%) by Provider")
        if filtered_providers.empty:
            st.warning("No providers match the current filter settings.")
        else:
            st.bar_chart(
                filtered_providers.set_index("Provider")["Availability (%)"],
                horizontal=True,
                height=340,
            )

    st.markdown("### Key Connectivity Takeaways")
    t1, t2, t3, t4 = st.columns(4)
    t1.info("**Satellite (100%)**\n\nStarlink & Viasat reach all homes across spread-out, rocky terrain; teacher-led satellite installation helped expand student access.")
    t2.info("**Fixed Wireless / 5G (~39%–87%)**\n\nLocal WISPs and 5G home options cover much of the area via nearby mesas, though cell tower capacity for home broadband is limited.")
    t3.info("**Wireline / Fiber (61%)**\n\nWindstream/Kinetic coverage largely tracks corridors like US-550 and NM-126.")
    t4.info("**Verizon 5G Home (4.3%)**\n\nVery limited footprint compared to satellite and local fixed wireless.")

    st.markdown("### FCC Location Map Speed Tiers (≥ 100/20 Mbps Reference)")
    st.markdown(
        "- **Green (Served):** At least one terrestrial ISP filed that it can install **≥ 100/20 Mbps** service within 10 business days.\n"
        "- **Yellow (Underserved):** Service exists at the address, but top speeds fall below **100/20 Mbps** (commonly DSL around 10/1 to 50/10 Mbps).\n"
        "- **Red (Unserved):** No ground-based wireline or terrestrial wireless provider claims even basic **25/3 Mbps** broadband."
    )

    st.markdown("### Interconnected Telecommunications Challenges")
    selected_challenge = st.selectbox("Select a factor to inspect its role:", list(TELECOM_CHALLENGES.keys()))
    st.write(TELECOM_CHALLENGES[selected_challenge])

# --- TAB 2: KNEW FACILITY ---
with tab2:
    st.header("The KNeW Company — Resource Recovery & Water Project")

    w1, w2, w3 = st.columns(3)
    w1.metric("Existing Municipal Demand", "420,000 gpd")
    w2.metric("Proposed KNeW Supply", "528,944 gpd", "+108,944 gpd extra capacity")
    w3.metric("Rio Puerco Aquifer Depth", "2,700 ft", "576k–2.6M acre-feet recoverable")

    st.markdown(
        "The project uses the KNeW / ZIX-Zag ion-exchange and crystallization/precipitation process "
        "(with EPC execution by **Black & Veatch** and fertilizer/water off-take interest including **Yara** "
        "and **Village of Cuba**) to produce demineralized/potable-grade water and mineral/fertilizer byproducts "
        "with minimal waste[cite: 6, 7, 8, 9, 10, 11, 12, 13]."
    )

    c_left, c_right = st.columns([1.4, 1])
    with c_left:
        st.subheader("Projected Annual Byproduct Output (Metric Tons / Year)")
        st.bar_chart(
            BYPRODUCT_DATA.sort_values("Annual Yield (metric tons/yr)", ascending=True).set_index("Product")[
                "Annual Yield (metric tons/yr)"
            ],
            horizontal=True,
            height=300,
        )
    with c_right:
        st.subheader("Byproduct Breakdown")
        st.dataframe(BYPRODUCT_DATA, use_container_width=True, hide_index=True)

    st.subheader("Feedwater Composition (Mass Balance Reference)")
    st.dataframe(FEED_CHEMISTRY, use_container_width=True, hide_index=True)
    st.caption("Facility design flow noted across diligence materials: at least 516k gpd / 0.52 MGD (186M–186.48M gal/yr)[cite: 7, 8, 13].")

    st.subheader("Mobilization & Project Schedule")
    st.dataframe(MILESTONE_RANGES, use_container_width=True, hide_index=True)
    st.markdown(
        "**Key Permitting & Execution Highlights:** 23 permitting requirements tracked across state/federal/local "
        "agencies (e.g., Construction General Permit NMR100000 at 7 days from eNOI, while several permits take ~30 days to 3–6+ months)[cite: 14]."
    )