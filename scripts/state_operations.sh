#!/bin/bash
# Terraform State Operations Toolkit
# Advanced state management operations for enterprise deployments

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    local title="$1"
    echo -e "${BLUE}"
    echo "=================================================================="
    echo "🔧 $title"
    echo "=================================================================="
    echo -e "${NC}"
}

check_state_backend() {
    print_header "STATE BACKEND VERIFICATION"
    
    echo -e "${YELLOW}🔍 Checking Terraform backend configuration...${NC}"
    
    # Check if backend is configured
    if terraform init -backend=false &> /dev/null; then
        echo -e "${GREEN}✅ Backend configuration is valid${NC}"
    else
        echo -e "${RED}❌ Backend configuration error${NC}"
        return 1
    fi
    
    # Show backend info
    echo -e "${BLUE}📊 Backend Information:${NC}"
    terraform init -backend=false
    
    # Check state accessibility
    if terraform state list &> /dev/null; then
        echo -e "${GREEN}✅ Remote state is accessible${NC}"
        local resource_count=$(terraform state list | wc -l)
        echo -e "${BLUE}📈 Resources in state: $resource_count${NC}"
    else
        echo -e "${RED}❌ Cannot access remote state${NC}"
        return 1
    fi
}

backup_state() {
    print_header "STATE BACKUP OPERATIONS"
    
    local backup_dir="./backups/state"
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local backup_file="$backup_dir/terraform-state-$timestamp.json"
    
    echo -e "${YELLOW}💾 Creating state backup...${NC}"
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Pull current state
    terraform state pull > "$backup_file"
    
    echo -e "${GREEN}✅ State backup created: $backup_file${NC}"
    echo -e "${BLUE}📊 Backup size: $(du -h "$backup_file" | cut -f1)${NC}"
    
    # List recent backups
    echo -e "${BLUE}📂 Recent backups:${NC}"
    ls -lht "$backup_dir" | head -5
}

analyze_state() {
    print_header "STATE ANALYSIS"
    
    echo -e "${YELLOW}📊 Analyzing Terraform state...${NC}"
    
    # Resource count by type
    echo -e "${BLUE}📈 Resource distribution:${NC}"
    terraform state list | cut -d'.' -f1 | sort | uniq -c | sort -nr
    
    # State file size analysis
    local state_size=$(terraform state pull | wc -c)
    echo -e "${BLUE}📦 State file size: $(echo $state_size | numfmt --to=iec-i --suffix=B)${NC}"
    
    # Check for large resources
    echo -e "${BLUE}🔍 Resource complexity analysis:${NC}"
    terraform show -json | jq -r '.values.root_module.resources[] | "\(.address): \(.values | keys | length) attributes"' | sort -k2 -nr | head -10
    
    # Identify potential issues
    echo -e "${BLUE}⚠️  Potential state issues:${NC}"
    terraform validate
    
    # Check for state drift
    echo -e "${BLUE}🔄 State drift analysis:${NC}"
    if terraform plan -detailed-exitcode -out=tfplan &> /dev/null; then
        case $? in
            0) echo -e "${GREEN}✅ No changes detected - state matches infrastructure${NC}" ;;
            1) echo -e "${RED}❌ Error in plan - check configuration${NC}" ;;
            2) echo -e "${YELLOW}⚠️  Changes detected - infrastructure drift identified${NC}" ;;
        esac
    fi
    
    # Clean up plan file
    rm -f tfplan
}

optimize_state() {
    print_header "STATE OPTIMIZATION"
    
    echo -e "${YELLOW}🔧 Optimizing Terraform state...${NC}"
    
    # Backup before optimization
    backup_state
    
    # Remove unused data sources from state (if any)
    echo -e "${BLUE}🧹 Checking for optimization opportunities...${NC}"
    
    # Identify data sources in state (these shouldn't be there)
    local data_resources=$(terraform state list | grep "^data\." || true)
    if [ -n "$data_resources" ]; then
        echo -e "${YELLOW}⚠️  Found data sources in state (these will be removed):${NC}"
        echo "$data_resources"
        
        # Remove data sources from state
        echo "$data_resources" | xargs -I {} terraform state rm {}
        echo -e "${GREEN}✅ Data sources removed from state${NC}"
    else
        echo -e "${GREEN}✅ No optimization needed - state is clean${NC}"
    fi
    
    # Refresh state to ensure consistency
    echo -e "${BLUE}🔄 Refreshing state from infrastructure...${NC}"
    terraform refresh
    
    echo -e "${GREEN}✅ State optimization complete${NC}"
}

import_existing_resource() {
    print_header "RESOURCE IMPORT OPERATIONS"
    
    local resource_address="$1"
    local azure_resource_id="$2"
    
    echo -e "${YELLOW}📥 Importing existing Azure resource...${NC}"
    echo -e "${BLUE}Resource Address: $resource_address${NC}"
    echo -e "${BLUE}Azure Resource ID: $azure_resource_id${NC}"
    
    # Backup state before import
    backup_state
    
    # Import the resource
    if terraform import "$resource_address" "$azure_resource_id"; then
        echo -e "${GREEN}✅ Resource imported successfully${NC}"
        
        # Verify import
        terraform plan -target="$resource_address"
        
        echo -e "${BLUE}📊 Imported resource details:${NC}"
        terraform state show "$resource_address"
    else
        echo -e "${RED}❌ Resource import failed${NC}"
        return 1
    fi
}

state_surgery() {
    print_header "STATE SURGERY OPERATIONS"
    
    echo -e "${RED}⚠️  WARNING: These are advanced operations that modify state directly${NC}"
    echo -e "${YELLOW}Always backup state before performing surgery operations${NC}"
    
    echo "Available operations:"
    echo "  1. Remove corrupted resource"
    echo "  2. Move resource to different address"
    echo "  3. Replace provider"
    echo "  4. Force unlock state"
    echo "  5. List all resources"
    
    read -p "Select operation (1-5): " operation
    
    case $operation in
        1)
            read -p "Enter resource address to remove: " resource_addr
            backup_state
            terraform state rm "$resource_addr"
            echo -e "${GREEN}✅ Resource removed from state${NC}"
            ;;
        2)
            read -p "Enter source resource address: " source_addr
            read -p "Enter destination resource address: " dest_addr
            backup_state
            terraform state mv "$source_addr" "$dest_addr"
            echo -e "${GREEN}✅ Resource moved in state${NC}"
            ;;
        3)
            read -p "Enter old provider: " old_provider
            read -p "Enter new provider: " new_provider
            backup_state
            terraform state replace-provider "$old_provider" "$new_provider"
            echo -e "${GREEN}✅ Provider replaced in state${NC}"
            ;;
        4)
            read -p "Enter lock ID (or 'auto' to detect): " lock_id
            if [ "$lock_id" = "auto" ]; then
                # Try to detect lock ID from error
                lock_id=$(terraform plan 2>&1 | grep -oP 'lock ID \K[a-f0-9-]+' | head -1 || echo "")
                if [ -z "$lock_id" ]; then
                    echo -e "${RED}❌ Could not detect lock ID automatically${NC}"
                    return 1
                fi
                echo -e "${BLUE}Detected lock ID: $lock_id${NC}"
            fi
            terraform force-unlock "$lock_id"
            echo -e "${GREEN}✅ State unlocked${NC}"
            ;;
        5)
            echo -e "${BLUE}📊 All resources in state:${NC}"
            terraform state list
            ;;
        *)
            echo -e "${RED}❌ Invalid operation${NC}"
            return 1
            ;;
    esac
}

monitor_state_health() {
    print_header "STATE HEALTH MONITORING"
    
    echo -e "${YELLOW}🏥 Performing comprehensive state health check...${NC}"
    
    # Check 1: Backend accessibility
    echo -e "${BLUE}1. Backend Accessibility${NC}"
    if terraform state list &> /dev/null; then
        echo -e "  ${GREEN}✅ State backend is accessible${NC}"
    else
        echo -e "  ${RED}❌ Cannot access state backend${NC}"
    fi
    
    # Check 2: State lock status
    echo -e "${BLUE}2. State Lock Status${NC}"
    if terraform plan -lock=false &> /dev/null; then
        echo -e "  ${GREEN}✅ State is not locked${NC}"
    else
        echo -e "  ${YELLOW}⚠️  State may be locked${NC}"
    fi
    
    # Check 3: Configuration validity
    echo -e "${BLUE}3. Configuration Validation${NC}"
    if terraform validate &> /dev/null; then
        echo -e "  ${GREEN}✅ Configuration is valid${NC}"
    else
        echo -e "  ${RED}❌ Configuration has errors${NC}"
        terraform validate
    fi
    
    # Check 4: State consistency
    echo -e "${BLUE}4. State Consistency${NC}"
    terraform plan -detailed-exitcode &> /dev/null
    case $? in
        0) echo -e "  ${GREEN}✅ State matches infrastructure${NC}" ;;
        1) echo -e "  ${RED}❌ Configuration errors detected${NC}" ;;
        2) echo -e "  ${YELLOW}⚠️  Infrastructure drift detected${NC}" ;;
    esac
    
    # Check 5: State file integrity
    echo -e "${BLUE}5. State File Integrity${NC}"
    if terraform state pull | jq . &> /dev/null; then
        echo -e "  ${GREEN}✅ State file is valid JSON${NC}"
    else
        echo -e "  ${RED}❌ State file is corrupted${NC}"
    fi
    
    # Summary
    echo -e "${GREEN}🎉 State health check complete${NC}"
}

usage() {
    echo "Terraform State Operations Toolkit"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  check       - Verify state backend configuration"
    echo "  backup      - Create state backup"
    echo "  analyze     - Analyze state composition and health"
    echo "  optimize    - Optimize state file"
    echo "  import      - Import existing Azure resource"
    echo "  surgery     - Advanced state modification operations"
    echo "  monitor     - Comprehensive state health monitoring"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 backup                    # Create state backup"
    echo "  $0 analyze                   # Analyze current state"
    echo "  $0 import resource_addr id   # Import existing resource"
    echo "  $0 monitor                   # Check state health"
}

main() {
    case "${1:-}" in
        "check")
            check_state_backend
            ;;
        "backup")
            backup_state
            ;;
        "analyze")
            analyze_state
            ;;
        "optimize")
            optimize_state
            ;;
        "import")
            if [ $# -lt 3 ]; then
                echo -e "${RED}❌ Import requires resource address and Azure resource ID${NC}"
                echo "Usage: $0 import <resource_address> <azure_resource_id>"
                exit 1
            fi
            import_existing_resource "$2" "$3"
            ;;
        "surgery")
            state_surgery
            ;;
        "monitor")
            monitor_state_health
            ;;
        "help"|"--help"|"-h"|"")
            usage
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            usage
            exit 1
            ;;
    esac
}

main "$@"