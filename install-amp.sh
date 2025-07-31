#!/bin/bash

# CubeCoders AMP Installation Script (Root-Compatible Version)
# This script installs CubeCoders AMP (Application Management Panel)
# Supports multiple game servers including Minecraft, Rust, ARK, and more
# WARNING: This version allows root execution but is not recommended

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root and warn
if [[ $EUID -eq 0 ]]; then
   warning "Running as root is not recommended for security reasons."
   warning "AMP will still be installed but consider using a regular user in the future."
   read -p "Press Enter to continue or Ctrl+C to cancel..."
fi

log "Starting CubeCoders AMP installation..."

# Update system packages
log "Updating system packages..."
if [[ $EUID -eq 0 ]]; then
    apt update || error "Failed to update package list"
else
    sudo apt update || error "Failed to update package list"
fi

# Install required dependencies
log "Installing required dependencies..."
if [[ $EUID -eq 0 ]]; then
    apt install -y \
        curl \
        wget \
        git \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        libffi-dev \
        libssl-dev \
        || error "Failed to install dependencies"
else
    sudo apt install -y \
        curl \
        wget \
        git \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        libffi-dev \
        libssl-dev \
        || error "Failed to install dependencies"
fi

# Install Java (required for many game servers)
log "Installing Java..."
if [[ $EUID -eq 0 ]]; then
    apt install -y \
        openjdk-8-jdk \
        openjdk-11-jdk \
        openjdk-17-jdk \
        openjdk-21-jdk \
        || error "Failed to install Java"
else
    sudo apt install -y \
        openjdk-8-jdk \
        openjdk-11-jdk \
        openjdk-17-jdk \
        openjdk-21-jdk \
        || error "Failed to install Java"
fi

# Set Java 17 as default (good balance for most game servers)
if [[ $EUID -eq 0 ]]; then
    update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java || warning "Could not set Java 17 as default"
else
    sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java || warning "Could not set Java 17 as default"
fi

# Create AMP user
log "Creating AMP user..."
if ! id "amp" &>/dev/null; then
    if [[ $EUID -eq 0 ]]; then
        useradd -m -s /bin/bash amp || error "Failed to create AMP user"
        usermod -aG sudo amp || warning "Could not add AMP user to sudo group"
    else
        sudo useradd -m -s /bin/bash amp || error "Failed to create AMP user"
        sudo usermod -aG sudo amp || warning "Could not add AMP user to sudo group"
    fi
else
    warning "AMP user already exists"
fi

# Create AMP directory
log "Creating AMP directory..."
if [[ $EUID -eq 0 ]]; then
    mkdir -p /opt/amp || error "Failed to create AMP directory"
    chown amp:amp /opt/amp || error "Failed to set ownership of AMP directory"
else
    sudo mkdir -p /opt/amp || error "Failed to create AMP directory"
    sudo chown amp:amp /opt/amp || error "Failed to set ownership of AMP directory"
fi

# Download AMP
log "Downloading CubeCoders AMP..."
cd /tmp
if [ -f "AMPInstaller.zip" ]; then
    rm AMPInstaller.zip
fi

# Download the latest AMP installer
wget -O AMPInstaller.zip "https://cubecoders.com/AMP/releases/latest/download/AMPInstaller.zip" || error "Failed to download AMP installer"

# Extract AMP
log "Extracting AMP..."
if [[ $EUID -eq 0 ]]; then
    su - amp -c "unzip -o /tmp/AMPInstaller.zip -d /opt/amp/" || error "Failed to extract AMP"
else
    sudo -u amp unzip -o AMPInstaller.zip -d /opt/amp/ || error "Failed to extract AMP"
fi

# Set proper permissions
if [[ $EUID -eq 0 ]]; then
    chown -R amp:amp /opt/amp || error "Failed to set AMP directory permissions"
else
    sudo chown -R amp:amp /opt/amp || error "Failed to set AMP directory permissions"
fi

# Create AMP configuration directory
if [[ $EUID -eq 0 ]]; then
    su - amp -c "mkdir -p /opt/amp/AMPData" || error "Failed to create AMP data directory"
else
    sudo -u amp mkdir -p /opt/amp/AMPData || error "Failed to create AMP data directory"
fi

# Create systemd service file
log "Creating systemd service..."
if [[ $EUID -eq 0 ]]; then
    tee /etc/systemd/system/amp.service > /dev/null <<EOF
[Unit]
Description=CubeCoders AMP Service
After=network.target

[Service]
Type=simple
User=amp
Group=amp
WorkingDirectory=/opt/amp
ExecStart=/usr/bin/java -jar /opt/amp/AMP.jar
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
else
    sudo tee /etc/systemd/system/amp.service > /dev/null <<EOF
[Unit]
Description=CubeCoders AMP Service
After=network.target

[Service]
Type=simple
User=amp
Group=amp
WorkingDirectory=/opt/amp
ExecStart=/usr/bin/java -jar /opt/amp/AMP.jar
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
fi

# Reload systemd and enable service
log "Enabling AMP service..."
if [[ $EUID -eq 0 ]]; then
    systemctl daemon-reload || error "Failed to reload systemd"
    systemctl enable amp.service || error "Failed to enable AMP service"
else
    sudo systemctl daemon-reload || error "Failed to reload systemd"
    sudo systemctl enable amp.service || error "Failed to enable AMP service"
fi

# Create AMP startup script
log "Creating AMP startup script..."
if [[ $EUID -eq 0 ]]; then
    tee /opt/amp/start-amp.sh > /dev/null <<'EOF'
#!/bin/bash
cd /opt/amp
java -jar AMP.jar
EOF
    chmod +x /opt/amp/start-amp.sh || error "Failed to make startup script executable"
    chown amp:amp /opt/amp/start-amp.sh || error "Failed to set startup script ownership"
else
    sudo tee /opt/amp/start-amp.sh > /dev/null <<'EOF'
#!/bin/bash
cd /opt/amp
java -jar AMP.jar
EOF
    sudo chmod +x /opt/amp/start-amp.sh || error "Failed to make startup script executable"
    sudo chown amp:amp /opt/amp/start-amp.sh || error "Failed to set startup script ownership"
fi

# Create AMP configuration
log "Creating AMP configuration..."
if [[ $EUID -eq 0 ]]; then
    su - amp -c "tee /opt/amp/AMPData/AMPConfig.txt > /dev/null" <<EOF
# AMP Configuration
# Generated by installation script

# Web interface settings
WebInterfacePort=8080
WebInterfaceIP=0.0.0.0

# Security settings
UseSSL=false
SSLPort=8443

# Database settings
UseSQLite=true
DatabasePath=/opt/amp/AMPData/amp.db

# Logging
LogLevel=INFO
LogToFile=true
LogFilePath=/opt/amp/AMPData/logs/

# Performance
MaxMemory=2048
MinMemory=512
EOF
else
    sudo -u amp tee /opt/amp/AMPData/AMPConfig.txt > /dev/null <<EOF
# AMP Configuration
# Generated by installation script

# Web interface settings
WebInterfacePort=8080
WebInterfaceIP=0.0.0.0

# Security settings
UseSSL=false
SSLPort=8443

# Database settings
UseSQLite=true
DatabasePath=/opt/amp/AMPData/amp.db

# Logging
LogLevel=INFO
LogToFile=true
LogFilePath=/opt/amp/AMPData/logs/

# Performance
MaxMemory=2048
MinMemory=512
EOF
fi

# Create logs directory
if [[ $EUID -eq 0 ]]; then
    su - amp -c "mkdir -p /opt/amp/AMPData/logs" || error "Failed to create logs directory"
else
    sudo -u amp mkdir -p /opt/amp/AMPData/logs || error "Failed to create logs directory"
fi

# Create firewall rules (if ufw is available)
if command -v ufw &> /dev/null; then
    log "Configuring firewall rules..."
    if [[ $EUID -eq 0 ]]; then
        ufw allow 8080/tcp || warning "Could not add firewall rule for port 8080"
        ufw allow 8443/tcp || warning "Could not add firewall rule for port 8443"
        ufw allow 25565/tcp || warning "Could not add firewall rule for Minecraft port"
        ufw allow 28015/tcp || warning "Could not add firewall rule for Rust port"
        ufw allow 32330/tcp || warning "Could not add firewall rule for ARK port"
    else
        sudo ufw allow 8080/tcp || warning "Could not add firewall rule for port 8080"
        sudo ufw allow 8443/tcp || warning "Could not add firewall rule for port 8443"
        sudo ufw allow 25565/tcp || warning "Could not add firewall rule for Minecraft port"
        sudo ufw allow 28015/tcp || warning "Could not add firewall rule for Rust port"
        sudo ufw allow 32330/tcp || warning "Could not add firewall rule for ARK port"
    fi
fi

# Start AMP service
log "Starting AMP service..."
if [[ $EUID -eq 0 ]]; then
    systemctl start amp.service || error "Failed to start AMP service"
else
    sudo systemctl start amp.service || error "Failed to start AMP service"
fi

# Wait a moment for AMP to start
sleep 5

# Check if AMP is running
if [[ $EUID -eq 0 ]]; then
    if systemctl is-active --quiet amp.service; then
        log "AMP service is running successfully!"
    else
        warning "AMP service may not be running. Check status with: systemctl status amp"
    fi
else
    if sudo systemctl is-active --quiet amp.service; then
        log "AMP service is running successfully!"
    else
        warning "AMP service may not be running. Check status with: sudo systemctl status amp"
    fi
fi

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Display installation summary
log "Installation completed successfully!"
echo
echo "=========================================="
echo "CubeCoders AMP Installation Complete"
echo "=========================================="
echo
echo "AMP Web Interface: http://$SERVER_IP:8080"
echo "SSL Interface: https://$SERVER_IP:8443"
echo
echo "Default credentials:"
echo "Username: admin"
echo "Password: admin"
echo
echo "Important notes:"
echo "- Change the default password after first login"
echo "- AMP data is stored in /opt/amp/AMPData/"
echo "- Logs are available in /opt/amp/AMPData/logs/"
echo "- Service is configured to start automatically"
echo
echo "Useful commands:"
if [[ $EUID -eq 0 ]]; then
    echo "  Check status: systemctl status amp"
    echo "  Start service: systemctl start amp"
    echo "  Stop service: systemctl stop amp"
    echo "  Restart service: systemctl restart amp"
    echo "  View logs: journalctl -u amp -f"
else
    echo "  Check status: sudo systemctl status amp"
    echo "  Start service: sudo systemctl start amp"
    echo "  Stop service: sudo systemctl stop amp"
    echo "  Restart service: sudo systemctl restart amp"
    echo "  View logs: sudo journalctl -u amp -f"
fi
echo
echo "Supported game servers:"
echo "- Minecraft (Java & Bedrock)"
echo "- Rust"
echo "- ARK: Survival Evolved"
echo "- 7 Days to Die"
echo "- Factorio"
echo "- Valheim"
echo "- And many more..."
echo
echo "For more information, visit: https://cubecoders.com/amp"
echo

# Cleanup
log "Cleaning up installation files..."
rm -f /tmp/AMPInstaller.zip || warning "Could not remove installer file"

log "Installation script completed!"
