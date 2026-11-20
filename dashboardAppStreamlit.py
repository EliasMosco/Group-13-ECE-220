from pathlib import Path
import pandas as pd
import streamlit as st
import streamlit.components.v1 as components

st.set_page_config(
    page_title="Cuba, NM — Telecommunications Dashboard",
    page_icon="📡",
    layout="wide",
)

FCC_MAP_URL = (
    "https://broadbandmap.fcc.gov/location-summary/fixed?"
    "version=dec2025&zoom=15.26&vlon=-106.956261&vlat=36.017635"
    "&br=r&speed=100_20&tech=1_2_3_7"
)

# -----------------------------------------------------------------------------
# TELECOMMUNICATIONS, CELLULAR & POWER RELIABILITY DATA (CUBA, NM)
# -----------------------------------------------------------------------------
INTERNET_PROVIDERS = pd.DataFrame(
    [
        {
            "Provider": "Starlink",
            "Connection": "Satellite",
            "Availability (%)": 100.0,
            "Max Speed (Mbps)": 400,
            "Terrestrial": "No",
            "Notes": "Broad community coverage; non-terrestrial.",
        },
        {
            "Provider": "Viasat",
            "Connection": "Satellite",
            "Availability (%)": 100.0,
            "Max Speed (Mbps)": 150,
            "Terrestrial": "No",
            "Notes": "Broad community coverage; non-terrestrial.",
        },
        {
            "Provider": "Hughesnet",
            "Connection": "Satellite",
            "Availability (%)": 97.4,
            "Max Speed (Mbps)": 50,
            "Terrestrial": "No",
            "Notes": "Broad community coverage; non-terrestrial.",
        },
        {
            "Provider": "Higher-Speed Internet",
            "Connection": "Fixed Wireless",
            "Availability (%)": 62.8,
            "Max Speed (Mbps)": 10,
            "Terrestrial": "Yes",
            "Notes": "Largest cited terrestrial footprint, but low maximum speed.",
        },
        {
            "Provider": "Choice Broadband",
            "Connection": "Fixed Wireless",
            "Availability (%)": 55.8,
            "Max Speed (Mbps)": 200,
            "Terrestrial": "Yes",
            "Notes": "Meaningful Cuba footprint with higher cited maximum speed.",
        },
        {
            "Provider": "Kinetic",
            "Connection": "DSL",
            "Availability (%)": 41.2,
            "Max Speed (Mbps)": 300,
            "Terrestrial": "Yes",
            "Notes": "Wired/DSL option with partial Cuba availability.",
        },
        {
            "Provider": "T-Mobile 5G Home Internet",
            "Connection": "5G Home Internet",
            "Availability (%)": 23.5,
            "Max Speed (Mbps)": 498,
            "Terrestrial": "Yes",
            "Notes": "High potential speed but limited cited Cuba footprint.",
        },
        {
            "Provider": "Mint Mobile 5G Internet",
            "Connection": "5G Internet",
            "Availability (%)": 23.2,
            "Max Speed (Mbps)": 415,
            "Terrestrial": "Yes",
            "Notes": "5G-based service with limited cited footprint.",
        },
        {
            "Provider": "XNET WiFi",
            "Connection": "Fixed Wireless",
            "Availability (%)": 15.4,
            "Max Speed (Mbps)": 2000,
            "Terrestrial": "Yes",
            "Notes": "Highest cited maximum speed, but small Cuba footprint.",
        },
        {
            "Provider": "Verizon 5G Home Internet",
            "Connection": "5G Home Internet",
            "Availability (%)": 8.5,
            "Max Speed (Mbps)": 300,
            "Terrestrial": "Yes",
            "Notes": "Small cited Cuba home-internet footprint.",
        },
    ]
)

CELLULAR_COVERAGE = pd.DataFrame(
    [
        {
            "Carrier": "AT&T",
            "4G Coverage (%)": 100,
            "5G Coverage (%)": 0,
            "Summary": "Broad modeled 4G footprint; no 5G footprint in cited Cuba dataset.",
        },
        {
            "Carrier": "Verizon",
            "4G Coverage (%)": 100,
            "5G Coverage (%)": 0,
            "Summary": "Broad modeled 4G footprint; no 5G footprint in cited Cuba dataset.",
        },
        {
            "Carrier": "T-Mobile",
            "4G Coverage (%)": 97,
            "5G Coverage (%)": 94,
            "Summary": "Broad 4G plus strongest cited 5G footprint (94%) in Cuba.",
        },
    ]
)

JMEC_RELIABILITY = pd.DataFrame(
    [
        {
            "Year": 2020,
            "SAIDI Incl. Major Events (min/cust)": 540.9,
            "SAIDI Excl. Major Events (min/cust)": 486.0,
            "SAIFI": 2.785,
            "Approx. Outage Hours / Cust": 9.02,
        },
        {
            "Year": 2021,
            "SAIDI Incl. Major Events (min/cust)": 777.6,
            "SAIDI Excl. Major Events (min/cust)": 432.9,
            "SAIFI": 4.166,
            "Approx. Outage Hours / Cust": 12.96,
        },
        {
            "Year": 2022,
            "SAIDI Incl. Major Events (min/cust)": 605.5,
            "SAIDI Excl. Major Events (min/cust)": 569.8,
            "SAIFI": 2.929,
            "Approx. Outage Hours / Cust": 10.09,
        },
        {
            "Year": 2023,
            "SAIDI Incl. Major Events (min/cust)": 668.1,
            "SAIDI Excl. Major Events (min/cust)": 641.3,
            "SAIFI": 3.430,
            "Approx. Outage Hours / Cust": 11.14,
        },
        {
            "Year": 2024,
            "SAIDI Incl. Major Events (min/cust)": 1876.7,
            "SAIDI Excl. Major Events (min/cust)": 1044.8,
            "SAIFI": 4.950,
            "Approx. Outage Hours / Cust": 31.28,
        },
    ]
)

FACTOR_DETAILS = {
    "Poor Electrical": (
        "Cuba is particularly prone to electrical issues and temporary power outages compared to "
        "other areas in New Mexico, directly interrupting cellular and computer communications "
        "even where cell towers and devices exist. Utility-wide JMEC SAIDI reached 1,876.7 minutes "
        "per customer in 2024."
    ),
    "Seasonal Monsoons / Weather": (
        "Seasonal monsoons and rapidly changing weather disrupt satellite-based links (causing "
        "degraded service or complete failures) and slowly degrade terrain, creating downstream "
        "maintenance and access challenges."
    ),
    "Poor Work Terrain / Maintenance / Roaming Livestock": (
        "Difficult terrain and roaming livestock (which can chew cables or get loose) slow down "
        "crew access, material transport, and routine maintenance needed to keep towers and "
        "telecom equipment operating reliably."
    ),
    "Poor Economy": (
        "Creates a reinforcing feedback loop: limited local funds constrain road/terrain repairs "
        "and tower maintenance, while connectivity and infrastructure constraints limit local "
        "economic activity."
    ),
}

# -----------------------------------------------------------------------------
# HEADER & TOP KPIs
# -----------------------------------------------------------------------------
st.title("Village of Cuba, NM — Telecommunications Dashboard")
st.caption("Broadband availability, cellular coverage, power reliability context, and systemic telecom factors.")

k1, k2, k3, k4 = st.columns(4)
k1.metric("Registered Students (2023)", "769")
k2.metric("Graduation Rate Shift", "62% → 95%", "+33 pts (2019–2021)")
k3.metric("Top Satellite Footprint", "100%", "Starlink & Viasat")
k4.metric("JMEC 2024 SAIDI", "1,876.7 min", "vs. 540.9 min in 2020")

st.divider()

# -----------------------------------------------------------------------------
# SECTION 1: INTERNET PROVIDER AVAILABILITY
# -----------------------------------------------------------------------------
st.header("1. Internet Provider Availability & Speeds")

col_ctrl, col_viz = st.columns([1, 1.8])
with col_ctrl:
    conn_types = sorted(INTERNET_PROVIDERS["Connection"].unique())
    selected_conn = st.multiselect("Filter by Connection Type", conn_types, default=conn_types)
    terrestrial_only = st.checkbox("Terrestrial providers only", value=False)
    min_avail = st.slider("Minimum Availability (%)", 0.0, 100.0, 0.0, step=5.0)

    filtered_isp = INTERNET_PROVIDERS[
        (INTERNET_PROVIDERS["Connection"].isin(selected_conn))
        & (INTERNET_PROVIDERS["Availability (%)"] >= min_avail)
    ]
    if terrestrial_only:
        filtered_isp = filtered_isp[filtered_isp["Terrestrial"] == "Yes"]

with col_viz:
    if filtered_isp.empty:
        st.warning("No providers match the selected filters.")
    else:
        st.subheader("Estimated Availability (%) in Cuba, NM")
        st.bar_chart(
            filtered_isp.sort_values("Availability (%)", ascending=True).set_index("Provider")["Availability (%)"],
            horizontal=True,
            height=340,
        )

st.dataframe(filtered_isp.sort_values("Availability (%)", ascending=False), use_container_width=True, hide_index=True)

st.divider()

# -----------------------------------------------------------------------------
# SECTION 2: FCC NATIONAL BROADBAND MAP (CUBA, NM)
# -----------------------------------------------------------------------------
st.header("2. FCC Broadband Map — Cuba, NM (≥ 100/20 Mbps)")
st.link_button("Open Interactive FCC Broadband Map in New Tab", FCC_MAP_URL)

map_tab1, map_tab2 = st.tabs(["Embedded FCC Map", "FCC Map Snapshot (PDF)"])

with map_tab1:
    components.iframe(FCC_MAP_URL, height=520, scrolling=True)
    st.caption(
        "If the embedded FCC frame appears blank due to browser or site frame restrictions, "
        "use the button above to open the map directly or view the PDF map snapshot tab."
    )

with map_tab2:
    fcc_img_path = Path("fcc_map_page2_X14.png")
    if fcc_img_path.exists():
        st.image(
            str(fcc_img_path),
            caption="FCC Broadband Map view for Cuba, NM (from CUBA VILLAGE DATA-1-1.pdf)",
            use_container_width=True,
        )
    else:
        st.info("Place `fcc_map_page2_X14.png` alongside `app.py` to display the static FCC map snapshot.")

st.markdown("**FCC Location Map Tiers (≥ 100/20 Mbps Reference):**")
st.markdown(
    "- **Green (Served):** Terrestrial ISP filed ability to install **≥ 100/20 Mbps** within 10 business days.\n"
    "- **Yellow (Underserved):** Service exists, but top speeds fall below **100/20 Mbps** (commonly DSL ~10/1 to 50/10 Mbps).\n"
    "- **Red (Unserved):** No ground-based wireline or terrestrial wireless carrier claims even basic **25/3 Mbps** service."
)

st.divider()

# -----------------------------------------------------------------------------
# SECTION 3: CELLULAR COVERAGE & POWER RELIABILITY CONTEXT
# -----------------------------------------------------------------------------
st.header("3. Mobile Cellular Coverage & Power Reliability Context")

c_cell, c_pwr = st.columns(2)

with c_cell:
    st.subheader("Modeled 4G & 5G Coverage by Carrier (%)")
    st.dataframe(CELLULAR_COVERAGE, use_container_width=True, hide_index=True)
    st.bar_chart(CELLULAR_COVERAGE.set_index("Carrier")[["4G Coverage (%)", "5G Coverage (%)"]], height=260)

with c_pwr:
    st.subheader("JMEC Systemwide Reliability Trend (SAIDI / SAIFI)")
    st.dataframe(JMEC_RELIABILITY, use_container_width=True, hide_index=True)
    st.line_chart(
        JMEC_RELIABILITY.set_index("Year")[
            ["SAIDI Incl. Major Events (min/cust)", "SAIDI Excl. Major Events (min/cust)"]
        ],
        height=260,
    )
    st.caption("Utility-wide JMEC EIA-861 reliability context supporting power-resilience risk analysis for telecom equipment.")

st.divider()

# -----------------------------------------------------------------------------
# SECTION 4: TELECOMMUNICATIONS INTERCONNECTION FLOWCHART (ENG220_Story_JB)
# -----------------------------------------------------------------------------
st.header("4. Interconnected Telecommunications Factors (Flowchart)")

img_path = Path("flowchart_page1_X6.png")
col_img, col_exp = st.columns([1.4, 1])

with col_img:
    if img_path.exists():
        st.image(
            str(img_path),
            caption="Telecommunications factor relationship diagram (from ENG220_Story_JB-2.pdf)",
            use_container_width=True,
        )
    else:
        st.warning(
            "Flowchart image file `flowchart_page1_X6.png` not found in the working directory. "
            "Extract it from `ENG220_Story_JB-2.pdf` and place it alongside `app.py`."
        )

with col_exp:
    st.subheader("Factor Breakdown")
    selected_factor = st.selectbox("Select a factor:", list(FACTOR_DETAILS.keys()))
    st.info(FACTOR_DETAILS[selected_factor])

    st.markdown("**Educational Connectivity Context:**")
    st.markdown(
        "- Lightly populated rural & tribal land setting (~769 registered students in 2023) created severe remote-learning barriers during COVID-19.\n"
        "- Locally installed satellite units (with teacher installation) helped expand student connectivity, contributing to graduation rates rising from **62% (2019)** to **95% (2021)**."
    )
