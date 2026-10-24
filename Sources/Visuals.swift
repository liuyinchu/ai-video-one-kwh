import AppKit
import CoreGraphics

// V2: every explanation is staged by the actual narration sentence and its audio progress.
private enum V {
    static let paper=NSColor(calibratedRed:0.962,green:0.957,blue:0.935,alpha:1)
    static let ink=NSColor(calibratedRed:0.090,green:0.165,blue:0.208,alpha:1)
    static let blue=NSColor(calibratedRed:0.192,green:0.333,blue:0.906,alpha:1)
    static let orange=NSColor(calibratedRed:0.96,green:0.647,blue:0.29,alpha:1)
    static let green=NSColor(calibratedRed:0.165,green:0.62,blue:0.514,alpha:1)
    static let red=NSColor(calibratedRed:0.83,green:0.31,blue:0.25,alpha:1)
    static let muted=NSColor(calibratedRed:0.42,green:0.49,blue:0.52,alpha:1)
    static let lineColor=NSColor(calibratedRed:0.84,green:0.86,blue:0.85,alpha:1)
    static let white=NSColor.white
    static func cg(_ color:NSColor,_ alpha:CGFloat=1)->CGColor {color.withAlphaComponent(alpha).cgColor}
    static func box(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat,_ fill:NSColor,_ r:CGFloat=24,_ alpha:CGFloat=1){g.setFillColor(cg(fill,alpha));g.addPath(CGPath(roundedRect:CGRect(x:x,y:y,width:w,height:h),cornerWidth:r,cornerHeight:r,transform:nil));g.fillPath()}
    static func circle(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ r:CGFloat,_ color:NSColor,_ alpha:CGFloat=1){g.setFillColor(cg(color,alpha));g.fillEllipse(in:CGRect(x:x-r,y:y-r,width:r*2,height:r*2))}
    static func ring(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ r:CGFloat,_ color:NSColor,_ w:CGFloat=3,_ alpha:CGFloat=1){g.setStrokeColor(cg(color,alpha));g.setLineWidth(w);g.strokeEllipse(in:CGRect(x:x-r,y:y-r,width:r*2,height:r*2))}
    static func line(_ g:CGContext,_ pts:[CGPoint],_ color:NSColor=blue,_ w:CGFloat=5,_ alpha:CGFloat=1){guard let first=pts.first else{return};g.setStrokeColor(cg(color,alpha));g.setLineWidth(w);g.setLineCap(.round);g.setLineJoin(.round);g.beginPath();g.move(to:first);for p in pts.dropFirst(){g.addLine(to:p)};g.strokePath()}
    static func path(_ g:CGContext,_ pts:[CGPoint],_ color:NSColor){guard let first=pts.first else{return};g.setFillColor(cg(color));g.beginPath();g.move(to:first);for p in pts.dropFirst(){g.addLine(to:p)};g.closePath();g.fillPath()}
    static func text(_ s:String,_ x:CGFloat,_ y:CGFloat,_ size:CGFloat=34,_ color:NSColor=ink,_ weight:NSFont.Weight = .regular,_ width:CGFloat=1600,_ align:NSTextAlignment = .left){let style=NSMutableParagraphStyle();style.alignment=align;style.lineSpacing=7;style.lineBreakMode = .byWordWrapping;(s as NSString).draw(in:CGRect(x:x,y:y,width:width,height:size*4+30),withAttributes:[.font:NSFont.systemFont(ofSize:size,weight:weight),.foregroundColor:color,.paragraphStyle:style])}
    static func small(_ s:String,_ x:CGFloat,_ y:CGFloat,_ color:NSColor=muted,_ width:CGFloat=1600){text(s,x,y,27,color,.medium,width)}
    static func arrow(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ x2:CGFloat,_ y2:CGFloat,_ color:NSColor=blue,_ w:CGFloat=5){line(g,[.init(x:x,y:y),.init(x:x2,y:y2)],color,w);let a=atan2(y2-y,x2-x);line(g,[.init(x:x2-18*cos(a-0.52),y:y2-18*sin(a-0.52)),.init(x:x2,y:y2),.init(x:x2-18*cos(a+0.52),y:y2-18*sin(a+0.52))],color,w)}
    static func pill(_ g:CGContext,_ s:String,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ color:NSColor=blue){box(g,x,y,w,49,color,24,0.09);text(s,x,y+8,25,color,.semibold,w,.center)}
    static func bolt(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ s:CGFloat,_ color:NSColor=blue){path(g,[.init(x:x+0.08*s,y:y-0.5*s),.init(x:x-0.32*s,y:y+0.06*s),.init(x:x-0.03*s,y:y+0.06*s),.init(x:x-0.10*s,y:y+0.5*s),.init(x:x+0.32*s,y:y-0.06*s),.init(x:x+0.03*s,y:y-0.06*s)],color)}
    static func smooth(_ x:CGFloat)->CGFloat{let a=max(0,min(1,x));return a*a*(3-2*a)}
    static func show(_ g:CGContext,_ a:CGFloat,_ block:()->Void){g.saveGState();g.setAlpha(max(0,min(1,a)));g.translateBy(x:0,y:(1-max(0,min(1,a)))*18);block();g.restoreGState()}
    static func flow(_ g:CGContext,_ a:CGPoint,_ b:CGPoint,_ t:Double,_ color:NSColor=blue,_ w:CGFloat=5,_ on:Bool=true){line(g,[a,b],color,w,0.18);guard on else{return};let f=CGFloat((t*0.26).truncatingRemainder(dividingBy:1));let length:CGFloat=0.18;let u=max(0,f-length);line(g,[.init(x:a.x+(b.x-a.x)*u,y:a.y+(b.y-a.y)*u),.init(x:a.x+(b.x-a.x)*f,y:a.y+(b.y-a.y)*f)],color,w)}
    static func arc(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ r:CGFloat,_ progress:CGFloat,_ color:NSColor,_ w:CGFloat=12){g.setStrokeColor(cg(color));g.setLineWidth(w);g.setLineCap(.round);g.addArc(center:.init(x:x,y:y),radius:r,startAngle:-CGFloat.pi/2,endAngle:-CGFloat.pi/2+max(0.001,min(1,progress))*2*CGFloat.pi,clockwise:false);g.strokePath()}
    static func sine(_ g:CGContext,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ amp:CGFloat,_ phase:CGFloat,_ color:NSColor=blue,_ cycles:CGFloat=2){var pts:[CGPoint]=[];for i in 0...180{let f=CGFloat(i)/180;pts.append(.init(x:x+f*w,y:y-sin(f*2*CGFloat.pi*cycles-phase)*amp))};line(g,pts,color,5)}
}
private let sceneTitles=["一壶热水，连接多远的世界？","一度电，是多少能量？","发电：把能量换一种形式","电从一张网里来","为什么要把电压升高？","电流的平方，决定发热损耗","变压器，让电压适合下一程","接通回路，电器才开始工作","220 伏，也在不断变化","电子往复，能量向前","用电一变，电网就要响应","一度电背后，是整个系统"]
private let sceneTags=["从你家的水壶出发","01 / 能量的计量","02 / 能量转换","03 / 多源互联","04 / 高压输电","05 / 看懂损耗","06 / 变电与配电","07 / 家庭回路","08 / 交流电","09 / 电子与能量","10 / 动态平衡","回到这壶热水"]

func drawFrame(_ g:CGContext,width:Int,height:Int,scene:Int,progress:Double,subtitle:String,elapsed:Double,total:Double,beat:Int=0,beatProgress:Double=0){
    g.saveGState();g.translateBy(x:0,y:CGFloat(height));g.scaleBy(x:CGFloat(width)/1920,y:-CGFloat(height)/1080)
    NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(cgContext:g,flipped:true)
    let si=max(0,min(11,scene)), b=max(0,min(3,beat)), q=CGFloat(max(0,min(1,beatProgress))), t=elapsed
    let e=V.smooth(q*2.3), fade=min(1,min(CGFloat(progress)*90,(1-CGFloat(progress))*90))
    func seen(_ n:Int)->CGFloat {b>n ? 1 : (b==n ? e:0)}
    V.box(g,0,0,1920,1080,V.paper,0)
    V.circle(g,1720,150,330,V.orange,0.035)
    V.small("能 量 观 察 室",90,43,V.ink,540);V.small("一度电如何来到插座",1380,43,V.muted,480)
    V.line(g,[.init(x:90,y:99),.init(x:1830,y:99)],V.lineColor,1)
    g.saveGState();g.setAlpha(fade)
    V.text(sceneTags[si],94,129,26,V.blue,.semibold)
    V.text(sceneTitles[si],87,177,66,V.ink,.semibold,1720)
    V.text(String(format:"%02d",si+1),1630,105,125,V.ink.withAlphaComponent(0.035),.bold,220,.right)
    switch si {
    case 0:
        V.box(g,100,315,760,520,V.white,34)
        V.line(g,[.init(x:160,y:727),.init(x:805,y:727)],V.lineColor,4)
        Art.kettle(g,x:540,y:565,scale:1.65,heat:0.15+seen(1)*0.7,steam:seen(3)*0.55,time:t)
        Art.socket(g,x:235,y:525,scale:0.8)
        V.line(g,[.init(x:280,y:560),.init(x:340,y:560),.init(x:340,y:695),.init(x:490,y:695)],V.ink,5)
        V.pill(g,"一个开关",185,755,235)
        V.show(g,seen(0)) {V.text("几分钟后，\n水就热了。",970,342,65,V.ink,.semibold,780)}
        V.show(g,seen(1)) {V.pill(g,"能量从哪里来？",970,555,620,V.blue)}
        V.show(g,seen(2)) {
            Art.plant(g,x:1030,y:730,scale:0.48);Art.tower(g,x:1275,y:730,scale:0.48);Art.house(g,x:1525,y:730,scale:0.48,lit:true)
            V.flow(g,.init(x:1090,y:730),.init(x:1210,y:730),t);V.flow(g,.init(x:1340,y:730),.init(x:1455,y:730),t+0.3)
        }
        V.show(g,seen(3)){V.small("跟着能量，回到它的来处。",970,835,V.ink,790)}
    case 1:
        V.box(g,100,320,570,510,V.blue,32)
        V.ring(g,380,525,145,V.white,3,0.2);V.arc(g,380,525,145,0.15+seen(0)*0.85,V.orange,12)
        V.text("1",265,405,145,V.white,.medium,230,.center);V.text("kWh",250,570,61,V.white,.medium,260,.center)
        V.text("一度电 = 一千瓦时",140,730,38,V.white,.semibold,490,.center)
        for i in 0..<2 {
            let yy:CGFloat=CGFloat(i)*222+325, active=seen(i+1)
            V.show(g,active){
                V.box(g,730,yy,1090,193,V.white,26)
                V.text(i==0 ? "1000 W":"10 W",778,yy+26,57,V.ink,.medium,440)
                V.text(i==0 ? "× 1 小时":"× 100 小时",1210,yy+35,43,V.blue,.semibold,540)
                V.box(g,782,yy+130,964,11,V.lineColor,5)
                let fill=b>i+1 ? CGFloat(1):V.smooth(max(0,(q-0.1)/0.85))
                V.box(g,782,yy+130,964*fill,11,i==0 ? V.blue:V.green,5)
                V.small("累计能量：1 kWh",1230,yy+149,V.muted,510)
            }
        }
        V.show(g,seen(3)){V.pill(g,"千瓦：用电快慢",750,790,455,V.blue);V.pill(g,"千瓦时：累计多少",1250,790,530,V.green)}
        V.small("按恒定功率计算；两条时间轴分别为 1 小时与 100 小时，均已加速。",105,863,V.muted,1680)
    case 2:
        let src:CGFloat=290, gen:CGFloat=960, out:CGFloat=1600
        V.box(g,100,320,1710,320,V.white,30)
        Art.plant(g,x:src,y:455,scale:0.75)
        V.text("热能",src-90,565,36,V.ink,.semibold,180,.center)
        V.show(g,seen(1)){
            V.flow(g,.init(x:430,y:475),.init(x:780,y:475),t,V.orange,7)
            V.pill(g,"蒸汽推动 · 转起来",460,365,365,V.orange)
            Art.generator(g,x:gen,y:470,scale:0.94,time:t)
            V.text("机械能",gen-140,565,36,V.ink,.semibold,280,.center)
        }
        V.show(g,seen(1)) {V.flow(g,.init(x:1110,y:475),.init(x:1460,y:475),t+0.5,V.blue,7);V.bolt(g,out,470,130);V.text("电能",out-100,565,36,V.ink,.semibold,200,.center)}
        V.show(g,seen(1)){
            Art.wind(g,x:330,y:750,scale:0.55,time:t);V.small("水与风也能带动发电机",425,742,V.ink,520)
        }
        V.show(g,seen(2)){
            V.box(g,970,686,840,170,V.blue,25,0.07);Art.solar(g,x:1085,y:770,scale:0.55)
            V.text("直流",1210,737,32,V.blue,.semibold,150);V.show(g,seen(3)){V.arrow(g,1335,767,1400,767,V.blue,4)
            V.box(g,1430,725,155,80,V.white,16);V.text("逆变器",1430,744,28,V.ink,.semibold,155,.center)
            V.arrow(g,1600,767,1660,767,V.blue,4);V.sine(g,1680,767,87,25,CGFloat(t),V.blue,1)}
            V.small("光伏走另一条路",987,862,V.muted,810)
        }
    case 3:
        let points:[CGPoint]=[.init(x:245,y:420),.init(x:245,y:720),.init(x:675,y:525),.init(x:1050,y:380),.init(x:1050,y:750),.init(x:1390,y:550),.init(x:1700,y:390),.init(x:1700,y:740)]
        let links=[(0,2),(2,5),(5,6),(1,2),(2,3),(2,4),(3,5),(4,5),(5,7)]
        for (i,ab) in links.enumerated(){let a=i<3 ? seen(0):seen(1);V.show(g,a){V.flow(g,points[ab.0],points[ab.1],t+Double(i)*0.5,i==8 && b>=2 ? V.orange:V.blue,i==8 && b>=2 ? 9:5)}}
        Art.plant(g,x:245,y:420,scale:0.53);Art.tower(g,x:675,y:520,scale:0.64);Art.transformer(g,x:1390,y:550,scale:0.7,pulse:CGFloat(sin(t)*0.5+0.5));Art.house(g,x:1700,y:390,scale:0.55,lit:true)
        V.show(g,seen(1)){Art.wind(g,x:245,y:720,scale:0.52,time:t);Art.tower(g,x:1050,y:380,scale:0.47);Art.transformer(g,x:1050,y:750,scale:0.55,pulse:0.5);Art.house(g,x:1700,y:740,scale:0.55,lit:b>=2)}
        V.show(g,seen(2)){V.pill(g,"用电需求变化",1480,590,330,V.orange)}
        V.show(g,seen(3)){V.pill(g,"多个电源 · 多条线路 · 共同供电",520,795,870,V.blue)}
        V.small("光带为能量流示意；实际潮流由网络与运行状态共同决定。",105,867,V.muted,1670)
    case 4:
        let ramp=b==3 ? V.smooth(q):CGFloat(0)
        V.box(g,100,320,1070,500,V.white,30)
        Art.plant(g,x:260,y:590,scale:0.7);Art.house(g,x:1020,y:590,scale:0.7,lit:true)
        let wireY:CGFloat=550, heat=1-ramp*0.85
        V.line(g,[.init(x:380,y:wireY),.init(x:900,y:wireY)],V.ink,6)
        V.flow(g,.init(x:390,y:wireY),.init(x:890,y:wireY),t,V.blue,18-ramp*13)
        for i in 0..<8{let x=420+CGFloat(i)*62;var a:[CGPoint]=[];for j in 0..<20{let yy=CGFloat(j)*3.0;a.append(.init(x:x+sin(yy*0.13-CGFloat(t)*2)*8,y:wireY-25-yy))};V.line(g,a,V.orange,3,heat*0.8)}
        V.pill(g,ramp<0.5 ? "导线有电阻，电流让它发热":"升高电压，电流变小",330,358,650,ramp<0.5 ? V.orange:V.blue)
        V.show(g,seen(2)){Art.transformer(g,x:580,y:700,scale:0.6,pulse:CGFloat(sin(t*3)*0.5+0.5));V.text("升压",720,698,38,V.blue,.semibold,220)}
        V.box(g,1230,320,580,500,V.blue,30)
        V.text(b<2 ? "怎样少浪费一点？":"同样的输送功率",1270,360,35,V.white,.semibold,500)
        if b<2 {V.text("电流越大，\n线路越热。",1270,490,54,V.white,.semibold,480)};V.show(g,seen(2)){V.text("P = U × I",1270,430,53,V.white,.medium,500)
        V.small("电压 U",1290,550,V.white,210);V.small("电流 I",1560,550,V.white,210)
        let ratio:CGFloat=1+9*ramp, uh:CGFloat=20*ratio, ih:CGFloat=200/ratio
        V.box(g,1330,760-uh,90,uh,V.orange,12);V.box(g,1600,760-ih,90,ih,V.white,12)
        V.small(ramp>0.5 ? "↑":"",1352,780,V.white,100);V.small(ramp>0.5 ? "↓":"",1622,780,V.white,100)}
        V.small("单相、功率因数为 1 的简化模型；输送功率保持不变。",105,864,V.muted,1700)
    case 5:
        V.box(g,100,320,740,520,V.blue,30)
        V.text("线路电阻发热功率",145,355,35,V.white,.semibold,650)
        V.text("P损 = I²R",145,425,88,V.white,.medium,650)
        V.show(g,seen(1)){V.box(g,155,585,530,49,V.orange,24);V.text("电压 × 10",155,593,25,V.ink,.semibold,530,.center);V.text("电流 → 1/10",155,680,61,V.white,.semibold,640)}
        V.text("原来的损耗",925,325,35,V.ink,.semibold,720)
        let remain=b>=3 ? CGFloat(1):(b==2 ? 100-99*V.smooth(q*3):100)
        for i in 0..<100{let x:CGFloat=940+CGFloat(i%10)*51,y:CGFloat=398+CGFloat(i/10)*39;let on=CGFloat(i)<remain;V.box(g,x,y,38,27,on ? V.orange:V.lineColor,7,on ? 1:0.5)}
        let count=Int(ceil(remain))
        V.text("\(count)",1515,430,116,b>=2 ? V.green:V.orange,.medium,300,.center)
        V.text("/ 100",1515,560,48,V.muted,.medium,300,.center)
        V.show(g,seen(2)){V.pill(g,remain<1.5 ? "只剩 1%":"损耗减小中",1490,685,315,V.green)}
        V.show(g,seen(3)){V.small("高压输电，让远方的能量少些损耗。",930,810,V.ink,880)}
        V.small("比较条件：输送功率、线路电阻、功率因数相同；方格表示相对发热功率。",105,865,V.muted,1700)
    case 6:
        if b<2 {
            V.box(g,100,320,1710,520,V.white,30)
            V.box(g,620,435,640,260,V.lineColor,35)
            V.box(g,703,500,475,130,V.white,10)
            // Separate windings couple through changing magnetic flux, never a wire across the gap.
            for i in 0..<8 {V.ring(g,650,460+CGFloat(i)*31,39,V.orange,7)}
            for i in 0..<5 {V.ring(g,1225,475+CGFloat(i)*43,39,V.blue,7)}
            let direction=sin(t*2)>0
            V.arrow(g,direction ? 770:1100,467,direction ? 1100:770,467,V.green,5)
            V.arrow(g,direction ? 1100:770,663,direction ? 770:1100,663,V.green,5)
            V.sine(g,220,560,280,75,CGFloat(t)*2,V.orange,1.4)
            V.text("交流输入",250,720,38,V.ink,.semibold,350)
            V.show(g,seen(1)){V.sine(g,1390,560,270,45,CGFloat(t)*2,V.blue,1.4);V.text("不同电压的交流",1320,720,38,V.ink,.semibold,460)}
            V.pill(g,"变化磁场 · 联系两组线圈",630,345,665,V.green)
            V.small("两组线圈彼此绝缘；匝数比决定理想电压比。",530,800,V.muted,1050)
        } else {
            V.show(g,b==2 ? e:1){
                V.line(g,[.init(x:220,y:590),.init(x:1700,y:590)],V.lineColor,12)
                let xs:[CGFloat]=[265,730,1190,1655], labels=["高压输电","城市变电站","社区变压器","居民家庭"], volts=["适合远距离","10 kV 配电","继续降压","220 V"]
                let cursor:CGFloat=b==2 ? 265+925*q:1190+465*q
                V.line(g,[.init(x:220,y:590),.init(x:min(1700,cursor),y:590)],V.blue,12);V.circle(g,min(1700,cursor),590,15,V.orange)
                for i in 0..<4{
                    V.circle(g,xs[i],505,105,V.white)
                    if i==0{Art.tower(g,x:xs[i],y:485,scale:0.75)}
                    else if i==3{Art.house(g,x:xs[i],y:495,scale:0.8,lit:b==3)}
                    else{Art.transformer(g,x:xs[i],y:495,scale:0.75,pulse:CGFloat(sin(t*3)*0.5+0.5))}
                    V.text(labels[i],xs[i]-205,675,36,V.ink,.semibold,410,.center);V.text(volts[i],xs[i]-205,740,35,i==3 ? V.green:V.blue,.medium,410,.center)
                }
                V.pill(g,"从适合远行，变成适合使用",485,332,950,V.blue)
            }
        }
        V.small("电压路线示意，实际电网的等级与接线方式因地区而异。",105,867,V.muted,1710)
    case 7:
        let closed=b>=2
        V.pill(g,"工作回路：相线 L ＋ 中性线 N",560,315,800,V.blue)
        V.line(g,[.init(x:250,y:485),.init(x:1160,y:485)],V.red,6)
        V.line(g,[.init(x:1255,y:485),.init(x:1400,y:485),.init(x:1400,y:590)],V.red,6)
        let coil:[CGPoint]=[.init(x:1400,y:590),.init(x:1384,y:600),.init(x:1416,y:614),.init(x:1384,y:628),.init(x:1416,y:642),.init(x:1384,y:656),.init(x:1400,y:670)]
        V.line(g,coil,closed ? V.orange:V.ink,7)
        V.line(g,[.init(x:1400,y:670),.init(x:1400,y:718),.init(x:250,y:718)],V.blue,6)
        V.line(g,[.init(x:250,y:485),.init(x:250,y:718)],V.ink,5)
        V.circle(g,250,600,53,V.white);V.sine(g,219,600,62,17,CGFloat(t),V.blue,1)
        V.text("L",178,460,32,V.red,.bold,70);V.text("N",178,696,32,V.blue,.bold,70)
        Art.meter(g,x:550,y:505,scale:0.72,value:closed ? 12.343+Double(b-2)*0.003+Double(q)*0.003:12.34)
        Art.breaker(g,x:880,y:505,scale:0.72)
        V.circle(g,1160,485,8,V.ink);V.circle(g,1255,485,8,V.ink)
        V.line(g,[.init(x:1160,y:485),.init(x:1255,y:closed ? 485:438)],V.ink,7)
        Art.kettle(g,x:1650,y:570,scale:1.12,heat:closed ? 0.75:0,steam:b==3 ? 0.3:0,time:t,powerOn:closed);V.small("电热电阻",1280,745,V.ink,260);if closed {V.arrow(g,1465,640,1535,640,V.orange,5)}
        V.text("电表：累计电能",370,790,33,V.ink,.semibold,360,.center)
        V.text("配电箱：保护与分路",715,790,33,V.ink,.semibold,420,.center)
        V.text(closed ? "开关闭合":"开关断开",1070,790,33,closed ? V.green:V.muted,.semibold,290,.center)
        V.text("转为热能",1410,790,33,V.orange,.semibold,330,.center)
        if closed {V.flow(g,.init(x:1000,y:485),.init(x:1160,y:485),t,V.orange,10);V.pill(g,"已接通",1130,365,200,V.green)}
        if b<2 {
            V.box(g,100,310,1720,540,V.paper,0)
            if b==0 {
                V.box(g,140,340,720,480,V.white,30);Art.meter(g,x:490,y:575,scale:1.8,value:12.34+Double(q)*0.003)
                V.text("电表记下的，是累计电能",970,410,49,V.ink,.semibold,770)
                V.text("kWh",970,535,125,V.blue,.medium,720)
                V.small("用掉多少，就累计多少。",978,730,V.muted,770)
            } else {
                V.box(g,140,340,520,480,V.white,30);Art.breaker(g,x:400,y:570,scale:1.7)
                V.flow(g,.init(x:650,y:520),.init(x:1020,y:520),t,V.blue,7);V.line(g,[.init(x:1020,y:520),.init(x:1020,y:400),.init(x:1430,y:400)],V.blue,5)
                V.line(g,[.init(x:1020,y:520),.init(x:1020,y:695),.init(x:1430,y:695)],V.blue,5)
                Art.bulb(g,x:1510,y:400,scale:0.85,glow:1);Art.socket(g,x:1510,y:695,scale:0.85)
                V.text("照明回路",1130,330,35,V.ink,.semibold,340);V.text("插座回路",1130,735,35,V.ink,.semibold,340)
                V.pill(g,"保护装置 ＋ 分路",715,540,540,V.blue)
            }
        }
        V.small("简化原理示意，不作为接线指南；正常工作回路不经保护地线。",105,865,V.muted,1710)

    case 8:
        V.box(g,100,320,1100,510,V.white,30)
        V.line(g,[.init(x:175,y:575),.init(x:1130,y:575)],V.lineColor,2)
        V.line(g,[.init(x:195,y:385),.init(x:195,y:770)],V.lineColor,2)
        V.sine(g,205,575,900,140,CGFloat(t)*1.4,V.blue,2)
        let markerX:CGFloat=660, markerY=575-sin((markerX-205)/900*4*CGFloat.pi-CGFloat(t)*1.4)*140
        V.circle(g,markerX,markerY,11,V.orange)
        V.small("＋",145,385,V.muted,50);V.small("−",145,735,V.muted,50);V.small("时间 →",990,768,V.muted,190)
        V.show(g,seen(1)){V.line(g,[.init(x:280,y:370),.init(x:280,y:400)],V.ink,2);V.line(g,[.init(x:730,y:370),.init(x:730,y:400)],V.ink,2);V.arrow(g,290,385,718,385,V.ink,2);V.pill(g,"一个完整周期 = 20 毫秒",430,321,540,V.blue)}
        V.box(g,1260,320,550,510,V.blue,30)
        V.text("50",1300,355,123,V.white,.medium,310);V.text("Hz",1575,423,48,V.white,.medium,180)
        V.text("每秒 50 个完整周期",1300,510,31,V.white,.semibold,470)
        V.show(g,seen(2)){V.line(g,[.init(x:1310,y:585),.init(x:1760,y:585)],V.white,1,0.3);V.text("220 V",1300,615,80,V.orange,.medium,470);V.text("有效值",1300,728,40,V.white,.semibold,470)}
        if b==3 {
            V.box(g,100,320,1100,510,V.white,30)
            for i in 0..<2 {
                let xx:CGFloat=180+CGFloat(i)*525
                V.text(i==0 ? "220 V 交流":"220 V 直流",xx,360,35,V.ink,.semibold,440,.center)
                V.small(i==0 ? "有效值":"恒定电压",xx+110,420,V.muted,250)
                if i==0{V.sine(g,xx+95,510,250,45,CGFloat(t)*2,V.blue,1.3)}else{V.line(g,[.init(x:xx+95,y:510),.init(x:xx+345,y:510)],V.blue,5)}
                var resistor:[CGPoint]=[.init(x:xx+110,y:610)];for j in 0..<10{resistor.append(.init(x:xx+130+CGFloat(j)*20,y:610+(j%2==0 ? -15:15)))};resistor.append(.init(x:xx+330,y:610));V.line(g,resistor,V.orange,6)
                V.box(g,xx+60,690,320,28,V.lineColor,12);V.box(g,xx+60,690,320*V.smooth(q),28,V.orange,12)
                V.small("相同电阻 · 相同时间",xx+20,755,V.ink,440)
            }
        }
        V.small("波形已放慢；同一电阻上，相同时间产生的平均热量相同。",105,865,V.muted,1710)

    case 9:
        V.pill(g,"稳态电子：局部往复",105,326,430,V.blue)
        V.box(g,120,440,1325,120,V.blue,58,0.07)
        V.line(g,[.init(x:140,y:440),.init(x:1430,y:440)],V.blue,3,0.25);V.line(g,[.init(x:140,y:560),.init(x:1430,y:560)],V.blue,3,0.25)
        for i in 0..<15{let center=190+CGFloat(i)*82, offset=CGFloat(sin(t*2.5-Double(i)*0.07))*21;V.line(g,[.init(x:center-27,y:500),.init(x:center+27,y:500)],V.blue,2,0.2);V.circle(g,center,500,3,V.blue,0.35);V.circle(g,center+offset,500,12,V.blue);V.text("−",center+offset-12,482,25,V.white,.bold,24,.center)}
        V.show(g,seen(1)){V.text("局部往复",475,600,47,V.blue,.semibold,640,.center);V.arrow(g,265,625,380,625,V.blue,4);V.arrow(g,380,650,265,650,V.blue,4)}
        V.show(g,seen(2)){
            V.pill(g,"电磁场传递能量",105,744,430,V.green)
            V.arrow(g,600,770,1420,770,V.green,12)
            let front=b>2 ? CGFloat(1):V.smooth(min(1,q/0.65));V.line(g,[.init(x:610,y:770),.init(x:610+800*front,y:770)],V.orange,12);V.circle(g,610+800*front,770,15,V.orange)
            V.small("传播前沿已大幅放慢 · 能流示意",700,815,V.green,760)
        }
        Art.kettle(g,x:1660,y:570,scale:1.22,heat:(b>2 || (b==2 && q>0.65)) ? 0.8:0.1,steam:b>=3 ? 0.45:0,time:t,powerOn:(b>2 || (b==2 && q>0.65)))
        V.text("电器吸收能量",1480,770,32,V.ink,.semibold,360,.center)
        V.small("电子不必跑完长途；电路中的电磁变化以有限速度快速传播。",105,872,V.muted,1700)
    case 10:
        let demandRise=b==0 ? V.smooth(q):CGFloat(1)
        let demand:CGFloat=190+80*demandRise
        var supply:CGFloat=190, generation:CGFloat=190, frequencyOffset:CGFloat=0
        if b==0 {frequencyOffset = -0.08*demandRise}
        if b==1 {frequencyOffset = -0.08-0.28*V.smooth(q)}
        if b==2 {
            generation=190+50*V.smooth(q)
            if q<0.3 {supply=190+80*V.smooth(q/0.3);frequencyOffset = -0.36-0.04*V.smooth(q/0.3)}
            else {let f=(q-0.3)/0.7;supply=270+10*sin(f*CGFloat.pi);frequencyOffset = -0.40*(1-V.smooth(f))}
        }
        if b==3 {supply=270;generation=240+20*V.smooth(q);frequencyOffset=0}
        let storage=max(0,supply-generation)
        let recovery=b<2 ? CGFloat(0):(b==2 ? V.smooth(q)*0.72:0.72+V.smooth(q)*0.28)
        V.box(g,100,320,560,510,V.white,30);V.box(g,1260,320,550,510,V.white,30)
        V.text("供给",145,355,45,V.ink,.semibold,460);V.text("用电需求 + 网损",1305,355,37,V.ink,.semibold,470)
        V.box(g,205,745-generation,150,generation,V.blue,18);if storage>0 {V.box(g,205,745-supply,150,storage,V.green,7)};V.box(g,1455,745-demand,150,demand,V.orange,18)
        V.line(g,[.init(x:175,y:745),.init(x:590,y:745)],V.lineColor,2);V.line(g,[.init(x:1320,y:745),.init(x:1750,y:745)],V.lineColor,2)
        Art.plant(g,x:500,y:660,scale:0.5);Art.house(g,x:1700,y:660,scale:0.45,lit:true)
        V.circle(g,955,505,153,V.white);V.arc(g,955,505,131,0.75,V.lineColor,10)
        let off=frequencyOffset, angle = -CGFloat.pi/2+off
        V.line(g,[.init(x:955,y:505),.init(x:955+cos(angle)*102,y:505+sin(angle)*102)],abs(off)>0.1 ? V.orange:V.green,8);V.circle(g,955,505,13,V.ink)
        V.text("50 Hz",805,565,59,V.ink,.semibold,300,.center);V.small("目标频率 · 变化示意",790,650,V.muted,360)
        V.text(b<2 ? "需求增加 → 频率趋降":(b==2 && q<0.3 ? "储能补入，减缓下降":"短时补回能量 → 回稳"),700,710,30,b<2 ? V.orange:V.green,.semibold,510,.center)
        V.show(g,seen(2)){Art.battery(g,x:980,y:800,scale:0.36,charge:0.95-recovery*0.4);V.pill(g,"发电调节",125,785,295,V.blue);V.pill(g,"储能放电",1320,785,330,V.green)}
        V.small("过程为示意；短暂功率缺额由系统已有储存能量承担，调节随后恢复平衡。",105,872,V.muted,1720)
    default:
        V.box(g,100,320,1060,520,V.white,30)
        let xs:[CGFloat]=[250,545,840]
        V.show(g,seen(1)){Art.plant(g,x:xs[0],y:460,scale:0.5);Art.tower(g,x:xs[1],y:460,scale:0.5);Art.transformer(g,x:xs[2],y:460,scale:0.5,pulse:0.5);V.flow(g,.init(x:320,y:460),.init(x:470,y:460),t);V.flow(g,.init(x:620,y:460),.init(x:765,y:460),t+0.4)}
        V.show(g,seen(1)){V.text("转换",170,550,31,V.ink,.semibold,160,.center);V.text("输送",465,550,31,V.ink,.semibold,160,.center);V.text("分配",760,550,31,V.ink,.semibold,160,.center)};if b==0 {V.show(g,e){V.text("水开了。\n答案，也到了。",180,440,76,V.ink,.semibold,900)}}
        V.show(g,seen(1)){V.text("能量，完成了一次接力。",145,640,49,V.ink,.semibold,970)}
        V.show(g,seen(2)){V.text("转化成热，留下计量。",145,730,42,V.blue,.semibold,720);Art.meter(g,x:1000,y:740,scale:0.55,value:12.349)}
        Art.kettle(g,x:1510,y:565,scale:1.95,heat:1,steam:0.85,time:t,powerOn:false);V.small("开关已跳停 · 保留余热",1260,740,V.muted,600)
        V.pill(g,"热水好了",1320,800,410,V.orange)
        V.show(g,seen(3)){V.small("小小插座，连接着整张时刻协作的电网。",105,870,V.ink,1660)}
    }
    g.restoreGState()
    // A quiet subtitle band preserves contrast even on a bright scene.
    V.box(g,90,927,1740,95,V.ink,21)
    V.text(subtitle,126,949,subtitle.count>38 ? 35:40,V.white,.medium,1668,.center)
    let trackX:CGFloat=100,tw:CGFloat=1720
    V.box(g,trackX,1050,tw,4,V.lineColor,2)
    V.box(g,trackX,1050,tw*CGFloat(min(1,max(0,elapsed/max(1,total)))),4,V.blue,2)
    V.small(String(format:"%02d / 12",si+1),1680,875,V.muted,150)
    NSGraphicsContext.restoreGraphicsState();g.restoreGState()
}
