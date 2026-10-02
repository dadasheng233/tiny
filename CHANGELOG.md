# 变更记录

本文件记录 TinyOS 的重要变更。版本号尚未正式发布前，使用 `Unreleased` 区段。

## [Unreleased]

### Added

- 基于 GRUB Multiboot 1 的 32 位 x86 启动链路。
- `boot.s` 汇编入口和 16 KiB 初始栈。
- `kernel_main` C 内核入口。
- VGA 文本模式清屏和 `Hello, kernel!` 输出。
- Docker 化的 `i686-elf-gcc`、GRUB、xorriso 和 QEMU 工具链。
- Windows PowerShell 快捷脚本 `docker.ps1`。
- GitHub Issue、Pull Request 和安全问题模板。

### Known Issues

- 尚未实现键盘、中断、分页、内存分配和文件系统。
- 只支持 32 位 x86 BIOS/GRUB 启动路径。
- QEMU 的 curses 显示依赖交互式终端。