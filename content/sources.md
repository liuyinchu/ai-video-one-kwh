# 《一度电如何来到插座》V2 科学核查与来源

制作日期：2026-10-24（Asia/Shanghai）  
版本：V2，热水壶贯穿首尾，12 场 × 4 句，按旁白句子 beat 0–3 推进。  
核查对象：content/story.json 的 text、visualBeat、notes，以及 Sources/Visuals.swift 的对应场景源码。  
适用语境：中国大陆普通居民交流供电；面向大众的原理示意。  
来源原则：政府、能源监管机构、电网运营机构、国家实验室和大学的一手公开资料；以下为独立转述。

## 本轮结论

V2 旁白与制作 notes 的主要科学表述正确，内容主线不需要实质重写。相比初版，变压器磁耦合、有效值的加热比较、有限传播速度与储能容量边界已写进脚本。

本文件保留事实、来源与制作边界。V2 旁白审查通过；最终视觉实现将在主作者完成修正后另行复核，此处不记录暂时的代码缺陷。

## 1. 一度电是能量，千瓦是功率

- 对应场景：1、11。
- 事实：1 度电 = 1 kWh = 3.6 MJ = 360 万焦耳。实际有功功率保持 1 kW 持续 1 h，或保持 10 W 持续 100 h，累计电能均为 1 kWh。功率表示能量转换或传递的速率。
- 来源：[美国能源信息署 EIA：Measuring electricity](https://www.eia.gov/energyexplained/electricity/measuring-electricity.php)；[EIA：Electricity glossary](https://www.eia.gov/tools/glossary/?id=electricity)。
- 边界：功率乘时间的简单算式要求功率恒定；一般情况需随时间累计实际功率。额定功率不代表电器始终按该功率运行。焦耳换算来自 1000 W × 3600 s。烧一壶水的能耗取决于水量、初温、器具效率等，不能暗示必然为 1 kWh。
- 旁白是否需实质修改：否。两例条件在 text 和 notes 中清楚。两条动画时间轴须分别标 1 h 和 100 h，不能暗示同一时间消耗相同能量；累计电表不得因 beatProgress 重置而倒退。

## 2. 发电是转换能量，不制造电子

- 对应场景：2、11。
- 事实：火电、核电通常经过热能、机械能、电能的转换；水电和风电利用流体的机械作用驱动发电机。发电机通过电磁感应把机械能转换成电能。
- 来源：[EIA：How electricity is generated](https://www.eia.gov/energyexplained/electricity/how-electricity-is-generated.php)；[新西兰电力监管局 Electricity Authority：How electricity works](https://www.ea.govt.nz/your-power/how-electricity-works/)。
- 边界：不是所有发电方式都经过烧水或转动；光伏是另一条路线。火电与核电的具体热力循环不完全相同，核燃料与化石燃料也不应混作同一种热源。这里的“转换”不能画成生产新电子。
- 旁白是否需实质修改：否。场 2 第 2 句是合理的通俗概括。水风图示应在该句 beat 1 展开，不应延后到正在讲光伏的 beat 2。

## 3. 光伏向交流电网送电通常需要逆变器

- 对应场景：2。
- 事实：光伏组件把光能转化为直流电能；逆变器将直流输出转换成符合交流电网并网要求的交流输出。
- 来源：[美国能源部 DOE：Solar Integration — Inverters and Grid Services Basics](https://www.energy.gov/cmei/systems/solar-integration-inverters-and-grid-services-basics)；[DOE：Solar Power Electronic Devices](https://www.energy.gov/cmei/systems/solar-power-electronic-devices)。
- 边界：此处指交流并网系统；直流负载或直流微网不必经过完全相同的路线。部分风电也通过电力电子设备并网，不能把全部风机都画成与电网直接同步相连的发电机。
- 旁白是否需实质修改：否。场 2 第 4 句已明确“常见的交流电网”。画面应在 beat 2 先出现光伏直流输出，在 beat 3 再增加逆变器及交流输出。

## 4. 输配电网络经过变压；变压器靠变化磁通耦合

- 对应场景：0、3、6、7、11。
- 事实：电网包含多个电源、输电线路、变电站、配电网络与用户。普通公共电网不能理解为给每一度电安排一条专属运输路线。普通双绕组变压器通过共同的变化磁通耦合绕组；理想电压比等于匝数比，两个绕组不需要直接电连接。
- 来源：[EIA：Delivery to consumers](https://www.eia.gov/energyexplained/electricity/delivery-to-consumers.php)；[NESO：How does electricity move around?](https://www.neso.energy/energy-101/electricity-explained/how-does-electricity-move-around)；[莱斯大学 OpenStax：University Physics Volume 2，15.6 Transformers](https://openstax.org/books/university-physics-volume-2/pages/15-6-transformers)。
- 边界：10 kV 配电至居民 220 V 是典型示意，实际中间电压等级、接线与电源距离因地区而异。分布式电源可就近供电，直流输电还涉及换流站。双绕组图不代表所有变压器均如此，自耦变压器等另有结构。铁芯磁通是耦合说明，不宜把磁场画成像物质包裹一样单向流动并被另一侧消耗。
- 旁白是否需实质修改：否。场 6 新增的两句磁场解释准确，但 beat 0–1 必须展示两组彼此绝缘的绕组和变化磁通；单纯画设备外形无法支撑旁白。

## 5. 同功率升压降电流，电阻发热功率为 I²R

- 对应场景：4、5。
- 事实：相同输送有功功率、功率因数及系统接法等条件下，提高电压可降低所需电流。线路电阻发热功率与 I²R 成正比；电流为原来的 1/10、线路电阻不变时，该项损耗为原来的 1/100。
- 来源：[DOE／橡树岭国家实验室：Opportunities for Energy Efficiency Improvements in the U.S. Electricity Transmission and Distribution System，第 2 节](https://www.energy.gov/sites/prod/files/2015/04/f22/QER%20Analysis%20-%20Opportunities%20for%20Energy%20Efficiency%20Improvements%20in%20the%20US%20Electricity%20Transmission%20and%20Distribution%20System_0.pdf)。
- 边界：I²R 是功率；使用交流有效值电流时给出相应平均损耗功率，固定时间的发热能量还须乘时间。该比例不是整个电网全部损耗的比例。P = UI 可用于直流或功率因数为 1 的单相交流简化例；一般交流有功功率需计入功率因数，三相还涉及接法及线量、相量定义。仅“功率因数不变”不足以把一般有功功率写成 UI。
- 旁白是否需实质修改：无需重录。场 4 第 3 句已说“简化关系”；画面须同时明确“单相、功率因数 = 1 的简化模型”。可把式子写为 P = UI。动画 U、I 应真正互为反比，不能只线性一增一减；若柱高当作数值，乘积也应保持不变。

## 6. 50 Hz 是完整周期频率；220 V 是有效值

- 对应场景：6、8。
- 事实：现行《供电营业规则》第六、七条规定额定频率为交流 50 Hz；低压单相 220 V，三相三线 380 V，三相四线 380/220 V。50 Hz 对应每秒 50 个完整周期，周期为 20 ms。同一电阻在 220 V 有效值交流与 220 V 直流下，其平均发热功率相同。理想正弦波的峰值为有效值的 √2 倍，因此 220 V 对应约 311 V 峰值。
- 来源：[国家发展改革委：《供电营业规则》2024 年第 14 号令](https://www.ndrc.gov.cn/xxgk/zcfb/fzggwl/202403/t20240315_1364965_ext.html)；[重庆市发展改革委官方全文，第六、七条](https://fzggw.cq.gov.cn/zfxxgk/fdzdgknr/lzyj/gjbwgz/202412/t20241231_14035748_wap.html)；[莱斯大学 OpenStax：College Physics 2e，20.5 Alternating Current versus Direct Current](https://openstax.org/books/college-physics-2e/pages/20-5-alternating-current-versus-direct-current)。
- 边界：不能把 50 Hz 说成每秒只换向 50 次；正弦交流每个周期换向两次。220 V 为额定有效值，不保证任意时刻实测恰为 220 V。热效应比较要求同电阻、同时间；220 V 不能画成该正弦波的峰值或有符号时间平均值。311 V 只针对相应理想正弦波。
- 旁白是否需实质修改：否。场 8 有效值解释比初版更易理解。beat 2–3 需真正显示两种供电的同 R、同时间热量比较，不能只继续播放正弦波和“220 V”标签。

## 7. 局部电子运动与能流、传播前沿须分开表现

- 对应场景：9。
- 事实：金属导线里本来有可参与导电的电子。交流电场引起的定向漂移分量在局部往复。电磁场描述能量传递，电路变化以有限速度传播，远快于电子的平均漂移；电器无需等待远方某颗电子抵达。
- 来源：[西得州农工大学 Christopher S. Baird：What is the speed of electricity?](https://www.wtamu.edu/~cbaird/sq/mobile/2014/02/19/what-is-the-speed-of-electricity/)；[佐治亚州立大学 HyperPhysics：Microscopic View of Ohm’s Law](https://www.hyperphysics.gsu.edu/hbase/electric/ohmmic.html)；[弗吉尼亚大学 Michael Fowler：Energy Flow and Poynting’s Vector](https://galileoandeinstein.phys.virginia.edu/Elec_Mag/2022_Lectures/EM_41_Poynting.html)。
- 边界：局部往复指交流造成的平均定向运动，不是否认微观复杂运动。传播速度依赖线路与介质，不能统一写为真空光速。周期平均能流可以朝负载，但不应与瞬时电子方向或场扰动的传播前沿混为一件事。导体、场和负载共同组成系统，不能夸张为“电与电线无关”。
- 旁白是否需实质修改：否。画面需把稳态电子往复和一次瞬态传播分别标明；若展示“前沿抵达后负载响应”，负载加热状态必须由前沿抵达驱动，不能 beat 刚开始就立即加热。

## 8. 功率失衡影响频率变化趋势，恢复还涉及储存能量

- 对应场景：10。
- 事实：电网持续适应用电变化，稳态收支要计入用电、损耗、储能充放电。同步系统短时有功功率缺额会使系统储存的转动动能等减少，频率趋于下降；惯量影响变化速率。发电控制、储能与可调节负荷可以参与恢复。
- 来源：[NESO：What is frequency?](https://www.neso.energy/energy-101/electricity-explained/how-do-we-balance-grid/what-frequency)；[NESO：Faster Acting Response，Frequency Variation 图解](https://www.neso.energy/document/119256/download)；[NESO：Dynamic Containment，System operability needs](https://www.neso.energy/document/164471/download)；[国家能源局：关于促进新型储能并网和调度运用的通知](https://zfxxgk.nea.gov.cn/2024-04/02/c_1310771072.htm)。
- 边界：即时功率缺额关联频率变化速率，不能简单把频率偏差画成缺额本身的比例值。供给补齐需求可以止跌；恢复原频率还需恢复相应储存能量或体现其他控制过程。电池可储能，但功率、容量与效率均有限。英国来源用于物理机制，不套用英国监管频率偏差范围。
- 旁白是否需实质修改：否。场 10 文字只描述一般变化和调节，合理。动画应避免在供给仍低于总需求期间让频率指针明显回升；可示意为“缺额下探 → 储能补齐止跌 → 短暂略有富余恢复 → 重新平衡”，并标为示意。

## 最终成片复核要点

- 一壶水不被默认为恰好消耗一度电。
- 公式条件与量化动画在同一拍可见；相对损耗图不被误读为整个电网损耗。
- 变压器以磁耦合解释，两个示意绕组之间无直接导线贯穿。
- 家庭回路有明确串联负载，L/N 形成正常工作回路，保护地线不承担正常负载电流。
- 电表只累计已吸收的电能，跨句切换不倒退，水壶跳停后读数保持。
- 50 Hz、20 ms、220 V 有效值和理想正弦峰值不混淆。
- 电子局部往复、周期平均能流和一次传播前沿用不同视觉编码。
- 频率下探、止跌与恢复的顺序符合功率和储存能量的收支。


## V2 最终复核记录

2026-10-24：第二版旁白及关键科学动画逻辑已复核。最终 MP4 已抽取损耗、变压器、有效值和片尾实帧，核对文字与示意关系；另完成 48 句字幕的音频时间对齐及成片媒体检查。图形用于解释物理原理，不构成定量电网仿真。
