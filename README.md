# shiboqi

数字示波器 FPGA 工程，目标器件为 Altera/Intel Cyclone IV E `EP4CE10F17C8`。工程通过外部 AD 输入采集波形数据，完成抽样、频率测量、峰峰值测量，并通过 RGB LCD 显示波形和测量参数。

## 功能概述

- 8 bit AD 数据输入采样
- AD 采样时钟输出
- 波形数据写入双口 RAM
- 输入信号频率测量
- 输入信号峰峰值、最大值、最小值测量
- RGB565 LCD 波形与字符显示
- 按键消抖与幅度/频率调节输入

## 工程状态

当前根目录工程作为主工程维护，重复工程副本 `shiboqi/` 已在 `.gitignore` 中排除，后续上传 Git 时默认不会提交。

已完成的整理：

- `rtl/OSR.v` 已加入 Quartus 工程文件 `quartus_prj/shiboqi.qsf`
- `OSR` 模块已补齐 `ad_freq` 输入端口，修复重复声明问题
- 顶层 `rtl/top/shiboqi.v` 已补齐关键显式信号声明
- `sim/tb_shiboqi.v` 已整理为基础顶层 testbench
- `.gitignore` 已排除 Quartus 生成数据库、输出文件、仿真输出和重复工程副本

注意：当前机器未安装 Quartus 命令行工具、Icarus Verilog 或 Verilator，因此尚未完成本地综合/仿真编译验证。最终可用性请以 Quartus II 13.0 SP1 全量编译结果为准。

## 目录结构

```text
.
|-- quartus_prj/          # Quartus II 工程目录
|   |-- shiboqi.qpf       # Quartus project file
|   `-- shiboqi.qsf       # 器件、引脚、源文件和 IP 约束
|-- rtl/                  # RTL 源码
|   |-- top/              # 顶层模块
|   |-- oscp/             # 采样与测量相关模块
|   |-- lcd/              # LCD 驱动与显示绘制
|   |-- key/              # 按键消抖和按键事件
|   |-- ram/              # RAM IP
|   |-- pll/              # LCD PLL IP
|   |-- pll_top/          # 系统 PLL IP
|   `-- OSR.v             # 抽样控制模块
|-- sim/                  # 仿真 testbench
|-- doc/                  # 项目文档
|-- .gitignore            # Git 排除规则
`-- README.md
```

## 硬件与工具

| 项目 | 说明 |
| --- | --- |
| FPGA | Cyclone IV E `EP4CE10F17C8` |
| 开发工具 | Quartus II 13.0 SP1 |
| 仿真工具 | ModelSim |
| 顶层模块 | `shiboqi` |
| 工程文件 | `quartus_prj/shiboqi.qpf` |

## 主要接口

| 信号 | 方向 | 说明 |
| --- | --- | --- |
| `clk` | input | 系统时钟 |
| `rst` | input | 复位信号 |
| `key_1` ~ `key_4` | input | 按键输入 |
| `ad_data[7:0]` | input | AD 输入数据 |
| `ad_clk` | output | AD 驱动时钟 |
| `lcd_rgb[15:0]` | output | LCD RGB565 数据 |
| `lcd_hs` | output | LCD 行同步 |
| `lcd_vs` | output | LCD 场同步 |
| `lcd_de` | output | LCD 数据使能 |
| `lcd_pclk` | output | LCD 像素时钟 |
| `lcd_bl` | output | LCD 背光控制 |
| `lcd_rst` | output | LCD 复位 |

## 主要模块

| 模块 | 文件 | 说明 |
| --- | --- | --- |
| `shiboqi` | `rtl/top/shiboqi.v` | 工程顶层 |
| `OSR` | `rtl/OSR.v` | AD 时钟、抽样有效信号和写 RAM 地址控制 |
| `param_measure` | `rtl/oscp/param_measure.v` | 频率、峰峰值、最大值、最小值测量 |
| `pulse_gen` | `rtl/oscp/pulse_gen.v` | 根据 AD 数据生成待测脉冲 |
| `cymometer` | `rtl/oscp/cymometer.v` | 等精度频率测量 |
| `vpp_measure` | `rtl/oscp/vpp_measure.v` | 峰峰值测量 |
| `lcd_rgb_char` | `rtl/lcd/lcd_rgb_char.v` | LCD 显示顶层封装 |
| `lcd_driver` | `rtl/lcd/lcd_driver.v` | LCD 时序驱动 |
| `lcd_display` | `rtl/lcd/lcd_display.v` | 波形、字符和参数绘制 |
| `key_top` | `rtl/key/key_top.v` | 按键消抖和按键事件输出 |

## 编译方式

### Quartus 图形界面

1. 安装 Quartus II 13.0 SP1。
2. 打开 `quartus_prj/shiboqi.qpf`。
3. 检查器件型号是否为 `EP4CE10F17C8`。
4. 执行全量编译。
5. 编译通过后，根据需要下载生成的 `.sof` 文件。

### Quartus 命令行

配置好 Quartus 命令行环境后，在 `quartus_prj/` 目录执行：

```powershell
quartus_sh --flow compile shiboqi
```

## 仿真

基础 testbench 位于：

```text
sim/tb_shiboqi.v
```

该 testbench 用于顶层基础连线和时钟/复位激励检查。若要做完整功能仿真，还需要根据实际 AD 输入波形、LCD 时序和 IP 仿真库继续补充测试场景。

