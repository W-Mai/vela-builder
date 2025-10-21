# AGENTS.md - Vela Builder 项目指南

## 项目概述

**Vela Builder** 是一个为 [OpenVela](https://github.com/open-vela/) 项目提供的**临时编译环境包装器**。它通过 Podman 容器技术,为 Vela 项目的编译构建提供一个隔离、可复现的编译环境,**用完即销毁**,无需在本地安装复杂的工具链和依赖。

### 核心设计理念

1. **临时性**:容器不是长期运行的开发环境,而是按需创建、用完即删除的临时编译环境
2. **透明性**:用户在容器内的工作目录与宿主机完全一致,无需关心路径映射
3. **智能复用**:如果同名容器已存在则直接进入,否则创建新容器
4. **零配置**:无需手动管理容器生命周期,一个命令搞定所有操作

### 主要技术栈

- **容器运行时**: Podman(非 Docker)
- **基础镜像**: Ubuntu 22.04(使用阿里云镜像加速)
- **镜像仓库**: ghcr.io/w-mai/vela-builder
- **编译工具链**: GCC 9/11/13、Python 3、Node.js、CMake、Ninja 等
- **目标平台**: x86_64 和 i386 交叉编译支持

## 使用方式

### 前置要求

必须安装 Podman:

```bash
# Debian/Ubuntu
sudo apt update && sudo apt install -y podman

# Arch Linux
sudo pacman -S podman
# 或使用 AUR
paru -S podman

# macOS
brew install podman
```

### 安装 vela-builder 命令

根据你使用的 Shell 选择对应的安装方式:

#### Bash 用户

```bash
cp commands/vela-builder.sh ~/.local/bin/vela-builder
chmod +x ~/.local/bin/vela-builder
```

#### Fish 用户

```bash
cp commands/vela-builder.fish ~/.config/fish/functions/
```

### 使用场景

#### 场景 1:进入交互式编译环境

在 OpenVela 项目目录下执行:

```bash
cd /path/to/openvela
vela-builder
```

这会:
- 检查是否存在名为 `vela-builder-openvela` 的容器
- 如果存在,直接 `exec` 进入该容器
- 如果不存在,创建新容器并进入
- 容器内的工作目录与宿主机当前目录完全一致
- 退出容器后,容器自动删除(`--rm` 标志)

#### 场景 2:直接执行命令

无需进入容器,直接在容器内执行命令:

```bash
# 查看容器内的系统信息
vela-builder "uname -a"

# 执行编译命令
vela-builder "make menuconfig"
vela-builder "./build.sh"

# 运行测试
vela-builder "pytest tests/"
```

这种方式适合:
- CI/CD 流水线
- 自动化脚本
- 快速验证命令

## 容器特性详解

### 容器命名规则

容器名称格式:`vela-builder-<当前目录名>`

例如:
- 在 `/home/user/openvela` 目录下运行 → 容器名为 `vela-builder-openvela`
- 在 `/home/user/vela-fork` 目录下运行 → 容器名为 `vela-builder-vela-fork`

这样设计的好处:
- 不同项目目录使用不同的容器实例,互不干扰
- 同一项目目录下多次调用会复用同一个容器

### 卷挂载

1. **当前工作目录**:`${PWD}:${PWD}:Z`
   - 将宿主机当前目录挂载到容器内的**相同路径**
   - `:Z` 标志用于 SELinux 上下文重标记

2. **SSH 密钥**:`$HOME/.ssh:/root/.ssh:Z`
   - 挂载 SSH 密钥,方便在容器内进行 git 操作
   - 支持私有仓库的克隆和推送

### 容器权限

- `--cap-add=SYS_PTRACE`:添加调试能力,支持 GDB 等调试工具
- `--rm`:容器退出后自动删除,保持环境清洁

## 镜像构建与发布

### 构建镜像

本项目的镜像由维护者构建并发布到 GitHub Container Registry。如需自行构建:

```bash
./build.sh
```

构建脚本会:
1. 使用上海时区生成时间戳标签(格式:`YYYYMMDDHHMM`)
2. 同时打上 `latest` 和时间戳两个标签
3. 推送到 `ghcr.io/w-mai/vela-builder`

### 镜像内容

镜像基于 Ubuntu 22.04,预装了完整的 Vela 编译工具链:

#### 编译工具链
- **GCC/G++**: 9, 11, 13 多版本(默认使用 GCC 13)
- **交叉编译**: 支持 x86_64 和 i386 架构
- **构建工具**: CMake, Ninja, Autotools, Meson
- **汇编器**: NASM, YASM

#### 开发工具
- **版本控制**: Git, Repo(配置了国内镜像源)
- **Python 生态**: Python 3, pip, pytest, gcovr, kconfiglib
- **Node.js**: npm, nodejs
- **其他**: JDK 11, Protobuf 3.14.0

#### 嵌入式开发工具
- **QEMU**: qemu-system-arm, qemu-efi-aarch64
- **烧录工具**: dfu-util, esptool
- **调试工具**: GDB(通过 SYS_PTRACE 支持)

#### 多媒体库(用于 GUI 编译)
- **图形库**: SDL2, Wayland, DRM, libinput
- **图像处理**: libpng, libjpeg, Pillow, pngquant
- **音视频**: FFmpeg (libavcodec, libavformat, libswscale)
- **音频**: PulseAudio, ALSA

#### 系统配置
- **时区**: Asia/Shanghai
- **镜像源**: 清华大学 TUNA 镜像(apt 和 pip)
- **Git 配置**: 
  - 禁用压缩(`core.compression -1`)
  - 信任所有目录(`safe.directory '*'`)

## 开发约定

### 目录结构

```
vela-dev-latest/
├── build.sh                  # 镜像构建和推送脚本
├── Dockerfile                # 镜像定义文件
├── README.md                 # 用户使用文档(英文)
├── AGENTS.md                 # AI Agent 上下文文档(本文件)
└── commands/                 # 命令行工具
    ├── vela-builder.sh       # Bash 版本
    └── vela-builder.fish     # Fish Shell 版本
```

### 脚本实现逻辑

两个版本的 `vela-builder` 脚本逻辑完全一致:

1. **检查 Podman 是否安装**
   - 如果未安装,显示彩色提示信息并退出
   - 提供各主流发行版的安装命令

2. **判断调用方式**
   - 无参数:进入交互式 Shell
   - 有参数:将参数作为命令传递给容器执行

3. **智能容器复用**
   - 先尝试 `podman exec` 进入已存在的容器
   - 如果失败(容器不存在),则 `podman run` 创建新容器

4. **错误处理**
   - 使用 `2>/dev/null` 抑制 exec 失败时的错误信息
   - 通过 `||` 运算符实现优雅降级

### 最佳实践

1. **在 OpenVela 项目根目录使用**
   ```bash
   cd /path/to/openvela
   vela-builder
   # 容器内的工作目录自动为 /path/to/openvela
   ```

2. **编译工作流**
   ```bash
   # 进入容器
   vela-builder
   
   # 在容器内执行编译
   ./build.sh
   make -j$(nproc)
   
   # 退出容器(容器自动删除)
   exit
   ```

3. **CI/CD 集成**
   ```bash
   # 在 CI 脚本中直接执行命令
   vela-builder "./configure && make && make test"
   ```

4. **多项目并行开发**
   ```bash
   # 项目 A
   cd ~/projects/vela-main
   vela-builder  # 容器名: vela-builder-vela-main
   
   # 项目 B(另一个终端)
   cd ~/projects/vela-fork
   vela-builder  # 容器名: vela-builder-vela-fork
   ```

## 故障排查

### 常见问题

#### 1. Podman 未安装

**现象**:执行 `vela-builder` 时提示 "Podman is not installed"

**解决**:按照提示安装 Podman(见前置要求章节)

#### 2. 镜像拉取失败

**现象**:首次运行时卡在 "Trying to pull ghcr.io/w-mai/vela-builder:latest..."

**原因**:网络问题或 GitHub Container Registry 访问受限

**解决**:
```bash
# 配置镜像加速(如果有)
# 或手动拉取镜像
podman pull ghcr.io/w-mai/vela-builder:latest
```

#### 3. SELinux 权限问题

**现象**:容器内无法访问挂载的目录

**原因**:SELinux 阻止了容器访问

**解决**:脚本已使用 `:Z` 标志自动处理,如仍有问题:
```bash
# 临时禁用 SELinux
sudo setenforce 0

# 或为目录添加正确的 SELinux 上下文
chcon -Rt svirt_sandbox_file_t /path/to/openvela
```

#### 4. SSH 密钥权限问题

**现象**:容器内 git 操作提示权限错误

**原因**:SSH 密钥权限过于宽松

**解决**:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
```

#### 5. 容器名称冲突

**现象**:虽然容器已删除,但仍提示名称冲突

**解决**:
```bash
# 手动清理容器
podman rm -f vela-builder-<目录名>

# 清理所有已停止的容器
podman container prune
```

## 扩展和定制

### 添加新的编译工具

编辑 `Dockerfile`,在合适的位置添加安装命令:

```dockerfile
# 例如:添加 Rust 工具链
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
```

然后重新构建镜像:

```bash
./build.sh
```

### 修改容器运行参数

编辑 `commands/vela-builder.sh` 或 `commands/vela-builder.fish`,修改 `podman run` 命令:

```bash
# 例如:添加更多卷挂载
-v "$HOME/downloads:/downloads:Z" \
```

### 使用自定义镜像

修改脚本中的镜像名称:

```bash
# 将 ghcr.io/w-mai/vela-builder:latest 替换为你的镜像
your-registry.com/your-image:tag
```

## 维护说明

### 镜像更新策略

- **定期更新**:每月更新一次基础镜像和工具链版本
- **安全补丁**:发现安全漏洞时立即更新
- **版本标签**:使用时间戳标签保留历史版本,方便回滚

### 脚本维护

- **功能一致性**:Bash 和 Fish 版本必须保持功能完全一致
- **错误处理**:确保所有错误都有友好的提示信息
- **兼容性**:测试在不同发行版上的兼容性

### 文档同步

- **README.md**:面向最终用户的使用文档(英文)
- **AGENTS.md**:面向 AI Agent 的技术文档(中文)
- **代码注释**:关键逻辑添加注释说明

---

**项目维护者**: xinbingnan <xinbingnan@xiaomi.com>  
**镜像仓库**: https://github.com/w-mai/vela-builder  
**最后更新**: 2025-10-21
