# TinyOS

一个从零开始的教学型 32 位 x86 操作系统内核实验项目。

TinyOS 使用 C 和少量 GNU 汇编编写，通过 GRUB 以 Multiboot 1 规范启动，并在 VGA 文本模式下显示第一条内核消息。项目重点不是追求功能完整，而是把操作系统启动链路拆成可以理解、可以复现、可以逐步扩展的最小单元。

> 当前状态：早期实验版本（pre-alpha）。适合学习和改造，不适合生产环境。

## 功能状态

| 模块 | 状态 | 说明 |
| --- | --- | --- |
| BIOS 启动 | 已完成 | 通过 GRUB 从 ISO 启动 |
| Multiboot 1 | 已完成 | GRUB 可以识别 `kernel.bin` |
| 32 位保护模式入口 | 已完成 | 由 `boot.s` 提供启动入口 |
| C 内核入口 | 已完成 | 调用 `kernel_main` |
| VGA 文本输出 | 已完成 | 清屏并显示 `Hello, kernel!` |
| 键盘中断 | 未开始 | 下一阶段 |
| 内存管理 | 未开始 | 下一阶段 |
| 用户态程序 | 未开始 | 远期目标 |

## 启动链路

```text
BIOS
  -> GRUB
  -> Multiboot 1
  -> boot.s::_start
  -> kernel_main()
  -> VGA text buffer
```

## 项目结构

```text
.
├── boot.s              # Multiboot 头、内核入口和初始栈
├── kernel.c            # C 内核入口、清屏和 VGA 输出
├── linker.ld           # 内核链接布局，基地址为 1 MiB
├── grub.cfg            # GRUB 菜单配置
├── Makefile            # 编译、链接、ISO、检查和运行目标
├── Dockerfile          # 可复现的交叉编译环境
├── docker.ps1          # Windows 下的 Docker 快捷命令
├── CONTRIBUTING.md     # 贡献流程和代码规范
├── CHANGELOG.md        # 版本变更记录
├── SECURITY.md         # 安全问题报告说明
└── .github/            # Issue、Pull Request 和 CI 模板
```

## 环境要求

推荐使用 Docker 运行完整工具链。需要：

- Windows 10/11、Linux 或 macOS
- Docker Desktop 或 Docker Engine
- 可用的互联网连接（首次构建需要下载基础镜像和 GNU 源码）
- 至少 8 GB 可用磁盘空间
- 建议至少 4 GB 内存

容器内部包含：

- `i686-elf-gcc`
- `i686-elf-as`
- `i686-elf-ld`
- GRUB 与 `grub-file`
- `grub-mkrescue`
- `xorriso`
- `qemu-system-i386`
- GNU Make

## 快速开始

### 1. 获取项目

```bash
git clone https://github.com/<your-account>/tinyos.git
cd tinyos
```

将 `<your-account>` 替换成你的 GitHub 用户名或组织名。

### 2. 构建工具链镜像

```bash
docker build -t tinyos-toolchain .
```

### 3. 构建 ISO

Windows PowerShell：

```powershell
.\docker.ps1 build
```

Linux/macOS：

```bash
docker run --rm -v "$PWD:/workspace" tinyos-toolchain
```

成功后会生成：

```text
build/tinyos.iso
build/kernel.bin
```

### 4. 检查 Multiboot 头

Windows PowerShell：

```powershell
.\docker.ps1 check
```

Linux/macOS：

```bash
docker run --rm -v "$PWD:/workspace" tinyos-toolchain check
```

### 5. 使用 QEMU 运行

Windows PowerShell：

```powershell
.\docker.ps1 run
```

Linux/macOS：

```bash
docker run --rm -it -v "$PWD:/workspace" tinyos-toolchain run
```

正常启动后，虚拟机屏幕应显示：

```text
Hello, kernel!
```

退出 QEMU：

```text
Ctrl+A，然后按 X
```

## 使用 VMware 运行

ISO 也可以挂载到 VMware Workstation 或 VMware Fusion：

1. 创建新的虚拟机。
2. 选择“稍后安装操作系统”。
3. 客户机系统选择 `Other Linux 32-bit` 或类似选项。
4. 固件选择 `BIOS`，不要使用纯 UEFI。
5. 在 CD/DVD 设置中选择 `build/tinyos.iso`。
6. 勾选“启动时连接”。
7. 启动虚拟机并在 GRUB 菜单中选择 `TinyOS`。

建议配置：

- 内存：128 MB 或以上
- CPU：1 个核心即可
- 硬盘：不需要，当前项目从 ISO 只读启动

## 手动 Make 命令

如果本机已经安装了完整的裸机工具链，也可以直接运行：

```bash
make              # 构建 ISO
make check        # 检查 Multiboot 1
make run          # 使用 QEMU 启动
make clean        # 删除构建目录
```

本机工具链必须提供 `i686-elf-gcc`，不能用普通宿主机 GCC 代替完整链接流程。

## 已知问题与限制

当前版本存在以下明确限制：

1. 只有 VGA 文本输出，没有图形界面。
2. 没有键盘驱动，内核无法读取用户输入。
3. 没有中断描述符表（IDT）和完整异常处理。
4. 没有分页、堆、页分配器或动态内存管理。
5. 没有文件系统、磁盘驱动、网络协议栈或用户态。
6. 只支持 32 位 x86 BIOS/GRUB 启动路径，不支持 UEFI 原生启动。
7. Docker 工具链首次构建耗时较长，并且需要下载 GNU 源码。
8. `-display curses` 需要交互式终端；在某些 IDE 内置终端中可能无法显示。
9. VMware 的 UEFI 模式可能提示找不到操作系统，请切换到 BIOS。
10. 项目尚未建立自动化硬件测试，当前验证主要依靠 QEMU 和 Multiboot 检查。

## 排查问题

### `docker: command not found`

安装 Docker Desktop，并确认 Docker Engine 已启动：

```powershell
docker version
```

### `docker build` 下载超时

首次构建需要下载较大的 Ubuntu、GCC 和 Binutils 文件。可以重新执行命令，Docker 会复用已经完成的缓存层；也可以配置 Docker 镜像加速器。

### `grub-file` 检查失败

先清理后重新构建：

```powershell
.\docker.ps1 clean
.\docker.ps1 build
.\docker.ps1 check
```

如果 `clean` 尚未提供 PowerShell 入口，可以直接删除项目下的 `build` 目录后重新执行构建。

### VMware 显示 `Operating System not found`

确认：

- 挂载的是 `build/tinyos.iso`。
- CD/DVD 设备已经勾选“启动时连接”。
- 固件使用 BIOS，而不是 UEFI。
- ISO 是最新构建产物，而不是旧文件。

### QEMU 没有画面

优先使用交互式终端运行：

```powershell
.\docker.ps1 run
```

如果使用 IDE 内置终端失败，可以直接用 VMware 挂载 ISO，或使用 QEMU 图形模式进行调试。

## 开发路线图

- [ ] 提取并显示 Multiboot 内存信息
- [ ] 实现 GDT 和 IDT 初始化
- [ ] 添加异常处理和 Panic 输出
- [ ] 添加 PIT 定时器
- [ ] 添加 PS/2 键盘驱动
- [ ] 实现物理内存探测
- [ ] 实现页分配器和内核堆
- [ ] 添加简单 Shell
- [ ] 设计系统调用接口
- [ ] 加入用户态程序
- [ ] 支持 UEFI 启动

## 参与贡献

欢迎提交 Issue、改进文档、修复启动问题或实现新的内核模块。提交代码前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

本项目使用 MIT License，详见 [LICENSE](LICENSE)。

## 致谢

- GNU GCC / Binutils
- GRUB
- QEMU
- xorriso
- VMware（用于虚拟机验证）