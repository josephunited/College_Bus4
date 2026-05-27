# 🚌 Smart College Bus Tracking System

A real-time bus tracking system built using **IoT + Web Technologies** to monitor college buses and provide live location updates to students, staff, and administrators.

---

## 🚀 Features

- 📍 Real-time bus location tracking
- 🗺️ Live map visualization (Mapbox / Google Maps)
- ⏱️ ETA prediction and route tracking
- 👥 Role-based dashboards (Student, Parent, Admin)
- 📡 Dual communication: WiFi + GSM (SIM800L fallback)
- 📊 Historical data tracking

---

## 🏗️ System Architecture

### 🔹 Arduino / IoT
- ESP32 microcontroller
- NEO-6M GPS module for location data
- SIM800L for GSM-based communication
- Sends coordinates to backend via HTTP/SMS

### 🔹 Backend
- FastAPI (Python)
- REST APIs for receiving and serving bus data
- Handles GPS data processing and ETA logic

### 🔹 Database
- MySQL / PostgreSQL
- Stores:
  - Bus locations
  - Routes
  - User data
  - Location history

### 🔹 Frontend
- Flutter app
- Real-time map interface
- Displays bus location, route, and ETA

---

## 🔄 Data Flow

1. GPS module captures location
2. ESP32 processes data
3. Data sent via WiFi / SIM800L (HTTP/SMS)
4. Backend API receives and stores data
5. Frontend fetches and displays live updates

---

## 🛠️ Tech Stack

- **Frontend:** Flutter
- **Backend:** FastAPI (Python)
- **Database:** MySQL / PostgreSQL
- **IoT:** ESP32, GPS (NEO-6M), SIM800L
- **Maps:** Mapbox / Google Maps

---

## ⚙️ Setup Instructions

### 1. Clone Repository
```bash
git clone https://github.com/your-repo/bus-tracking-system.git
cd bus-tracking-system
