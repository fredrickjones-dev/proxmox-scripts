# CubeCoders AMP Installer

Automated installation script for [CubeCoders AMP](https://cubecoders.com/amp) (Application Management Panel) - a powerful game server management platform.

## 🎮 What is AMP?

CubeCoders AMP is a web-based application that allows you to manage multiple game servers from a single interface. It supports a wide variety of games including:

- **Minecraft** (Java & Bedrock)
- **Rust**
- **ARK: Survival Evolved**
- **7 Days to Die**
- **Factorio**
- **Valheim**
- **And many more...**

## 🚀 Quick Installation

### One-liner Installation
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/amp-installer/main/install-amp.sh | bash
```

### Manual Installation
```bash
# Download the script
wget https://raw.githubusercontent.com/YOUR_USERNAME/amp-installer/main/install-amp.sh

# Make it executable
chmod +x install-amp.sh

# Run the installation
./install-amp.sh
```

## 📋 System Requirements

- **OS:** Ubuntu 18.04+ or Debian 9+
- **RAM:** Minimum 2GB, recommended 4GB+
- **Storage:** At least 10GB free space
- **Network:** Stable internet connection
- **User:** Non-root user with sudo privileges

## 🔧 What the Script Does

The installation script automatically:

1. **Updates system packages**
2. **Installs dependencies** (Java, Python, build tools)
3. **Creates dedicated AMP user** for security
4. **Downloads and installs AMP** from official source
5. **Configures systemd service** for automatic startup
6. **Sets up firewall rules** for common game ports
7. **Creates initial configuration**
8. **Starts AMP service**

## 🌐 Accessing AMP

After installation, access AMP via:

- **Web Interface:** `http://your-server-ip:8080`
- **SSL Interface:** `https://your-server-ip:8443`

### Default Credentials
- **Username:** `admin`
- **Password:** `admin`

**⚠️ Important:** Change the default password after first login!

## 🛠️ Management Commands

```bash
# Check AMP status
sudo systemctl status amp

# Start AMP service
sudo systemctl start amp

# Stop AMP service
sudo systemctl stop amp

# Restart AMP service
sudo systemctl restart amp

# View AMP logs
sudo journalctl -u amp -f

# View real-time logs
sudo tail -f /opt/amp/AMPData/logs/AMP.log
```

## 📁 Important Directories

```bash
# AMP installation directory
/opt/amp/

# AMP data and configuration
/opt/amp/AMPData/

# AMP logs
/opt/amp/AMPData/logs/

# AMP user home
/home/amp/
```

## 🔧 Configuration

AMP configuration is stored in `/opt/amp/AMPData/AMPConfig.txt`. Key settings:

- **Web Interface Port:** 8080
- **SSL Port:** 8443
- **Database:** SQLite (default)
- **Memory:** 512MB-2048MB

## 🎯 Creating Game Servers

1. Login to AMP web interface
2. Click "Create Instance"
3. Choose your game type
4. Configure server settings
5. Start your server

## 🔒 Security Features

- Runs as dedicated `amp` user (not root)
- Automatic firewall configuration
- Secure file permissions
- SSL support (optional)

## 🐛 Troubleshooting

### Common Issues

**AMP won't start:**
```bash
# Check service status
sudo systemctl status amp

# View detailed logs
sudo journalctl -u amp -n 50

# Check Java installation
java -version
```

**Can't access web interface:**
```bash
# Check if port is open
sudo netstat -tlnp | grep :8080

# Check firewall
sudo ufw status

# Restart AMP service
sudo systemctl restart amp
```

**Permission issues:**
```bash
# Fix AMP directory permissions
sudo chown -R amp:amp /opt/amp
sudo chmod -R 755 /opt/amp
```

## 🗑️ Uninstallation

To completely remove AMP:

```bash
# Stop and disable service
sudo systemctl stop amp
sudo systemctl disable amp

# Remove service file
sudo rm /etc/systemd/system/amp.service

# Remove AMP files
sudo rm -rf /opt/amp

# Remove AMP user
sudo userdel -r amp

# Reload systemd
sudo systemctl daemon-reload
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [CubeCoders](https://cubecoders.com/) for creating AMP
- The open-source community for inspiration and feedback

## 📞 Support

- **AMP Documentation:** https://docs.cubecoders.com/
- **CubeCoders Support:** https://cubecoders.com/support
- **GitHub Issues:** [Create an issue](https://github.com/YOUR_USERNAME/amp-installer/issues)

---

**⭐ If this script helped you, please give it a star!** 