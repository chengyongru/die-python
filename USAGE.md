# 使用说明

本文档介绍如何在其他项目或环境中使用本仓库。

## 方式一：从 GitHub 克隆并安装（推荐用于开发）

### 1. 克隆仓库

```bash
git clone https://github.com/chengyongru/die-python
cd die-python
```

### 2. 安装 Qt 依赖

根据你的操作系统选择对应的命令：

**Windows (MSVC 2019 64位):**
```bash
python -m pip install aqtinstall --user -U
python -m aqt install-qt -O ./build windows desktop 6.7.3 win64_msvc2019_64
```

**Linux (x64):**
```bash
python -m pip install aqtinstall --user -U
python -m aqt install-qt -O ./build linux desktop 6.7.3 linux_gcc_64
```

**Linux (ARM64):**
```bash
python -m pip install aqtinstall --user -U
python -m aqt install-qt -O ./build linux desktop 6.7.3 linux_gcc_arm64
```

**macOS:**
```bash
python -m pip install aqtinstall --user -U
python -m aqt install-qt -O ./build mac desktop 6.7.3 clang_64
```

### 3. 安装 Python 包

**使用 uv（推荐）:**
```bash
uv sync
```

**使用 pip:**
```bash
python -m pip install . --user -U
```

### 4. 验证安装

```python
import die
print(f"die version: {die.__version__}")
```

## 方式二：使用 pip 直接从 Git 安装

### 安装最新版本

```bash
pip install git+https://github.com/chengyongru/die-python.git
```

**注意：** 这种方式需要目标机器已安装 Qt 6.7.3 到 `build/` 目录，或者配置了系统级的 Qt 环境变量。

## 方式三：使用 uv 从 Git 安装

如果你的项目使用 `uv` 管理依赖，可以在 `pyproject.toml` 中添加：

```toml
[project]
dependencies = [
    "die-python @ git+https://github.com/chengyongru/die-python.git",
]
```

然后运行：
```bash
uv sync
```

## 方式四：作为开发依赖安装（可编辑模式）

如果你需要修改代码并实时看到效果：

```bash
# 克隆仓库
git clone https://github.com/chengyongru/die-python
cd die-python

# 安装 Qt（参考方式一）

# 以可编辑模式安装
pip install -e . --user
# 或使用 uv
uv pip install -e .
```

## 方式五：构建 Wheel 包分发

如果你需要将构建好的包分发给其他机器：

### 1. 构建 Wheel

```bash
# 使用 uv
$env:DIE_QT_ROOT = ".\die-python\build"

uv build

```

构建产物位于 `dist/` 目录。

### 2. 安装 Wheel

```bash
pip install dist/die_python-0.5.0-*.whl
```

**注意：** Wheel 包包含编译好的二进制文件，但需要目标机器有对应的 Qt 运行时库。

## 网络配置

如果网络环境无法直接访问 GitHub，需要配置 Git 代理：

```bash
# 设置代理
git config --global http.proxy http://127.0.0.1:23458
git config --global https.proxy http://127.0.0.1:23458

# 安装完成后可取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

## 在其他项目中使用

### 基本使用示例

```python
import die
import pathlib

# 扫描文件类型
file_type = die.scan_file("path/to/file.exe", die.ScanFlags.DEEP_SCAN)
print(f"File type: {file_type}")

# 获取详细扫描结果（JSON 格式）
result_json = die.scan_file(
    "path/to/file.exe", 
    die.ScanFlags.RESULT_AS_JSON,
    str(die.database_path / 'db')
)
print(result_json)

# 列出所有数据库文件
for db in die.databases():
    print(db)
```

### 在 requirements.txt 中使用

```txt
# 从 Git 安装
die-python @ git+https://github.com/chengyongru/die-python.git@main

# 或指定版本（如果有发布到 PyPI）
# die-python==0.5.0
```

### 在 pyproject.toml 中使用

```toml
[project]
dependencies = [
    "die-python @ git+https://github.com/chengyongru/die-python.git",
]

# 或使用 uv
[tool.uv.sources]
die-python = { git = "https://github.com/chengyongru/die-python.git", branch = "main" }
```

## 系统要求

- **Python**: >= 3.9
- **CMake**: >= 3.20
- **Qt**: 6.7.3
- **编译器**:
  - Windows: Visual Studio 2019 或更高版本
  - Linux: GCC
  - macOS: Clang

## 常见问题

### Q: 安装时提示找不到 Qt

A: 确保已按照方式一的步骤安装 Qt 到 `build/` 目录，或配置系统环境变量指向 Qt 安装路径。

### Q: 从 Git 安装时构建失败

A: 从 Git 安装需要完整的构建环境（CMake、编译器、Qt）。建议先在本地构建 Wheel 包，然后分发安装。

### Q: 如何更新到最新版本

A: 如果使用 Git 安装：
```bash
pip install --upgrade --force-reinstall git+https://github.com/chengyongru/die-python.git
```

如果使用本地克隆：
```bash
cd die-python
git pull origin main
pip install -e . --upgrade
```

### Q: 跨平台使用

A: Wheel 包是平台特定的。Windows 构建的包只能在 Windows 上使用。需要在目标平台重新构建，或使用 CI/CD 为各平台构建对应的 Wheel 包。

## 相关文档

- [开发文档](Development.md) - 更新依赖和构建流程
- [README.md](README.md) - 项目基本信息和快速开始

