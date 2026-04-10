#!/usr/bin/env bash
###########################################
# Install script for AI MCP memory project
###########################################

# Ensure we're running under bash
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash. Please run with:"
    echo "  bash $0"
    echo "  or"
    echo "  curl -fsSL https://example.com/install.sh | bash"
    exit 1
fi

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Detect OS and distribution
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID="${ID}"
        OS_VERSION="${VERSION_ID:-unknown}"
        OS_NAME="${PRETTY_NAME}"
    else
        log_error "Cannot detect OS - /etc/os-release not found"
        exit 1
    fi
    
    log_info "Detected OS: ${OS_NAME}"
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PKG_MGR="apt"
        PKG_UPDATE="apt-get update"
        PKG_INSTALL="apt-get install -y"
    elif command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
        PKG_UPDATE="dnf check-update || true"
        PKG_INSTALL="dnf install -y"
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
        PKG_UPDATE="yum check-update || true"
        PKG_INSTALL="yum install -y"
    elif command -v pacman &> /dev/null; then
        PKG_MGR="pacman"
        PKG_UPDATE="pacman -Sy"
        PKG_INSTALL="pacman -S --noconfirm"
    elif command -v zypper &> /dev/null; then
        PKG_MGR="zypper"
        PKG_UPDATE="zypper refresh"
        PKG_INSTALL="zypper install -y"
    else
        log_error "No supported package manager found"
        exit 1
    fi
    
    log_info "Using package manager: ${PKG_MGR}"
}

# Check if running as root
check_root() {
    if [[ $(id -u) -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Generate random secret
generate_secret() {
    openssl rand -hex 32
}

# Install Docker from official Docker repos
install_docker() {
    log_step "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        log_info "Docker already installed"
        docker --version
        return 0
    fi
    
    case "${PKG_MGR}" in
        apt)
            log_info "Installing Docker on Debian/Ubuntu..."
            
            # Remove old versions
            apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
            
            # Install prerequisites
            ${PKG_INSTALL} ca-certificates curl gnupg lsb-release
            
            # Add Docker's official GPG key
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/${OS_ID}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            chmod a+r /etc/apt/keyrings/docker.gpg
            
            # Set up the repository
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS_ID} \
              $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Install Docker Engine
            ${PKG_UPDATE}
            ${PKG_INSTALL} docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            
        dnf)
            log_info "Installing Docker on Fedora..."
            
            # Remove old versions
            dnf remove -y docker docker-client docker-client-latest docker-common docker-latest \
                docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine 2>/dev/null || true
            
            # Install prerequisites
            ${PKG_INSTALL} dnf-plugins-core
            
            # Add Docker repo
            dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            
            # Install Docker
            ${PKG_INSTALL} docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            
        yum)
            log_info "Installing Docker on RHEL/CentOS..."
            
            # Remove old versions
            yum remove -y docker docker-client docker-client-latest docker-common docker-latest \
                docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine 2>/dev/null || true
            
            # Install prerequisites
            ${PKG_INSTALL} yum-utils
            
            # Add Docker repo
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            
            # Install Docker
            ${PKG_INSTALL} docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            
        *)
            log_error "Docker installation not implemented for ${PKG_MGR}"
            log_info "Please install Docker manually from https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    log_info "Docker installed successfully"
    docker --version
}

# Install git
install_git() {
    log_step "Installing git..."
    
    if command -v git &> /dev/null; then
        log_info "Git already installed"
        git --version
        return 0
    fi
    
    ${PKG_INSTALL} git
    log_info "Git installed successfully"
    git --version
}

# Clone repository and set up compose environment
setup_memory_infrastructure() {
    log_step "Setting up memory infrastructure..."
    
    local INSTALL_DIR="${1:-/srv/ai-memory}"
    local REPO_URL="${2:-https://github.com/ai-memory-project-2026/mcp-memory-stack/}"
    
    # Create installation directory
    log_info "Creating installation directory: ${INSTALL_DIR}"
    mkdir -p "${INSTALL_DIR}"
    cd "${INSTALL_DIR}"
    
    # Clone repository
    if [[ -d "${INSTALL_DIR}/.git" ]]; then
        log_info "Repository already exists, pulling latest changes..."
        git pull
    else
        log_info "Cloning repository from ${REPO_URL}..."
        git clone "${REPO_URL}" .
    fi

    # Clone AuthMCP Gateway
    log_info "Cloning additional sources..."
    git clone https://github.com/loglux/authmcp-gateway
    
    # Generate secrets
    log_info "Generating secrets..."
    JWT_SECRET_KEY=$(generate_secret)
    
    # MCP Memory Service
    MCP_API_KEY=$(generate_secret)
    MCP_OAUTH_SECRET_KEY=$(generate_secret)

    # AuthMCP Gateway config
    cat > ./authmcp-gateway/.env <<EOF
# JWT Configuration
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# Admin Panel Configuration
ADMIN_TOKEN_EXPIRE_MINUTES=480    # 8 hours admin session

# Gateway Configuration
GATEWAY_PORT=9105                    # Docker port (change if needed)
AUTH_REQUIRED=true
ALLOW_INSECURE_HTTP=false            # Allow HTTP (not recommended for production)
DISABLE_DNS_REBINDING=false          # Disable DNS rebinding protection

# Database
AUTH_SQLITE_PATH=/app/data/users.db

# User Management
ALLOW_REGISTRATION=false

# Password Policy
PASSWORD_MIN_LENGTH=16
PASSWORD_REQUIRE_UPPERCASE=true
PASSWORD_REQUIRE_LOWERCASE=true
PASSWORD_REQUIRE_DIGIT=true
PASSWORD_REQUIRE_SPECIAL=true

# Optional: Static tokens for backward compatibility
# STATIC_BEARER_TOKEN=
# STATIC_BEARER_TOKENS=

# Request timeout
REQUEST_TIMEOUT_SECONDS=30

# Backend Token Management
MCP_TOKEN_REFRESH_INTERVAL=300       # Check every 5 minutes
MCP_TOKEN_REFRESH_THRESHOLD=5        # Refresh if expires within 5 minutes

# Logging
LOG_LEVEL=INFO
# MCP request logging
MCP_LOG_DB_ENABLED=true
# DB log retention and size limits
MCP_LOG_DB_DAYS_TO_KEEP=30
MCP_LOG_DB_MAX_MB=200
MCP_LOG_DB_MAX_ROWS=200000
MCP_LOG_DB_CHECK_INTERVAL_SECONDS=300

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_LOGIN_MAX=5
RATE_LIMIT_LOGIN_WINDOW=60
RATE_LIMIT_REGISTER_MAX=3
RATE_LIMIT_REGISTER_WINDOW=300
RATE_LIMIT_MCP_MAX=100
RATE_LIMIT_MCP_WINDOW=60
RATE_LIMIT_CLEANUP_INTERVAL=3600

EOF
    chmod 600 ./authmcp-gateway/.env

    
    # Create .env file
    log_info "Creating .env file..."
    cat > .env <<EOF
# Memory Infrastructure Configuration
# Generated on $(date)

# Cloudflare tunnel token
TUNNEL_TOKEN=${TUNNEL_TOKEN:-empty}

# AuthMCP gateway
JWT_SECRET_KEY=${JWT_SECRET_KEY}
MCP_PUBLIC_URL=https://mcp.${DOMAIN}
ALLOWED_ORIGINS=https://mcp.${DOMAIN},http://localhost:9105

# MCP memory service config
MCP_API_KEY=${MCP_API_KEY}
MCP_OAUTH_SECRET_KEY=${MCP_OAUTH_SECRET_KEY}

# Additional configuration
DOMAIN=${DOMAIN:-empty}
INSTALL_DIR=${INSTALL_DIR}

EOF

    chmod 600 .env
    
    log_info ".env file created successfully"
    log_warn "Secrets have been generated - please backup .env file securely"
}

# Start the infrastructure
start_infrastructure() {
    log_step "Starting memory infrastructure..."
    
    local INSTALL_DIR="${1:-/srv/ai-memory}"
    cd "${INSTALL_DIR}"
    
    if [[ ! -f docker-compose.yml ]]; then
        log_error "docker-compose.yml not found in ${INSTALL_DIR}"
        exit 1
    fi
    
    log_info "Starting containers..."
    docker compose up -d
    
    log_info "Checking container status..."
    docker compose ps
}

# Main execution
main() {
    log_info "========================================="
    log_info "   Memory Infrastructure Setup Script   "
    log_info "========================================="
    echo
    
    # Parse arguments
    local INSTALL_DIR="${1:-/srv/ai-memory}"
    local REPO_URL="${2:-https://github.com/ai-memory-project-2026/mcp-memory-stack/}"
    
    check_root
    detect_os
    detect_package_manager
    
    echo
    install_git
    echo
    install_docker
    echo
    setup_memory_infrastructure "${INSTALL_DIR}" "${REPO_URL}"
    echo
    start_infrastructure "${INSTALL_DIR}"
    
    echo
    log_info "========================================="
    log_info "Setup completed successfully!"
    log_info "Installation directory: ${INSTALL_DIR}"
    log_info "========================================="
    log_warn "Please backup the .env file containing your secrets"
    log_info "To view logs: docker compose -f ${INSTALL_DIR}/docker-compose.yml logs -f"
}

# Run main function
main "$@"
