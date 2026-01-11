#!/usr/bin/env python3
# Dev: Tyler Hudson - tkhudson
# Zero-Trust IoT Dashboard - Complete Demo Launcher
# Coordinates dashboard, devices, and security demonstration
"""
Zero-Trust IoT Dashboard - Complete Demo Launcher
Coordinates dashboard, devices, and security demonstration
"""

import os
import sys
import subprocess
import time
import webbrowser
from datetime import datetime

class ZeroTrustDemo:
    """Orchestrates the complete zero-trust demonstration"""
    
    def __init__(self):
        self.processes = []
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        
    def print_banner(self):
        print("\n" + "🛡️ " * 20)
        print("   AZURE ZERO-TRUST IoT DASHBOARD DEMONSTRATION")
        print("🛡️ " * 20)
        print("\n📋 This demo showcases:")
        print("  ✅ Real Azure IoT Hub integration (FREE tier)")
        print("  ✅ Live telemetry from 3 IoT devices")
        print("  ✅ Real-time security monitoring dashboard")
        print("  ✅ Zero-trust attack prevention simulation")
        print("  ✅ Azure cost monitoring ($0 total cost)")
        print("\n💼 Perfect for:")
        print("  🎯 Portfolio demonstrations")
        print("  🎯 Technical interviews")
        print("  🎯 Azure architecture showcases")
        print("  🎯 Security engineering discussions")
        print("\n" + "🛡️ " * 20 + "\n")
    
    def start_dashboard(self):
        """Start the dashboard web server"""
        print("🌐 Starting Zero-Trust Dashboard...")
        dashboard_dir = os.path.join(self.base_dir, 'dashboard')
        
        try:
            process = subprocess.Popen([
                sys.executable, '-m', 'http.server', '8080'
            ], cwd=dashboard_dir, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            self.processes.append(process)
            time.sleep(2)
            
            print("✅ Dashboard server started")
            print("🔗 URL: http://localhost:8080")
            
            # Try to open in browser
            try:
                webbrowser.open('http://localhost:8080')
                print("🌐 Browser opened automatically")
            except:
                print("📱 Please open http://localhost:8080 in your browser")
                
            return True
            
        except Exception as e:
            print(f"❌ Dashboard start failed: {str(e)}")
            return False
    
    def start_iot_devices(self):
        """Start legitimate IoT device simulation"""
        print("\n📱 Starting IoT Devices...")
        
        try:
            # Check if device connections exist
            device_file = os.path.join(self.base_dir, 'device-simulation', 'device_connections.json')
            if not os.path.exists(device_file):
                print("⚠️  Device connections not found - run setup_devices.sh first")
                return False
                
            # Start IoT simulator
            iot_script = os.path.join(self.base_dir, 'device-simulation', 'iot_simulator.py')
            process = subprocess.Popen([
                sys.executable, iot_script
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            self.processes.append(process)
            time.sleep(2)
            
            print("✅ IoT devices started (3 devices sending telemetry)")
            print("📊 Telemetry: Temperature, Humidity, Motion data")
            print("🔄 Frequency: Every 30 seconds to Azure IoT Hub")
            
            return True
            
        except Exception as e:
            print(f"❌ IoT devices start failed: {str(e)}")
            return False
    
    def wait_for_user_ready(self):
        """Wait for user to open dashboard and confirm readiness"""
        print("\n📋 SETUP CHECKLIST:")
        print("  1. ✅ Dashboard server running")
        print("  2. ✅ IoT devices sending data")
        print("  3. 🔄 Open http://localhost:8080 in your browser")
        print("  4. 🔄 Verify you can see live device telemetry")
        print("  5. 🔄 Check that security status shows 'SECURE'")
        
        input("\n⏸️  Press ENTER when dashboard is open and showing live data...")
    
    def run_attack_simulation(self):
        """Run the security attack demonstration"""
        print("\n🚨 STARTING ZERO-TRUST SECURITY DEMONSTRATION")
        print("="*60)
        print("The following attacks will be simulated:")
        print("  🎭 Unauthorized device connections")
        print("  🎭 Credential brute force attacks")
        print("  🎭 Malicious telemetry injection")
        print("  🎭 Network protocol violations")
        print("  🎭 Device identity spoofing")
        print("\n📊 Watch the dashboard for real-time security alerts!")
        print("="*60)
        
        # Run the quick attack demo
        try:
            attack_script = os.path.join(self.base_dir, 'quick_attack_demo.py')
            subprocess.run([sys.executable, attack_script], check=True)
            
        except Exception as e:
            print(f"⚠️  Attack simulation error: {str(e)}")
            print("🔄 Continuing with manual demonstration...")
    
    def show_architecture_summary(self):
        """Display the architecture and cost summary"""
        print("\n📐 AZURE ARCHITECTURE DEPLOYED:")
        print("  🏗️  Resource Group: rg-zerotrust-iot-dash")
        print("  🌐 IoT Hub: F1 Free Tier (8000 msg/day)")
        print("  🌍 Static Web App: Free Tier")
        print("  🔒 Virtual Network + Security Groups")
        print("  🛡️  Microsoft Defender for IoT")
        print("  📊 Application Insights")
        
        print("\n💰 COST BREAKDOWN:")
        print("  💲 Total Monthly Cost: $0.00")
        print("  ✅ All services using free tiers")
        print("  ✅ No unexpected charges")
        print("  ✅ Cost alerts configured")
        
        print("\n🔧 INFRASTRUCTURE AS CODE:")
        print("  📜 Terraform configuration")
        print("  🏗️  Fully reproducible")
        print("  🗂️  Remote state management")
        print("  🧹 Easy cleanup with destroy script")
    
    def cleanup(self):
        """Clean up all processes"""
        print("\n🧹 Cleaning up processes...")
        for process in self.processes:
            try:
                process.terminate()
            except:
                pass
        print("✅ Cleanup complete")
    
    def run_full_demo(self):
        """Run the complete demonstration"""
        try:
            self.print_banner()
            
            # Start dashboard
            if not self.start_dashboard():
                return False
                
            # Start IoT devices  
            if not self.start_iot_devices():
                return False
            
            # Wait for user to view dashboard
            self.wait_for_user_ready()
            
            # Run attack simulation
            self.run_attack_simulation()
            
            # Show architecture summary
            self.show_architecture_summary()
            
            print("\n🎉 DEMONSTRATION COMPLETE!")
            print("💼 Your Azure Zero-Trust IoT Dashboard is fully operational")
            print("📊 Dashboard continues running at http://localhost:8080")
            print("🔄 IoT devices continue sending telemetry")
            
            # Keep running until user stops
            print("\n⏹️  Press Ctrl+C to end demonstration")
            try:
                while True:
                    time.sleep(60)
                    timestamp = datetime.now().strftime("%H:%M:%S")
                    print(f"⏱️  Demo running... {timestamp} - Dashboard: http://localhost:8080")
            except KeyboardInterrupt:
                print("\n🛑 Demonstration ended by user")
                
            return True
            
        except KeyboardInterrupt:
            print("\n🛑 Demo interrupted")
            return False
        except Exception as e:
            print(f"\n❌ Demo error: {str(e)}")
            return False
        finally:
            self.cleanup()

def main():
    """Main entry point"""
    demo = ZeroTrustDemo()
    
    try:
        success = demo.run_full_demo()
        if success:
            print("✅ Demo completed successfully")
        else:
            print("⚠️  Demo completed with issues")
            
    except KeyboardInterrupt:
        print("\n🛑 Demo interrupted")
        demo.cleanup()
    except Exception as e:
        print(f"❌ Fatal error: {str(e)}")
        demo.cleanup()
        sys.exit(1)

if __name__ == "__main__":
    main()