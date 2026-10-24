# 《一度电如何来到插座》科学核查与来源

制作日期：2026-10-24（Asia/Shanghai）  
核查对象：content/story.json，12 个场景，场景 ID 0–11。  
适用语境：中国大陆普通居民交流供电；面向大众的示意解释。  
核查方式：对照政府、能源监管机构、电网运营机构、国家实验室及大学的公开一手资料。下文为独立转述，不是来源原文摘抄。

## 审阅结论

现有旁白未发现需要实质修改的科学错误，可以据此继续制作。关键条件已经写入脚本：一度是能量；升压比较限定相同功率、功率因数和线路电阻；10 千伏至 220 伏路线注明示意；50 赫兹用完整周期解释；220 伏注明有效值；电子运动与电磁能流区分；供需平衡纳入网损和储能。

本结论只覆盖本次读取的 story.json 文本。未检查最终画面、字幕、声音或渲染成片；画面若把能量示意画成单个电子的长途旅行，或把地线画成正常工作电流通道，会重新造成误导。

## 1. 一度电是能量，千瓦是功率

- 对应场景：1、11。
- 事实：1 度电 = 1 kWh = 3.6 MJ = 360 万焦耳。功率保持 1 kW 持续 1 h，或保持 10 W 持续 100 h，累计电能均为 1 kWh。功率表示能量转换或传递的速率。
- 来源：[美国能源信息署 EIA：Measuring electricity](https://www.eia.gov/energyexplained/electricity/measuring-electricity.php)；[EIA：Electricity glossary](https://www.eia.gov/tools/glossary/?id=electricity)。
- 边界：由功率乘时间求能量的简单算式要求功率保持不变；一般情况需累计实际功率。额定功率不代表电器始终按该功率运行。焦耳换算来自 1000 W × 3600 s。
- 是否需实质修改：否。场景 1 已使用“功率保持”，例子成立。

## 2. 发电设备转换能量，不制造电子

- 对应场景：2、11。
- 事实：火电、核电通常经过热能、机械能、电能的转换；水电和风电利用流体的机械作用驱动发电机。传统发电机利用电磁感应把机械能转换为电能。
- 来源：[EIA：How electricity is generated](https://www.eia.gov/energyexplained/electricity/how-electricity-is-generated.php)；[新西兰电力监管局 Electricity Authority：How electricity works](https://www.ea.govt.nz/your-power/how-electricity-works/)。
- 边界：不是所有发电方式都要先烧水或带动涡轮；光伏属于不同路线。“发电”不能解释为生产新电子。火电和核电的热力循环也不完全相同。
- 是否需实质修改：否。场景 2 用“通常”限定热力发电路线，并单列光伏。

## 3. 并网光伏通常需要逆变器

- 对应场景：2。
- 事实：光伏组件将光能转化为直流电能。向交流电网送电时，逆变器及相关电力电子设备将直流输出转换成符合并网要求的交流输出。
- 来源：[美国能源部 DOE：Solar Integration — Inverters and Grid Services Basics](https://www.energy.gov/cmei/systems/solar-integration-inverters-and-grid-services-basics)；[DOE：Solar Power Electronic Devices](https://www.energy.gov/cmei/systems/solar-power-electronic-devices)。
- 边界：此处指接入交流电网的光伏系统；直流负载或直流微网不必走完全相同的路线。部分风电设备也通过变流器并网，不宜把所有发电设备画成完全相同的同步发电机。
- 是否需实质修改：否。脚本明确说“与交流电网相配合”，符合本片语境。

## 4. 输电与配电构成网络，路径是示意

- 对应场景：0、3、6、7、11。
- 事实：电力系统包含电源、输电线路、变电站、配电线路和用户。高压输电承担大量远距离电能传输，变压器调整交流电压，配电网络将电能送到终端用户。普通公共电网由多个电源共同供电，不能把“这一度电”理解成沿唯一快递路线运送的独立包裹。
- 来源：[EIA：Delivery to consumers](https://www.eia.gov/energyexplained/electricity/delivery-to-consumers.php)；[英国国家能源系统运营商 NESO：How does electricity move around?](https://www.neso.energy/energy-101/electricity-explained/how-does-electricity-move-around)。
- 边界：10 千伏配电至居民 220 伏是典型示意，实际电压等级、接线与电源距离因地区而异。分布式电源可能就近供电；直流输电还需换流站。专线、孤岛电网等不属于本片普通公共电网的简化主线。“不能贴专属路线标签”是物理潮流的通俗解释，不涉及绿电证书或交易的属性追踪。
- 是否需实质修改：否。场景 6 已明确“示意路线”。若制作时增补细节，避免把所有居民用电都画成必经某一套远距离输电电压等级。

## 5. 升压可降低电流及电阻发热损耗

- 对应场景：4、5。
- 事实：相同输送功率、功率因数和网络比较条件下，电压提高可降低所需电流。线路电阻发热损耗功率与 I²R 成正比；电流变为十分之一，在电阻不变时，此项损耗变为百分之一。
- 来源：[DOE／橡树岭国家实验室：Opportunities for Energy Efficiency Improvements in the U.S. Electricity Transmission and Distribution System，第 2 节 Transmission Losses](https://www.energy.gov/sites/prod/files/2015/04/f22/QER%20Analysis%20-%20Opportunities%20for%20Energy%20Efficiency%20Improvements%20in%20the%20US%20Electricity%20Transmission%20and%20Distribution%20System_0.pdf)。
- 边界：I²R 给出的是电阻发热损耗的功率；使用交流有效值电流时表示相应平均损耗功率。固定时间内的发热能量还需乘时间。百分之一不是整个真实电网总损耗的保证，也未包括变压器、换流、电晕等其他损耗。三相交流功率不能无条件直接写成 P = UI；通常还涉及相数、线电压定义和功率因数。
- 是否需实质修改：否。脚本已给足比较条件，并标为理想模型。可选精度优化：画面公式标签写成“线路电阻发热功率：P损 = I²R”，使量纲更明确；不需要重写现有叙事。

## 6. 中国大陆常见居民供电为 220 V、50 Hz

- 对应场景：6、7、8。
- 事实：现行《供电营业规则》第六、七条规定额定频率为交流 50 赫兹；低压单相为 220 伏，三相三线为 380 伏，三相四线为 380/220 伏。在常见三相四线系统中，相线之间为 380 V，相线与中性线之间为 220 V。这里的电压采用有效值。理想正弦波峰值为有效值的 √2 倍，所以 220 V 对应约 311 V 峰值。
- 来源：[国家发展改革委：《供电营业规则》2024 年第 14 号令发布页](https://www.ndrc.gov.cn/xxgk/zcfb/fzggwl/202403/t20240315_1364965_ext.html)；[重庆市发展改革委官方全文，第六、七条](https://fzggw.cq.gov.cn/zfxxgk/fdzdgknr/lzyj/gjbwgz/202412/t20241231_14035748_wap.html)；[莱斯大学 OpenStax：College Physics 2e，20.5 Alternating Current versus Direct Current](https://openstax.org/books/college-physics-2e/pages/20-5-alternating-current-versus-direct-current)。
- 边界：50 Hz 是每秒 50 个完整周期，不能说成每秒只换向 50 次；正弦交流每周期有两次换向。220 V 是额定有效值，不保证任意时刻的实测值恰为 220 V。311 V 只对应理想正弦波和 220 V 有效值，不是所有畸变波形的固定峰值。有效值的热效应比较须使用相同电阻。家庭保护地线不是正常负载电流的回流通道。
- 是否需实质修改：否。场景 7、8 的电压关系、完整周期、有效值定义及理想峰值均准确。

## 7. 电子的漂移与电磁能传播是不同概念

- 对应场景：0、9、11。
- 事实：金属导线中本来就有可参与导电的电子。交流电场使其定向漂移分量随时间往复变化；电路响应传播远快于电子的平均漂移。电磁场描述能量的传递，不能把电能输送理解为某颗电子从远方电厂跑到家里。
- 来源：[西得州农工大学 Christopher S. Baird：What is the speed of electricity?](https://www.wtamu.edu/~cbaird/sq/mobile/2014/02/19/what-is-the-speed-of-electricity/)；[佐治亚州立大学 HyperPhysics：Microscopic View of Ohm’s Law](https://www.hyperphysics.gsu.edu/hbase/electric/ohmmic.html)；[弗吉尼亚大学 Michael Fowler：Energy Flow and Poynting’s Vector](https://galileoandeinstein.phys.virginia.edu/Elec_Mag/2022_Lectures/EM_41_Poynting.html)。
- 边界：“来回运动”描述交流电引起的平均定向运动，不否认电子自身复杂的微观运动。信号或能量传播速度依赖线路结构和介质，不能一概说成真空光速。也不要用“电完全在电线外传”替代原误区；导体、场和负载共同构成系统。
- 是否需实质修改：否。场景 9 使用“主要来回运动”和“与线路相伴的电磁场”，保留了必要准确性。动画应让本地电子往复，另用明确标为能量流的箭头或光带表示能量传递。

## 8. 电网在变化中维持供需平衡，储能是调节手段

- 对应场景：10、11。
- 事实：电网运行要持续适应用电与发电变化。稳态能量收支须计入用户需求、损耗和储能充放电；短时失衡会涉及系统储存能量及频率动态。一般而言，供给不足会使同步电网频率趋于下降，供给过多会使其趋于上升。发电调节、储能和可调节负荷可参与平衡。
- 来源：[NESO：What is frequency?](https://www.neso.energy/energy-101/electricity-explained/how-do-we-balance-grid/what-frequency)；[国家能源局：《关于促进新型储能并网和调度运用的通知》，国能发科技规〔2024〕26 号](https://zfxxgk.nea.gov.cn/2024-04/02/c_1310771072.htm)。
- 边界：不能说电能完全无法储存；电池、抽水蓄能等通过能量转换实现储存，但有功率、容量和效率限制。供需并非每一瞬间无误差，转动惯量及其他储能承担暂态变化，再由控制系统响应。英国来源只用于说明频率与平衡的物理关系，其具体监管偏差范围不能套用到中国。
- 是否需实质修改：否。场景 10 用“稳态时”与“短暂失衡”正确区分了不同情形，并已纳入网损和储能。

## 成片检查要点

1. 能量流箭头不能冒充从电厂飞向家庭的同一群电子。
2. 50 Hz 标为 50 周期/秒；220 V 标为有效值；311 V 标为理想正弦峰值。
3. 升压十倍示意同时保留“同功率、同功率因数、同电阻”的条件，百分之一对应线路电阻发热损耗。
4. 电压路径保留“示意”字样；正常工作回路使用相线和中性线，不把保护地线当作工作回路。
5. 一度电不画成插座里预存的固定包裹；电表累计的是电能。

