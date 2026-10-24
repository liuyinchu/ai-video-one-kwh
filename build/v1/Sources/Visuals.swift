import AppKit
import CoreGraphics

// All artwork is drawn from vector primitives in the remote repository.
private let ink = NSColor(calibratedRed: 0.028, green: 0.075, blue: 0.105, alpha: 1)
private let panel = NSColor(calibratedRed: 0.055, green: 0.128, blue: 0.165, alpha: 1)
private let mint = NSColor(calibratedRed: 0.32, green: 0.94, blue: 0.75, alpha: 1)
private let amber = NSColor(calibratedRed: 1, green: 0.72, blue: 0.40, alpha: 1)
private let white = NSColor(calibratedRed: 0.94, green: 0.97, blue: 0.95, alpha: 1)
private let muted = NSColor(calibratedRed: 0.49, green: 0.64, blue: 0.68, alpha: 1)
private let blue = NSColor(calibratedRed: 0.36, green: 0.65, blue: 1, alpha: 1)
private func c(_ a:NSColor, _ alpha:CGFloat = 1) -> CGColor { a.withAlphaComponent(alpha).cgColor }
private func line(_ g:CGContext,_ pts:[CGPoint],_ color:NSColor = mint,_ width:CGFloat = 5,_ alpha:CGFloat = 1) {
    guard let p=pts.first else{return};g.setStrokeColor(c(color,alpha));g.setLineWidth(width);g.setLineCap(.round);g.setLineJoin(.round);g.beginPath();g.move(to:p);for q in pts.dropFirst(){g.addLine(to:q)};g.strokePath()
}
private func path(_ g:CGContext,_ pts:[CGPoint],_ color:NSColor) {
    guard let p=pts.first else{return};g.setFillColor(c(color));g.beginPath();g.move(to:p);for q in pts.dropFirst(){g.addLine(to:q)};g.closePath();g.fillPath()
}
private func rect(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat,_ color:NSColor,_ r:CGFloat = 20,_ alpha:CGFloat=1) {
    g.setFillColor(c(color,alpha));g.addPath(CGPath(roundedRect:CGRect(x:x,y:y,width:w,height:h),cornerWidth:r,cornerHeight:r,transform:nil));g.fillPath()
}
private func circle(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ r:CGFloat,_ color:NSColor,_ alpha:CGFloat=1){g.setFillColor(c(color,alpha));g.fillEllipse(in:CGRect(x:x-r,y:y-r,width:r*2,height:r*2))}
private func ring(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ r:CGFloat,_ color:NSColor,_ width:CGFloat=3,_ alpha:CGFloat=1){g.setStrokeColor(c(color,alpha));g.setLineWidth(width);g.strokeEllipse(in:CGRect(x:x-r,y:y-r,width:r*2,height:r*2))}
private func text(_ s:String,_ x:CGFloat,_ y:CGFloat,_ size:CGFloat=32,_ color:NSColor=white,_ weight:NSFont.Weight = .regular,_ width:CGFloat=1700,_ align:NSTextAlignment = .left) {
    let style=NSMutableParagraphStyle();style.alignment=align;style.lineBreakMode = .byWordWrapping;style.lineSpacing=6
    let f=NSFont.systemFont(ofSize:size,weight:weight)
    (s as NSString).draw(in:CGRect(x:x,y:y,width:width,height:size*4+30),withAttributes:[.font:f,.foregroundColor:color,.paragraphStyle:style])
}
private func small(_ s:String,_ x:CGFloat,_ y:CGFloat,_ color:NSColor=muted,_ width:CGFloat=500){text(s,x,y,27,color,.medium,width)}
private func arrow(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ x2:CGFloat,_ y2:CGFloat,_ color:NSColor=mint,_ width:CGFloat=5){line(g,[CGPoint(x:x,y:y),CGPoint(x:x2,y:y2)],color,width);let a=atan2(y2-y,x2-x);line(g,[CGPoint(x:x2-18*cos(a-0.5),y:y2-18*sin(a-0.5)),CGPoint(x:x2,y:y2),CGPoint(x:x2-18*cos(a+0.5),y:y2-18*sin(a+0.5))],color,width)}
private func pill(_ g:CGContext,_ s:String,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ color:NSColor=mint){rect(g,x,y,w,50,color,25,0.12);text(s,x,y+8,25,color,.semibold,w,.center)}
private func bolt(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ size:CGFloat,_ color:NSColor=mint){path(g,[CGPoint(x:x+size*0.10,y:y-size*0.50),CGPoint(x:x-size*0.35,y:y+size*0.08),CGPoint(x:x-size*0.03,y:y+size*0.08),CGPoint(x:x-size*0.12,y:y+size*0.50),CGPoint(x:x+size*0.35,y:y-size*0.08),CGPoint(x:x+size*0.04,y:y-size*0.08)],color)}
private func outlet(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat=1){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);rect(g,-100,-110,200,220,panel,30);ring(g,0,0,72,muted,3);line(g,[CGPoint(x:-28,y:0),CGPoint(x:-28,y:32)],white,13);line(g,[CGPoint(x:28,y:0),CGPoint(x:28,y:32)],white,13);line(g,[CGPoint(x:0,y:-44),CGPoint(x:0,y:-18)],white,13);g.restoreGState()}
private func bulb(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat=1,_ glow:CGFloat=1){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);for i in stride(from:5,through:1,by:-1){circle(g,0,-15,CGFloat(65+i*13),amber,0.013*glow)};circle(g,0,-15,60,amber,0.12+0.13*glow);ring(g,0,-15,60,amber,5);line(g,[CGPoint(x:-27,y:36),CGPoint(x:-22,y:65),CGPoint(x:22,y:65),CGPoint(x:27,y:36)],amber,5);line(g,[CGPoint(x:-20,y:78),CGPoint(x:20,y:78)],white,7);line(g,[CGPoint(x:-16,y:91),CGPoint(x:16,y:91)],white,5);line(g,[CGPoint(x:-10,y:59),CGPoint(x:-12,y:-8),CGPoint(x:12,y:-8),CGPoint(x:10,y:59)],amber,4);g.restoreGState()}
private func house(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat=1,_ color:NSColor=mint){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);path(g,[CGPoint(x:-85,y:-15),CGPoint(x:0,y:-85),CGPoint(x:85,y:-15)],panel);line(g,[CGPoint(x:-100,y:-10),CGPoint(x:0,y:-95),CGPoint(x:100,y:-10)],color,7);rect(g,-73,-14,146,120,panel,4);line(g,[CGPoint(x:-73,y:-14),CGPoint(x:-73,y:106),CGPoint(x:73,y:106),CGPoint(x:73,y:-14)],color,5);rect(g,-50,10,42,40,amber,3,0.65);rect(g,20,38,31,68,color,3,0.25);g.restoreGState()}
private func tower(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat=1,_ color:NSColor=mint){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);line(g,[CGPoint(x:-70,y:130),CGPoint(x:0,y:-120),CGPoint(x:70,y:130)],color,6);line(g,[CGPoint(x:-60,y:100),CGPoint(x:37,y:10),CGPoint(x:-32,y:-10),CGPoint(x:22,y:-55)],color,4);line(g,[CGPoint(x:60,y:100),CGPoint(x:-37,y:10),CGPoint(x:32,y:-10),CGPoint(x:-22,y:-55)],color,4);line(g,[CGPoint(x:-95,y:-55),CGPoint(x:95,y:-55)],color,6);line(g,[CGPoint(x:-115,y:-5),CGPoint(x:115,y:-5)],color,6);for a in [-85.0,-45,45,85]{line(g,[CGPoint(x:a,y:-55),CGPoint(x:a,y:-35)],amber,5)};line(g,[CGPoint(x:-80,y:133),CGPoint(x:80,y:133)],color,6);g.restoreGState()}
private func turbine(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat,_ t:Double){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);line(g,[CGPoint(x:0,y:0),CGPoint(x:0,y:135)],muted,7);g.rotate(by:CGFloat(t));for i in 0..<3{g.saveGState();g.rotate(by:CGFloat(i)*2*CGFloat.pi/3);path(g,[CGPoint(x:-8,y:4),CGPoint(x:-4,y:-105),CGPoint(x:12,y:-24),CGPoint(x:9,y:5)],mint);g.restoreGState()};circle(g,0,0,12,white);g.restoreGState()}
private func plant(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat=1){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);rect(g,-94,-5,170,110,panel,8);line(g,[CGPoint(x:-100,y:105),CGPoint(x:100,y:105)],mint,5);path(g,[CGPoint(x:-75,y:-5),CGPoint(x:-60,y:-110),CGPoint(x:-28,y:-110),CGPoint(x:-14,y:-5)],muted);path(g,[CGPoint(x:4,y:-5),CGPoint(x:20,y:-90),CGPoint(x:52,y:-90),CGPoint(x:66,y:-5)],muted);for a in [-70.0,-20,30]{rect(g,CGFloat(a),35,24,38,amber,3,0.6)};g.restoreGState()}
private func solar(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat=1){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);circle(g,48,-62,25,amber);rect(g,-90,-10,180,90,blue,8,0.25);for i in 0...3{let yy=CGFloat(i)*30-10;line(g,[CGPoint(x:-90,y:yy),CGPoint(x:90,y:yy)],blue,2)};for i in 0...4{let xx=CGFloat(i)*45-90;line(g,[CGPoint(x:xx,y:-10),CGPoint(x:xx,y:80)],blue,2)};line(g,[CGPoint(x:-50,y:80),CGPoint(x:-60,y:110)],muted,5);line(g,[CGPoint(x:50,y:80),CGPoint(x:60,y:110)],muted,5);g.restoreGState()}
private func transformer(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat=1){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);rect(g,-94,-50,188,130,panel,12);for i in 0..<9{let xx=CGFloat(i)*17-68;line(g,[CGPoint(x:xx,y:-32),CGPoint(x:xx,y:65)],muted,4)};for xx: CGFloat in [-60,0,60]{line(g,[CGPoint(x:xx,y:-50),CGPoint(x:xx,y:-99)],mint,8);for yy: CGFloat in [-90,-78,-66]{line(g,[CGPoint(x:xx-10,y:yy),CGPoint(x:xx+10,y:yy)],mint,3)}};line(g,[CGPoint(x:-108,y:87),CGPoint(x:108,y:87)],mint,5);g.restoreGState()}
private func battery(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat=1){g.saveGState();g.translateBy(x:x,y:y);g.scaleBy(x:s,y:s);rect(g,-70,-95,140,190,panel,15);rect(g,-23,-110,46,16,muted,4);for i in 0..<3{rect(g,-47,CGFloat(i)*48-65,94,34,mint,4,0.65)};g.restoreGState()}
private let titles=["按下开关，发生了什么？","先弄清：一度电有多大","发电，是把能量换一种形式","你接入的，是一张网","远行之前，先升高电压","电流小一点，损耗少很多","接近城市，电压逐级降低","最后一段路，就在家里","插座里的电，一直在变化","电子不必从电厂跑到你家","每一次用电，都牵动全网","一度电背后，是整个系统"]
private let kickers=["从一个插座开始","01  ·  能量的单位","02  ·  能量转换","03  ·  输电网络","04  ·  高压的意义","05  ·  电流与损耗","06  ·  变电与配电","07  ·  家庭回路","08  ·  交流电","09  ·  能量怎样传递","10  ·  动态平衡","回到你的插座"]

func drawFrame(_ context: CGContext, width: Int, height: Int, scene: Int, progress: Double, subtitle: String, elapsed: Double, total: Double) {
    let g=context;g.saveGState();g.translateBy(x:0,y:CGFloat(height));g.scaleBy(x:CGFloat(width)/1920,y:-CGFloat(height)/1080)
    NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(cgContext:g,flipped:true)
    let p=CGFloat(max(0,min(1,progress))), t=elapsed
    rect(g,0,0,1920,1080,ink,0)
    // Fine engineering grid and a restrained ambient light field.
    for x in stride(from:0,through:1920,by:80){line(g,[CGPoint(x:x,y:0),CGPoint(x:x,y:1080)],muted,0.6,0.065)}
    for y in stride(from:0,through:1080,by:80){line(g,[CGPoint(x:0,y:y),CGPoint(x:1920,y:y)],muted,0.6,0.065)}
    for i in stride(from:8,through:1,by:-1){circle(g,1660,380,CGFloat(i)*65,mint,0.008)}
    g.setAlpha(min(1, min(p * 65, (1 - p) * 65)))
    small("能 量 观 察 室",112,45,mint,430);small("一度电如何来到插座",1330,45,muted,480)
    line(g,[CGPoint(x:112,y:95),CGPoint(x:1808,y:95)],muted,1,0.25)
    let si=max(0,min(11,scene))
    text(kickers[si],114,125,27,mint,.semibold)
    text(titles[si],108,178,70,white,.semibold,1710)
    switch si {
    case 0:
        rect(g,120,328,780,475,panel,30,0.55)
        small("你看到的",160,365)
        outlet(g,325,585,1.22)
        line(g,[CGPoint(x:445,y:585),CGPoint(x:555,y:585),CGPoint(x:555,y:660),CGPoint(x:725,y:660),CGPoint(x:725,y:650)],mint,6)
        bulb(g,725,530,1.05,0.65+0.35*sin(CGFloat(t)*2))
        pill(g,"一按，就亮",500,725,240,amber)
        text("插座背后",1030,365,45,white,.semibold)
        text("是一场跨越空间的\n能量接力。",1030,440,55,white,.medium,680)
        let labels=["发电","输电","配电","调度"]
        for i in 0..<4{pill(g,labels[i],1030+CGFloat(i%2)*260,625+CGFloat(i/2)*74,220,i==3 ? amber:mint)}
    case 1:
        text("1",145,320,170,mint,.light,300);text("度电",265,402,62,white,.medium,350)
        text("= 1 千瓦时",155,520,54,white,.semibold,650)
        small("1 kWh = 360 万焦耳",160,605,mint,650)
        small("功率 × 时间 = 电能",160,730,muted,650)
        rect(g,880,338,900,192,panel,25)
        text("1000 W",930,370,60,white,.medium,430);text("× 1 小时",1355,382,46,mint,.medium,400)
        rect(g,880,565,900,192,panel,25)
        text("10 W",930,598,60,white,.medium,430);text("× 100 小时",1325,610,46,amber,.medium,440)
        small("均按额定功率持续运行的理想情况计算",900,788,muted,850)
    case 2:
        let xs:[CGFloat]=[340,950,1560]
        for x in xs{rect(g,x-245,335,490,460,panel,25,0.7)}
        plant(g,xs[0],500,0.8);turbine(g,xs[1]-65,475,0.65,t*0.7);solar(g,xs[2],500,0.85)
        text("火电 · 核电",xs[0]-210,650,36,white,.semibold,420,.center)
        text("水电 · 风电",xs[1]-210,650,36,white,.semibold,420,.center)
        text("光伏",xs[2]-210,650,36,white,.semibold,420,.center)
        small("热能 → 机械能 → 电能",xs[0]-215,715,mint,450)
        small("流动的水与风 → 电能",xs[1]-205,715,mint,440)
        small("光能 → 直流电 → 逆变器",xs[2]-215,715,blue,460)
        small("发电不制造电子；它把其他形式的能量转为电能。",123,825,muted,1620)
    case 3:
        let nodes:[CGPoint]=[.init(x:290,y:440),.init(x:310,y:720),.init(x:690,y:520),.init(x:995,y:375),.init(x:1060,y:710),.init(x:1420,y:530),.init(x:1660,y:395),.init(x:1695,y:730)]
        let edges=[(0,2),(1,2),(2,3),(2,4),(3,4),(3,5),(4,5),(5,6),(5,7)]
        for (a,b) in edges{line(g,[nodes[a],nodes[b]],mint,4,0.45);let f=CGFloat((t*0.17+Double(a)*0.11).truncatingRemainder(dividingBy:1));let q=CGPoint(x:nodes[a].x+(nodes[b].x-nodes[a].x)*f,y:nodes[a].y+(nodes[b].y-nodes[a].y)*f);circle(g,q.x,q.y,7,mint)}
        plant(g,290,420,0.5);turbine(g,310,680,0.45,t);tower(g,690,520,0.6);tower(g,995,375,0.45);transformer(g,1060,710,0.55);transformer(g,1420,530,0.6);house(g,1660,395,0.5);house(g,1695,730,0.5)
        pill(g,"多个电源",145,316,260);pill(g,"互相连接 · 共同供电",820,805,420);pill(g,"许多用户",1510,565,260,amber)
        small("光点表示能量流示意，不代表单个电子的行程",120,850,muted,1300)
    case 4:
        plant(g,290,565,1.05);transformer(g,730,565,1.05);tower(g,1280,555,1.35)
        arrow(g,410,560,590,560);arrow(g,875,560,1075,560)
        line(g,[CGPoint(x:1434,y:480),CGPoint(x:1810,y:480)],mint,5)
        line(g,[CGPoint(x:1434,y:550),CGPoint(x:1810,y:550)],mint,5)
        text("发电",170,745,40,white,.semibold,250,.center)
        text("升压变压器",550,745,40,white,.semibold,360,.center)
        text("高压输电",1120,745,40,white,.semibold,330,.center)
        pill(g,"更高电压",1440,360,310,mint);pill(g,"更小电流",1440,655,310,amber)
        small("输送功率相同的条件下",1420,730,muted,420)
    case 5:
        rect(g,120,320,800,480,panel,26);rect(g,970,320,830,480,panel,26)
        small("先看电流",160,350);text("电压 × 10",160,410,61,white,.semibold,700)
        arrow(g,330,505,330,570,mint,5);text("电流 ÷ 10",160,605,61,mint,.semibold,700)
        small("再看线路发热",1010,350);text("P损耗 = I²R",1010,410,67,white,.medium,740)
        text("损耗变为",1010,545,42,white,.medium,390);text("1/100",1010,610,95,amber,.medium,700)
        small("简化比较：输送功率、线路电阻和功率因数不变",123,827,muted,1680)
    case 6:
        let xs:[CGFloat]=[280,720,1160,1620]
        tower(g,xs[0],520,0.82);transformer(g,xs[1],540,0.9);transformer(g,xs[2],540,0.85);house(g,xs[3],545,0.85)
        for i in 0..<3{arrow(g,xs[i]+125,540,xs[i+1]-135,540,mint,4)}
        let labs=["高压输电","城市变电站","社区变压器","家庭插座"]
        let vals=["远距离输送","逐级降压","10 kV → 低压","220 V"]
        for i in 0..<4{text(labs[i],xs[i]-190,690,36,white,.semibold,380,.center);text(vals[i],xs[i]-205,752,31,i==3 ? amber:mint,.medium,410,.center)}
        pill(g,"电压路线示意 · 实际网络和等级因地区而异",525,335,870)
    case 7:
        let xs:[CGFloat]=[285,735,1185,1630]
        rect(g,195,420,180,245,panel,20);rect(g,220,455,130,72,mint,8,0.12);text("kWh",225,470,35,mint,.medium,120,.center);text("001.00",214,565,28,white,.medium,145,.center)
        rect(g,625,420,220,245,panel,20);for i in 0..<3{rect(g,655+CGFloat(i)*52,470,33,96,muted,5,0.5);rect(g,659+CGFloat(i)*52,497,25,30,mint,4)}
        outlet(g,1185,540,0.95);bulb(g,1630,520,0.92)
        for i in 0..<3{arrow(g,xs[i]+120,540,xs[i+1]-125,540,mint,4)}
        let labs=["电表","配电箱","插座","电器"]
        let desc=["累计电能","分路与保护","提供接入点","转换成光、热、运动"]
        for i in 0..<4{text(labs[i],xs[i]-160,700,39,white,.semibold,320,.center);text(desc[i],xs[i]-205,762,29,muted,.regular,410,.center)}
        pill(g,"相线—相线  380 V",400,330,480,blue);pill(g,"相线—中性线  220 V",930,330,570,mint)
    case 8:
        text("220",130,335,140,mint,.light,620);text("V",400,415,55,mint,.medium,130)
        small("电压的有效值",142,515,white,580)
        text("50",130,605,115,amber,.light,420);text("Hz",320,670,49,amber,.medium,160)
        small("每秒 50 个完整周期",142,768,white,620)
        rect(g,720,337,1080,465,panel,24,0.7)
        line(g,[CGPoint(x:780,y:570),CGPoint(x:1750,y:570)],muted,2,0.5)
        line(g,[CGPoint(x:800,y:395),CGPoint(x:800,y:740)],muted,2,0.5)
        var pts:[CGPoint]=[]
        for x in stride(from:0,through:920,by:4){let phase=CGFloat(x)/920*CGFloat.pi*4-CGFloat(t)*1.5;pts.append(CGPoint(x:810+CGFloat(x),y:570-sin(phase)*135))};line(g,pts,mint,6)
        text("电压随时间周期变化",1000,379,34,white,.semibold,650)
        small("+",750,395,muted,60);small("−",750,710,muted,60);small("时间 →",1595,735,muted,170)
        small("理想正弦峰值约 311 V · 波形已放慢",1010,825,muted,780)
    case 9:
        pill(g,"导线里的电子：局部往复",120,325,620,blue)
        rect(g,150,445,1600,125,blue,60,0.12)
        line(g,[CGPoint(x:170,y:445),CGPoint(x:1730,y:445)],blue,3,0.5);line(g,[CGPoint(x:170,y:570),CGPoint(x:1730,y:570)],blue,3,0.5)
        for i in 0..<18{let x=200+CGFloat(i)*86+sin(CGFloat(t)*2.8)*20;circle(g,x,507,12,blue);text("−",x-11,489,24,ink,.bold,25,.center)}
        for i in 0..<5{let x=225+CGFloat(i)*335;arrow(g,x-24,610,x+24,610,blue,3);arrow(g,x+24,635,x-24,635,blue,3)}
        pill(g,"能量：通过电磁场传递",120,720,620,mint)
        arrow(g,835,750,1720,750,mint,8)
        for i in 0..<4{let x=CGFloat((t*240+Double(i)*230).truncatingRemainder(dividingBy:860))+850;circle(g,x,750,10,mint,0.9)}
        small("响应传播很快，不意味着电子跑完了全程。",835,805,white,940)
    case 10:
        rect(g,750,335,430,430,panel,30)
        ring(g,965,520,128,muted,3,0.3)
        let phase=CGFloat(sin(t*0.55))*0.10
        line(g,[CGPoint(x:965,y:520),CGPoint(x:965+sin(phase)*98,y:520-cos(phase)*98)],mint,8)
        circle(g,965,520,12,mint)
        text("50 Hz",815,575,62,white,.semibold,300,.center)
        small("持续调节，维持平衡",797,700,mint,390)
        plant(g,310,495,0.85);house(g,1605,495,0.85)
        arrow(g,460,510,700,510,mint,6);arrow(g,1230,510,1460,510,amber,6)
        text("供给",192,650,42,white,.semibold,240,.center);text("需求 + 损耗",1410,650,42,white,.semibold,420,.center)
        battery(g,560,750,0.38);pill(g,"发电调节",130,760,290);pill(g,"储能",615,760,130);pill(g,"跨区互济",1200,760,270);pill(g,"负荷调节",1510,760,280,amber)
        small("频率是电网平衡状态的重要信号",750,825,muted,700)
    default:
        let labels=["发电","输电","配电","调度"]
        for i in 0..<4{let x=285+CGFloat(i)*445;circle(g,x,430,70,mint,0.08);if i==0{plant(g,x,430,0.40)}else if i==1{tower(g,x,430,0.4)}else if i==2{transformer(g,x,430,0.4)}else{ring(g,x,430,40,mint,4);line(g,[CGPoint(x:x,y:430),CGPoint(x:x+22,y:410)],mint,5)};text(labels[i],x-100,532,34,white,.semibold,200,.center);if i<3{arrow(g,x+95,430,x+345,430,mint,3)}}
        text("你用掉的，是一份能量。",180,640,68,white,.semibold,1560,.center)
        text("支撑它的，是一整张时刻协作的电网。",180,740,45,mint,.medium,1560,.center)
    }
    g.setAlpha(1)
    // Captions remain in a dedicated safe area on every frame.
    rect(g,94,900,1732,121,ink,22,0.96)
    let subtitleSize:CGFloat=subtitle.count>37 ? 36:42
    text(subtitle,140,922,subtitleSize,white,.medium,1640,.center)
    // Twelve chapter marks and a continuous playhead.
    let trackX:CGFloat=120,trackW:CGFloat=1680
    rect(g,trackX,1040,trackW,4,muted,2,0.2)
    rect(g,trackX,1040,trackW*CGFloat(min(1,max(0,elapsed/max(1,total)))),4,mint,2)
    for i in 0..<12{circle(g,trackX+CGFloat(i)*trackW/11,1042,3,i<=si ? mint:muted)}
    text(String(format:"%02d / 12",si+1),1660,850,23,muted,.medium,150,.right)
    NSGraphicsContext.restoreGraphicsState();g.restoreGState()
    _ = p
}
