# 开发文档

## 更新 Detect-It-Easy 依赖流程

本项目通过 `die_library` 间接依赖 `Detect-It-Easy`。当需要更新到最新版本时，按以下步骤操作。

### 1. 更新 die_library 版本

#### 1.1 获取最新提交哈希

```bash
git ls-remote https://github.com/horsicq/die_library HEAD
```

输出示例：
```
c8e482de7eac7d7f3621967cb3ac0d98f179b8cb	HEAD
```

#### 1.2 更新 CMake 配置

编辑 `cmake/FindDieLibrary.cmake` 文件，更新 `GIT_TAG` 字段：

```cmake
FetchContent_Declare(
  DieLibrary
  GIT_REPOSITORY "https://github.com/horsicq/die_library"
  GIT_TAG <最新提交哈希>
)
```

### 2. 检查 Detect-It-Easy 版本

`die_library` 使用 git submodule 管理 `Detect-It-Easy` 依赖。子模块的版本由 `die_library` 仓库决定，无法直接修改。

如需检查当前版本：

```bash
# 临时克隆 die_library 仓库
git clone --depth 1 https://github.com/horsicq/die_library temp_check
cd temp_check

# 查看 Detect-It-Easy 子模块版本
git ls-tree HEAD dep/Detect-It-Easy

# 获取 Detect-It-Easy 最新版本
git ls-remote https://github.com/horsicq/Detect-It-Easy HEAD

# 清理临时目录
cd ..
rm -rf temp_check
```

### 3. 安装 Qt 依赖

项目需要 Qt 6.7.3 作为构建依赖。使用 `aqtinstall` 工具安装：

#### 3.1 安装 aqtinstall

```bash
python -m pip install aqtinstall --user -U
```

#### 3.2 安装 Qt

根据平台选择对应的命令：

**Windows (MSVC 2019 64位):**
```bash
python -m aqt install-qt -O ./build windows desktop 6.7.3 win64_msvc2019_64
```

Qt 将安装到 `build/6.7.3/<编译器>/` 目录下。

### 4. 网络配置（如需要）

如果网络环境无法直接访问 GitHub，需要配置 Git 代理：

### 5. 清理构建缓存

更新依赖后，建议清理旧的构建缓存：

```bash
# 清理 scikit-build 缓存
rm -rf _skbuild
rm -rf build/cp*

# 清理 Python 包信息
rm -rf *.egg-info
```

### 6. 编译 Python Bindings

使用 `uv` 进行构建和安装：

```bash
# 同步依赖并构建
uv sync

# 验证安装
uv run python -c "import die; print(die.__version__)"
```

### 7. 验证更新

构建完成后，可以通过以下方式验证：

```python
import die

# 检查版本信息
print(f"DIE Version: {die.DIE_VERSION}")
print(f"DieLibrary Version: {die.DIELIB_VERSION}")

# 测试基本功能
result = die.scan_file("000df88e1d44567244c206012c102034f59c3340", die.ScanFlags.DEEP_SCAN)
print(result)
```

### 注意事项

1. **子模块版本限制**: `Detect-It-Easy` 的版本由 `die_library` 仓库控制，无法直接指定。如需使用最新版本的 `Detect-It-Easy`，需要等待 `die_library` 更新其子模块引用。

2. **Qt 版本要求**: 当前项目固定使用 Qt 6.7.3，修改版本需要同步更新 `cmake/FindDieLibrary.cmake` 中的 `QT_BUILD_VERSION` 变量。

3. **编译器要求**: Windows 平台建议使用 Visual Studio 2019 或更高版本。根据项目注释，VS2022 在构建 nanobind 时可能存在编译器崩溃问题。

4. **网络环境**: 如果使用代理，确保代理在构建过程中保持可用。构建完成后可移除代理配置。

