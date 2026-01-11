#!/usr/bin/env python3
# Dev: Tyler Hudson - tkhudson
# IoT Device Simulator for Azure Zero-Trust Architecture
# Simulates legitimate devices sending telemetry to Azure IoT Hub

"""
Zero-Trust IoT Device Simulator
Simulates 3 IoT devices sending telemetry to Azure IoT Hub F1 (free tier)
Keeps message count under 500/day per device (total <1500/day vs 8000 limit)
"""

import asyncio
import json
import random
import time
from datetime import datetime, timezone
from azure.iot.device.aio import IoTHubDeviceClient
from azure.iot.device import Message
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ZeroTrustIoTDevice:
    def __init__(self, device_id: str, connection_string: str):
        self.device_id = device_id
        self.connection_string = connection_string
        self.client = IoTHubDeviceClient.create_from_connection_string(connection_string)
        self.is_connected = False
        self.message_count = 0
        
    async def connect(self):
        """Establish secure connection to IoT Hub"""
        try:
            await self.client.connect()
            self.is_connected = True
            logger.info(f"✅ Device {self.device_id} connected securely")
        except Exception as e:
            logger.error(f"❌ Device {self.device_id} connection failed: {e}")
            
    async def disconnect(self):
        """Disconnect from IoT Hub"""
        try:
            await self.client.disconnect()
            self.is_connected = False
            logger.info(f"🔌 Device {self.device_id} disconnected")
        except Exception as e:
            logger.error(f"❌ Device {self.device_id} disconnect failed: {e}")
    
    def generate_telemetry(self) -> dict:
        """Generate realistic IoT telemetry data"""
        base_temp = 20.0 if "temp" in self.device_id.lower() else 25.0
        base_humidity = 45.0 if "humidity" in self.device_id.lower() else 50.0
        
        telemetry = {
            "deviceId": self.device_id,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "temperature": round(base_temp + random.uniform(-5, 5), 2),
            "humidity": round(base_humidity + random.uniform(-10, 10), 2),
            "motion": random.choice([True, False]),
            "batteryLevel": round(random.uniform(20, 100), 1),
            "signalStrength": random.randint(-80, -30),
            "messageCount": self.message_count + 1
        }
        
        # Simulate occasional anomalies for Defender for IoT demo
        if random.random() < 0.05:  # 5% chance
            telemetry["anomaly"] = {
                "type": random.choice(["temperature_spike", "unusual_motion", "low_battery"]),
                "severity": random.choice(["low", "medium", "high"]),
                "description": "Simulated anomaly for demo purposes"
            }
            
        return telemetry
    
    async def send_telemetry(self):
        """Send telemetry message to IoT Hub"""
        if not self.is_connected:
            logger.warning(f"⚠️ Device {self.device_id} not connected")
            return
            
        try:
            telemetry = self.generate_telemetry()
            message = Message(json.dumps(telemetry))
            
            # Add message properties for routing/filtering
            message.custom_properties["deviceType"] = "sensor"
            message.custom_properties["location"] = f"zone-{hash(self.device_id) % 3 + 1}"
            
            if "anomaly" in telemetry:
                message.custom_properties["alertLevel"] = telemetry["anomaly"]["severity"]
            
            await self.client.send_message(message)
            self.message_count += 1
            
            anomaly_flag = "🚨" if "anomaly" in telemetry else ""
            logger.info(f"📤 {self.device_id}: Message #{self.message_count} sent {anomaly_flag}")
            
        except Exception as e:
            logger.error(f"❌ {self.device_id} telemetry send failed: {e}")

class ZeroTrustSimulation:
    def __init__(self):
        self.devices = []
        self.iot_hub_hostname = None
        self.running = False
        
    def load_connection_strings(self):
        """Load device connection strings from file"""
        try:
            with open('device_connections.json', 'r') as f:
                connections = json.load(f)
                return connections
        except FileNotFoundError:
            logger.error("❌ device_connections.json not found. Run setup script first.")
            return {}
    
    async def setup_devices(self):
        """Initialize all simulated devices"""
        connections = self.load_connection_strings()
        
        if not connections:
            logger.error("❌ No device connections found")
            return False
            
        device_types = ["temperature-sensor", "humidity-monitor", "motion-detector"]
        
        for i, device_type in enumerate(device_types, 1):
            device_id = f"zero-trust-{device_type}-{i:02d}"
            
            if device_id in connections:
                device = ZeroTrustIoTDevice(device_id, connections[device_id])
                await device.connect()
                self.devices.append(device)
            else:
                logger.warning(f"⚠️ No connection string for {device_id}")
        
        logger.info(f"✅ {len(self.devices)} devices initialized")
        return len(self.devices) > 0
    
    async def run_simulation(self, duration_minutes: int = 60, message_interval: int = 30):
        """
        Run the IoT simulation
        
        Args:
            duration_minutes: How long to run simulation
            message_interval: Seconds between messages per device
        """
        if not await self.setup_devices():
            return
            
        self.running = True
        start_time = time.time()
        end_time = start_time + (duration_minutes * 60)
        
        logger.info(f"🚀 Starting zero-trust IoT simulation for {duration_minutes} minutes")
        logger.info(f"📊 Message interval: {message_interval} seconds")
        logger.info(f"📈 Max messages per device: {duration_minutes * 60 // message_interval}")
        
        try:
            while self.running and time.time() < end_time:
                # Send telemetry from all devices simultaneously
                tasks = [device.send_telemetry() for device in self.devices]
                await asyncio.gather(*tasks, return_exceptions=True)
                
                # Wait for next interval
                await asyncio.sleep(message_interval)
                
        except KeyboardInterrupt:
            logger.info("⏹️ Simulation interrupted by user")
        finally:
            await self.cleanup()
    
    async def cleanup(self):
        """Disconnect all devices"""
        self.running = False
        logger.info("🧹 Cleaning up connections...")
        
        for device in self.devices:
            await device.disconnect()
            
        total_messages = sum(device.message_count for device in self.devices)
        logger.info(f"📊 Simulation complete. Total messages sent: {total_messages}")

async def main():
    """Main simulation entry point"""
    print("🔐 Zero-Trust IoT Device Simulator")
    print("=" * 50)
    
    simulation = ZeroTrustSimulation()
    
    # Run for 30 minutes with 60-second intervals (30 messages per device)
    # Total: 90 messages vs 8000/day limit = very safe
    await simulation.run_simulation(duration_minutes=30, message_interval=60)

if __name__ == "__main__":
    asyncio.run(main())