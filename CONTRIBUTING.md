# 贡献指南

感谢你参与 TinyOS。这个项目处于早期阶段，最重要的是保持启动链路简单、改动可验证、文档与代码同步。

## 开始之前

请先阅读：

- [README.md](README.md)
- [CHANGELOG.md](CHANGELOG.md)
- [SECURITY.md](SECURITY.md)

## 开发环境

推荐使用 Docker：

```powershell
.\docker.ps1 build
.\docker.ps1 check
```

如果修改了内核代码，至少需要验证：

```powershell
.\docker.ps1 build
.\docker.ps1 check
.\docker.ps1 run
```

## 分支和提交

建议使用以下分支格式：

- `feature/<name>`：新功能
- `fix/<name>`：Bug 修复
- `docs/<name>`：文档修改
- `refactor/<name>`：重构

提交信息建议使用清晰的动词开头，例如：

```text
feat: add keyboard interrupt entry
fix: align boot stack before calling C
 docs: document VMware boot settings
```

## 代码规范

### C

- 使用 freestanding C，不依赖宿主机 libc。
- 保持 `-Wall -Wextra` 无警告。
- 使用明确宽度的整数类型，例如 `uint32_t`。
- 硬件地址和魔数尽量集中定义。
- 不在内核中调用不可用的标准库函数。
- 新增驱动时同时说明初始化顺序和硬件假设。

### 汇编

- 使用 GNU assembler AT&T 语法。
- 说明入口、寄存器约定和栈约束。
- 修改启动代码后必须重新执行 Multiboot 检查。

### 文档

- 中文文档统一使用 UTF-8。
- 不记录未验证的启动结果。
- 新增限制或已知问题时同步更新 README。

## Pull Request 要求

Pull Request 描述至少包含：

1. 修改目的。
2. 影响的启动阶段或内核模块。
3. 执行过的构建和检查命令。
4. QEMU 或 VMware 验证结果。
5. 已知限制和后续工作。

## 不接受的改动

- 把宿主机程序伪装成内核功能。
- 引入未经说明的闭源二进制。
- 提交 `build/`、ISO、目标文件或大型缓存。
- 修改工具链却不更新 Dockerfile 和文档。
- 未验证就宣称支持 UEFI、64 位或真实硬件。