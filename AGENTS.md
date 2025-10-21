# AGENTS.md - Vela 开发环境项目指南

## 项目概述

这是一个用于构建和管理 Vela 开发环境的 Docker 容器化项目。Vela 是一个基于 KubeVela 的应用交付平台开发环境，本项目提供了完整的构建脚本和命令行工具，用于快速搭建和管理开发环境。

### 主要技术栈

- **容器化**: Docker
- **基础镜像**: Ubuntu 22.04
- **开发工具**: Go 1.23.2, kubectl, Helm, k3d, kind
- **Shell 脚本**: Bash 和 Fish Shell

### 项目架构

项目采用容器化架构，通过 Dockerfile 定义开发环境，包含以下核心组件：

1. **Docker 镜像构建**: 基于 Ubuntu 22.04，预装所有必要的开发工具
2. **构建脚本**: `build.sh` 用于自动化构建 Docker 镜像
3. **命令行工具**: `vela-builder` 提供便捷的容器管理命令

## 构建和运行

### 构建 Docker 镜像

```bash
# 执行构建脚本
./build.sh
```

构建脚本会：
- 使用 `vela-dev:latest` 作为镜像标签
- 自动构建包含所有开发工具的 Docker 镜像

### 使用 vela-builder 命令

项目提供了两个版本的 `vela-builder` 命令行工具：

#### Bash 版本 (vela-builder.sh)

```bash
# 启动开发容器
./commands/vela-builder.sh start

# 进入容器
./commands/vela-builder.sh enter

# 停止容器
./commands/vela-builder.sh stop

# 删除容器
./commands/vela-builder.sh remove

# 查看帮助
./commands/vela-builder.sh help
```

#### Fish Shell 版本 (vela-builder.fish)

```fish
# 启动开发容器
./commands/vela-builder.fish start

# 进入容器
./commands/vela-builder.fish enter

# 停止容器
./commands/vela-builder.fish stop

# 删除容器
./commands/vela-builder.fish remove

# 查看帮助
./commands/vela-builder.fish help
```

### 容器特性

启动的开发容器具有以下特性：

- **容器名称**: `vela-dev`
- **网络模式**: host 模式（与宿主机共享网络）
- **特权模式**: 启用（支持 Docker-in-Docker）
- **卷挂载**: 
  - `/var/run/docker.sock` - Docker socket 挂载
  - `$HOME/workspace` → `/root/workspace` - 工作空间目录
- **自动重启**: 除非手动停止，否则自动重启

## 开发环境说明

### 预装工具

Docker 镜像中预装了以下开发工具：

1. **Go 语言环境**
   - 版本: 1.23.2
   - 安装路径: `/usr/local/go`

2. **Kubernetes 工具**
   - kubectl: Kubernetes 命令行工具
   - Helm: Kubernetes 包管理器
   - k3d: 轻量级 Kubernetes 集群工具
   - kind: Kubernetes IN Docker

3. **系统工具**
   - curl, wget, git, vim, jq
   - build-essential (编译工具链)
   - ca-certificates, gnupg, lsb-release

### 环境变量

容器中配置了以下环境变量：

- `GOPATH=/root/go`
- `PATH` 包含 Go 二进制路径

## 开发约定

### 目录结构

```
vela-dev-latest/
├── build.sh              # Docker 镜像构建脚本
├── Dockerfile            # Docker 镜像定义文件
├── README.md             # 项目说明文档
└── commands/             # 命令行工具目录
    ├── vela-builder.fish # Fish Shell 版本的管理工具
    └── vela-builder.sh   # Bash 版本的管理工具
```

### 工作流程建议

1. **首次使用**:
   ```bash
   # 1. 构建镜像
   ./build.sh
   
   # 2. 启动容器
   ./commands/vela-builder.sh start
   
   # 3. 进入容器
   ./commands/vela-builder.sh enter
   ```

2. **日常开发**:
   ```bash
   # 进入已运行的容器
   ./commands/vela-builder.sh enter
   
   # 在容器内进行开发工作
   # 工作目录: /root/workspace
   ```

3. **容器管理**:
   ```bash
   # 停止容器（保留容器状态）
   ./commands/vela-builder.sh stop
   
   # 重新启动
   ./commands/vela-builder.sh start
   
   # 完全删除容器
   ./commands/vela-builder.sh remove
   ```

### 最佳实践

1. **工作空间管理**: 所有项目代码应放在 `$HOME/workspace` 目录下，该目录会自动挂载到容器中
2. **持久化数据**: 重要数据应存储在挂载的卷中，避免容器删除时丢失
3. **Docker-in-Docker**: 容器支持在内部运行 Docker 命令，适合测试容器化应用
4. **网络访问**: 使用 host 网络模式，容器可以直接访问宿主机网络资源

## 故障排查

### 常见问题

1. **容器无法启动**
   - 检查 Docker 服务是否运行: `systemctl status docker`
   - 确认镜像已构建: `docker images | grep vela-dev`

2. **无法访问 Docker socket**
   - 确认 `/var/run/docker.sock` 存在且有权限
   - 检查用户是否在 docker 组中

3. **工作空间目录未挂载**
   - 确认 `$HOME/workspace` 目录存在
   - 如不存在，创建目录: `mkdir -p $HOME/workspace`

## 扩展和定制

### 修改 Dockerfile

如需添加额外的工具或依赖，编辑 `Dockerfile` 并重新构建：

```bash
# 编辑 Dockerfile
vim Dockerfile

# 重新构建镜像
./build.sh
```

### 自定义挂载目录

编辑 `commands/vela-builder.sh` 或 `commands/vela-builder.fish`，修改 `docker run` 命令中的 `-v` 参数。

## 维护说明

- **镜像更新**: 定期更新基础镜像和工具版本，保持开发环境的安全性和稳定性
- **脚本维护**: Bash 和 Fish 版本的脚本应保持功能一致性
- **文档同步**: 修改功能时同步更新 README.md 和 AGENTS.md

---

**最后更新**: 2025-10-21
**项目维护者**: b3n1gnx
