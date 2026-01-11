/**
 * Zero-Trust IoT Dashboard JavaScript
 * Simulates real-time data visualization for demo purposes
 * In production, this would connect to Azure IoT Hub via Event Hub endpoints
 */

class ZeroTrustDashboard {
    constructor() {
        this.devices = [
            {
                id: 'zero-trust-temperature-sensor-01',
                name: 'Temperature Sensor 01',
                type: 'temperature',
                zone: 'zone-1',
                online: true,
                lastSeen: new Date(),
                telemetry: {
                    temperature: 22.5,
                    humidity: 45,
                    batteryLevel: 87,
                    signalStrength: -45
                }
            },
            {
                id: 'zero-trust-humidity-monitor-02', 
                name: 'Humidity Monitor 02',
                type: 'humidity',
                zone: 'zone-2',
                online: true,
                lastSeen: new Date(),
                telemetry: {
                    temperature: 24.1,
                    humidity: 52,
                    batteryLevel: 92,
                    signalStrength: -38
                }
            },
            {
                id: 'zero-trust-motion-detector-03',
                name: 'Motion Detector 03', 
                type: 'motion',
                zone: 'zone-3',
                online: true,
                lastSeen: new Date(),
                telemetry: {
                    temperature: 23.8,
                    humidity: 48,
                    motion: false,
                    batteryLevel: 76,
                    signalStrength: -52
                }
            }
        ];

        this.telemetryData = {
            temperature: [],
            humidity: [],
            timestamps: []
        };

        this.alerts = [];
        this.messageCount = 0;
        this.isPaused = false;
        this.charts = {};
        
        this.init();
    }

    init() {
        this.initializeCharts();
        this.updateDeviceCards();
        this.updateStatusIndicators();
        this.updateSecurityStatus();
        this.setupEventListeners();
        this.startDataSimulation();
        
        console.log('🔐 Zero-Trust IoT Dashboard initialized');
    }

    initializeCharts() {
        // Temperature Chart
        const tempCtx = document.getElementById('temperatureChart').getContext('2d');
        this.charts.temperature = new Chart(tempCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: this.devices.filter(d => d.type === 'temperature' || d.type === 'humidity' || d.type === 'motion').map((device, index) => ({
                    label: device.name,
                    data: [],
                    borderColor: this.getChartColor(index),
                    backgroundColor: this.getChartColor(index, 0.1),
                    borderWidth: 2,
                    fill: false,
                    tension: 0.4
                }))
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: '🌡️ Temperature (°C)',
                        font: { size: 16, weight: 'bold' }
                    },
                    legend: {
                        position: 'bottom'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        min: 15,
                        max: 35,
                        grid: { color: '#e1dfdd' }
                    },
                    x: {
                        grid: { color: '#e1dfdd' }
                    }
                },
                elements: {
                    point: { radius: 4, hoverRadius: 6 }
                }
            }
        });

        // Humidity Chart  
        const humidityCtx = document.getElementById('humidityChart').getContext('2d');
        this.charts.humidity = new Chart(humidityCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: this.devices.filter(d => d.type === 'temperature' || d.type === 'humidity' || d.type === 'motion').map((device, index) => ({
                    label: device.name,
                    data: [],
                    borderColor: this.getChartColor(index + 3),
                    backgroundColor: this.getChartColor(index + 3, 0.1),
                    borderWidth: 2,
                    fill: false,
                    tension: 0.4
                }))
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: '💧 Humidity (%)',
                        font: { size: 16, weight: 'bold' }
                    },
                    legend: {
                        position: 'bottom'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        min: 30,
                        max: 70,
                        grid: { color: '#e1dfdd' }
                    },
                    x: {
                        grid: { color: '#e1dfdd' }
                    }
                },
                elements: {
                    point: { radius: 4, hoverRadius: 6 }
                }
            }
        });
    }

    getChartColor(index, alpha = 1) {
        const colors = [
            `rgba(0, 120, 212, ${alpha})`,    // Primary blue
            `rgba(16, 124, 16, ${alpha})`,    // Success green
            `rgba(255, 140, 0, ${alpha})`,    // Warning orange
            `rgba(107, 182, 255, ${alpha})`,  // Light blue
            `rgba(140, 90, 190, ${alpha})`,   // Purple
            `rgba(255, 99, 132, ${alpha})`    // Pink
        ];
        return colors[index % colors.length];
    }

    updateDeviceCards() {
        const devicesGrid = document.getElementById('devices-grid');
        devicesGrid.innerHTML = '';

        this.devices.forEach(device => {
            const card = document.createElement('div');
            card.className = `device-card ${device.online ? 'online' : 'offline'}`;
            
            const lastSeenTime = device.online ? 'Just now' : 
                this.formatTimeAgo(device.lastSeen);

            card.innerHTML = `
                <div class="device-header">
                    <span class="device-name">${this.getDeviceIcon(device.type)} ${device.name}</span>
                    <span class="device-status ${device.online ? 'online' : 'offline'}">
                        ${device.online ? '🟢 Online' : '🔴 Offline'}
                    </span>
                </div>
                <div class="device-metrics">
                    <div class="device-metric">
                        <span class="device-metric-label">Zone:</span>
                        <span class="device-metric-value">${device.zone}</span>
                    </div>
                    <div class="device-metric">
                        <span class="device-metric-label">Temperature:</span>
                        <span class="device-metric-value">${device.telemetry.temperature.toFixed(1)}°C</span>
                    </div>
                    <div class="device-metric">
                        <span class="device-metric-label">Humidity:</span>
                        <span class="device-metric-value">${device.telemetry.humidity}%</span>
                    </div>
                    <div class="device-metric">
                        <span class="device-metric-label">Battery:</span>
                        <span class="device-metric-value">${device.telemetry.batteryLevel}%</span>
                    </div>
                    <div class="device-metric">
                        <span class="device-metric-label">Signal:</span>
                        <span class="device-metric-value">${device.telemetry.signalStrength} dBm</span>
                    </div>
                    <div class="device-metric">
                        <span class="device-metric-label">Last Seen:</span>
                        <span class="device-metric-value">${lastSeenTime}</span>
                    </div>
                    ${device.telemetry.motion !== undefined ? `
                    <div class="device-metric">
                        <span class="device-metric-label">Motion:</span>
                        <span class="device-metric-value">${device.telemetry.motion ? '🔴 Detected' : '🟢 Clear'}</span>
                    </div>
                    ` : ''}
                </div>
            `;
            
            devicesGrid.appendChild(card);
        });
    }

    getDeviceIcon(type) {
        const icons = {
            temperature: '🌡️',
            humidity: '💧',
            motion: '👁️'
        };
        return icons[type] || '📟';
    }

    formatTimeAgo(date) {
        const seconds = Math.floor((new Date() - date) / 1000);
        if (seconds < 60) return `${seconds}s ago`;
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60) return `${minutes}m ago`;
        const hours = Math.floor(minutes / 60);
        return `${hours}h ago`;
    }

    updateStatusIndicators() {
        const connectedDevices = this.devices.filter(d => d.online).length;
        document.getElementById('device-count').textContent = connectedDevices;
        document.getElementById('message-count').textContent = this.messageCount;
        
        const securityStatus = this.alerts.filter(a => a.severity === 'high').length > 0 ? 
            '🚨 ALERT' : '✅ SECURE';
        document.getElementById('security-status').textContent = securityStatus;
        document.getElementById('security-status').className = 
            securityStatus.includes('ALERT') ? 'status-value security-alert' : 'status-value security-ok';
    }

    updateSecurityStatus() {
        const threatLevel = this.alerts.length > 0 ? 'MEDIUM' : 'LOW';
        document.getElementById('threat-level').textContent = threatLevel;
        document.getElementById('threat-level').className = 
            `threat-level-${threatLevel.toLowerCase()}`;
    }

    updateCharts() {
        if (this.isPaused) return;

        const now = new Date().toLocaleTimeString();
        
        // Update telemetry data
        this.devices.forEach((device, deviceIndex) => {
            // Add some realistic variation
            device.telemetry.temperature += (Math.random() - 0.5) * 0.5;
            device.telemetry.humidity += (Math.random() - 0.5) * 2;
            
            // Keep values in realistic ranges
            device.telemetry.temperature = Math.max(18, Math.min(30, device.telemetry.temperature));
            device.telemetry.humidity = Math.max(30, Math.min(70, device.telemetry.humidity));
            
            // Simulate occasional motion detection
            if (device.type === 'motion') {
                device.telemetry.motion = Math.random() < 0.1; // 10% chance
            }
            
            // Update chart data
            if (this.charts.temperature.data.datasets[deviceIndex]) {
                this.charts.temperature.data.datasets[deviceIndex].data.push(device.telemetry.temperature);
            }
            if (this.charts.humidity.data.datasets[deviceIndex]) {
                this.charts.humidity.data.datasets[deviceIndex].data.push(device.telemetry.humidity);
            }
        });

        // Update chart labels
        this.charts.temperature.data.labels.push(now);
        this.charts.humidity.data.labels.push(now);

        // Limit data points to last 20 for performance
        const maxDataPoints = 20;
        if (this.charts.temperature.data.labels.length > maxDataPoints) {
            this.charts.temperature.data.labels.shift();
            this.charts.humidity.data.labels.shift();
            
            this.charts.temperature.data.datasets.forEach(dataset => dataset.data.shift());
            this.charts.humidity.data.datasets.forEach(dataset => dataset.data.shift());
        }

        // Update charts
        this.charts.temperature.update('none');
        this.charts.humidity.update('none');
        
        // Simulate occasional anomalies
        if (Math.random() < 0.03) { // 3% chance per update
            this.simulateAlert();
        }
    }

    simulateAlert() {
        const alertTypes = [
            { 
                title: 'Temperature Anomaly Detected', 
                message: 'Device temperature reading exceeds normal range',
                severity: 'medium'
            },
            {
                title: 'Unusual Motion Pattern',
                message: 'Motion detector showing irregular activity patterns', 
                severity: 'low'
            },
            {
                title: '🚨 SECURITY BREACH ATTEMPT',
                message: 'Unauthorized device connection blocked by zero-trust authentication',
                severity: 'high'
            },
            {
                title: '🚨 BRUTE FORCE ATTACK',
                message: 'Multiple failed authentication attempts detected from same source',
                severity: 'high'
            },
            {
                title: '⚠️ MALICIOUS TELEMETRY',
                message: 'Anomalous data patterns detected - possible injection attack',
                severity: 'medium'
            },
            {
                title: '🔒 PROTOCOL VIOLATION',
                message: 'Unauthorized protocol access blocked by network security groups',
                severity: 'medium'
            },
            {
                title: '🎭 DEVICE SPOOFING ATTEMPT',
                message: 'Device identity spoofing blocked by certificate validation',
                severity: 'high'
            },
            {
                title: 'Network Anomaly',
                message: 'Unusual network traffic pattern from IoT device',
                severity: 'medium'
            }
        ];

        const alert = alertTypes[Math.floor(Math.random() * alertTypes.length)];
        alert.timestamp = new Date();
        alert.id = Date.now();
        
        this.alerts.unshift(alert);
        this.updateAlertsDisplay();
        this.updateStatusIndicators();
        this.updateSecurityStatus();

        // Auto-clear alerts after 45 seconds for demo (longer for security alerts)
        const clearTime = alert.severity === 'high' ? 60000 : 30000;
        setTimeout(() => {
            this.alerts = this.alerts.filter(a => a.id !== alert.id);
            this.updateAlertsDisplay();
            this.updateStatusIndicators();
            this.updateSecurityStatus();
        }, clearTime);
    }

    updateAlertsDisplay() {
        const alertsContainer = document.getElementById('alerts-container');
        
        if (this.alerts.length === 0) {
            alertsContainer.innerHTML = `
                <div class="no-alerts">
                    <span>🎉 No security alerts - All systems secure</span>
                </div>
            `;
            return;
        }

        alertsContainer.innerHTML = this.alerts.map(alert => `
            <div class="alert-item ${alert.severity}-severity" data-alert-id="${alert.id}">
                <div class="alert-content">
                    <h4>${this.getAlertIcon(alert.severity)} ${alert.title}</h4>
                    <p>${alert.message}</p>
                    <div class="alert-time">${alert.timestamp.toLocaleTimeString()}</div>
                </div>
                <button class="btn btn-small" onclick="dashboard.dismissAlert(${alert.id})">×</button>
            </div>
        `).join('');
    }

    getAlertIcon(severity) {
        const icons = {
            high: '🚨',
            medium: '⚠️', 
            low: '💡'
        };
        return icons[severity] || '⚠️';
    }

    dismissAlert(alertId) {
        this.alerts = this.alerts.filter(alert => alert.id !== alertId);
        this.updateAlertsDisplay();
        this.updateStatusIndicators();
        this.updateSecurityStatus();
    }

    clearAllAlerts() {
        this.alerts = [];
        this.updateAlertsDisplay();
        this.updateStatusIndicators();
        this.updateSecurityStatus();
    }

    updateMetrics() {
        // Simulate IoT Hub usage
        const hubUsage = Math.min(this.messageCount, 8000);
        const usagePercentage = (hubUsage / 8000) * 100;
        
        document.getElementById('hub-usage').textContent = hubUsage;
        document.getElementById('hub-usage-bar').style.width = `${usagePercentage}%`;
        
        // Update connectivity rate (simulate 99-100%)
        const connectivity = Math.floor(Math.random() * 2) + 99;
        document.getElementById('connectivity-rate').textContent = connectivity;
        document.getElementById('connectivity-bar').style.width = `${connectivity}%`;
        
        // Update response time (simulate 30-60ms)
        const responseTime = Math.floor(Math.random() * 30) + 30;
        document.getElementById('response-time').textContent = responseTime;
        const responsePercentage = Math.max(0, 100 - responseTime);
        document.getElementById('response-bar').style.width = `${responsePercentage}%`;
    }

    setupEventListeners() {
        // Pause/Resume button
        document.getElementById('pause-btn').addEventListener('click', () => {
            this.isPaused = !this.isPaused;
            const btn = document.getElementById('pause-btn');
            btn.textContent = this.isPaused ? '▶️ Resume' : '⏸️ Pause';
        });

        // Reset charts button
        document.getElementById('reset-btn').addEventListener('click', () => {
            this.charts.temperature.data.labels = [];
            this.charts.humidity.data.labels = [];
            this.charts.temperature.data.datasets.forEach(dataset => dataset.data = []);
            this.charts.humidity.data.datasets.forEach(dataset => dataset.data = []);
            this.charts.temperature.update();
            this.charts.humidity.update();
            this.messageCount = 0;
            this.updateStatusIndicators();
        });

        // Clear alerts button
        document.getElementById('clear-alerts-btn').addEventListener('click', () => {
            this.clearAllAlerts();
        });
    }

    startDataSimulation() {
        // Update data every 5 seconds for demo
        setInterval(() => {
            this.updateCharts();
            this.updateDeviceCards();
            this.messageCount += this.devices.filter(d => d.online).length;
            this.updateStatusIndicators();
            this.updateMetrics();
            
            // Update last update time
            document.getElementById('last-update').textContent = 
                `Last update: ${new Date().toLocaleTimeString()}`;
        }, 5000);

        console.log('📊 Data simulation started - updating every 5 seconds');
    }
}

// Initialize dashboard when page loads
let dashboard;
document.addEventListener('DOMContentLoaded', () => {
    dashboard = new ZeroTrustDashboard();
});

// Global functions for event handlers
window.dashboard = {
    dismissAlert: (alertId) => dashboard.dismissAlert(alertId)
};