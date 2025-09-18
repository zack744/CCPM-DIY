# Testing Prime Script 设计文档

## 脚本架构

### 全局变量
```bash
# 检测结果
DETECTED_FRAMEWORK=""
TEST_COMMAND=""
TEST_DIRECTORY=""
CONFIG_FILE=""
FRAMEWORK_VERSION=""
TEST_COUNT=0
PROJECT_TYPE=""
ERROR_COUNT=0

# 配置选项
VERBOSE=true
REAL_DATETIME=""
```

### 核心函数模块

#### 1. 初始化模块
```bash
init_script() {
    # 设置颜色和emoji
    # 获取真实时间戳
    # 创建必要目录
}

setup_colors() {
    # 定义输出颜色
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
}
```

#### 2. 日志输出模块
```bash
log_info() { echo -e "${GREEN}✅${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
log_error() { echo -e "${RED}❌${NC} $1"; ERROR_COUNT=$((ERROR_COUNT + 1)); }
log_step() { echo -e "${BLUE}🔍${NC} $1"; }
```

#### 3. 框架检测模块
```bash
detect_javascript_framework() {
    # 检查 package.json
    # 查找 jest.config.*, .mocharc.*
    # 检测测试目录
    # 返回：jest|mocha|其他|未找到
}

detect_python_framework() {
    # 查找 pytest.ini, conftest.py
    # 检查 requirements.txt
    # 查找 test_*.py 文件
    # 返回：pytest|unittest|未找到
}

detect_rust_framework() {
    # 检查 Cargo.toml
    # 查找 #[cfg(test)] 模块
    # 返回：cargo|未找到
}

detect_go_framework() {
    # 查找 *_test.go
    # 检查 go.mod
    # 返回：go|未找到
}

detect_other_frameworks() {
    # Ruby: .rspec, spec_helper.rb
    # Java: pom.xml + junit
    # 返回：rspec|junit|未找到
}
```

#### 4. 依赖验证模块
```bash
validate_nodejs_deps() {
    # npm list --depth=0 检查
    # 检查 jest, mocha, chai 等
}

validate_python_deps() {
    # pip list 检查
    # 检查 pytest, unittest 等
}

validate_dependencies() {
    # 根据检测到的框架调用对应验证函数
}
```

#### 5. 测试发现模块
```bash
discover_tests() {
    # 扫描测试文件
    # 统计数量
    # 识别命名模式
    # 检查测试工具和fixture
}

count_test_files() {
    case $DETECTED_FRAMEWORK in
        "jest"|"mocha")
            find . -path "*/node_modules" -prune -o -name "*.test.js" -o -name "*.spec.js" | wc -l
            ;;
        "pytest")
            find . -name "test_*.py" -o -name "*_test.py" | wc -l
            ;;
        *)
            echo "0"
            ;;
    esac
}
```

#### 6. 配置生成模块
```bash
generate_framework_config() {
    case $DETECTED_FRAMEWORK in
        "jest")
            cat > /tmp/framework_config.yml << EOF
framework: jest
test_command: npm test
test_directory: __tests__
config_file: jest.config.js
options:
  - --verbose
  - --no-coverage
  - --runInBand
environment:
  NODE_ENV: test
EOF
            ;;
        "pytest")
            cat > /tmp/framework_config.yml << EOF
framework: pytest
test_command: pytest
test_directory: tests
config_file: pytest.ini
options:
  - -v
  - --tb=short
  - --strict-markers
environment:
  PYTHONPATH: .
EOF
            ;;
        # 其他框架...
    esac
}

create_testing_config() {
    # 创建 .claude/testing-config.md
    # 包含完整的配置信息
    # 使用真实时间戳
}
```

#### 7. 验证模块
```bash
validate_setup() {
    # 尝试运行简单的测试命令验证
    # 检查权限问题
    # 验证配置文件正确性
}
```

#### 8. 用户交互模块
```bash
ask_user_for_test_command() {
    echo "⚠️ 未检测到测试框架。请指定您的测试设置。"
    echo "您使用什么测试命令？(例如: npm test, pytest, cargo test)"
    read -r user_command
    # 验证和存储用户输入
}

confirm_overwrite() {
    echo "⚠️ 找到 $1 个现有的上下文文件。是否覆盖所有上下文？(yes/no)"
    read -r response
    [[ "$response" == "yes" ]]
}
```

#### 9. 主流程控制
```bash
main() {
    init_script
    
    log_info "🧪 测试环境准备中"
    log_info "======================================"
    
    # 1. 框架检测
    detect_all_frameworks
    
    # 2. 依赖验证  
    validate_dependencies
    
    # 3. 测试发现
    discover_tests
    
    # 4. 配置生成
    create_testing_config
    
    # 5. 验证设置
    validate_setup
    
    # 6. 显示摘要
    show_final_summary
}
```

## 实现复杂度评估

### 🔴 高复杂度部分
1. **多框架检测逻辑** - 需要精确的文件和内容检查
2. **跨平台命令差异** - Windows/Unix路径和命令处理
3. **YAML配置生成** - 格式化和模板系统

### 🟡 中等复杂度部分  
1. **依赖验证** - 包管理器命令调用
2. **测试文件统计** - 文件系统遍历和模式匹配
3. **用户交互** - 输入验证和错误处理

### 🟢 低复杂度部分
1. **日志系统** - 标准化输出格式
2. **目录创建** - 基础文件操作
3. **时间戳获取** - 系统命令调用

## 实现策略

### Phase 1: 核心框架 (MVP)
- 基础日志系统
- JavaScript/Node.js 检测
- 简单配置生成

### Phase 2: 多语言支持
- Python 检测
- Rust/Go 检测  
- 完整配置模板

### Phase 3: 增强功能
- 完整错误处理
- 用户交互优化
- 跨平台优化

## 预估实现时间
- 核心框架: ~100行代码
- 完整实现: ~300-400行代码
- 测试和调试: 额外时间

这个设计确保了代码的可维护性和可扩展性，同时处理了所有复杂的需求。