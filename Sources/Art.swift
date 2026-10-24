import AppKit
import CoreGraphics

/// Compact vector illustrations. Coordinates use a top-down drawing context.
/// Each artwork is centered on (x, y) in a nominal 200 × 200 box.
enum Art {
    private static let ink = color(0x172A35)
    private static let blue = color(0x3155E7)
    private static let orange = color(0xF5A54A)
    private static let green = color(0x2A9E83)
    private static let paper = color(0xF5F4EE)
    private static let white = color(0xFFFFFF)
    private static let paleBlue = color(0xDDE5FA)
    private static let steel = color(0x708394)
    private static let pale = color(0xE1E6E5)

    private static func color(_ rgb: UInt32, _ a: CGFloat = 1) -> CGColor {
        CGColor(red: CGFloat((rgb >> 16) & 255)/255, green: CGFloat((rgb >> 8) & 255)/255, blue: CGFloat(rgb & 255)/255, alpha: a)
    }
    private static func alpha(_ c: CGColor, _ a: CGFloat) -> CGColor { c.copy(alpha: a)! }
    private static func clamp(_ x: CGFloat) -> CGFloat { max(0, min(1, x)) }
    private static func local(_ g: CGContext, _ x: CGFloat, _ y: CGFloat, _ scale: CGFloat, _ body: () -> Void) {
        g.saveGState(); g.translateBy(x: x, y: y); g.scaleBy(x: scale, y: scale)
        g.setLineCap(.round); g.setLineJoin(.round); body(); g.restoreGState()
    }
    private static func rounded(_ g: CGContext, _ r: CGRect, _ radius: CGFloat, _ fill: CGColor, _ stroke: CGColor? = nil, _ width: CGFloat = 2) {
        let p = CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
        g.addPath(p); g.setFillColor(fill)
        if let stroke = stroke { g.setStrokeColor(stroke); g.setLineWidth(width); g.drawPath(using: .fillStroke) } else { g.fillPath() }
    }
    private static func ellipse(_ g: CGContext, _ r: CGRect, _ fill: CGColor, _ stroke: CGColor? = nil, _ width: CGFloat = 2) {
        g.setFillColor(fill); g.addEllipse(in: r)
        if let stroke = stroke { g.setStrokeColor(stroke); g.setLineWidth(width); g.drawPath(using: .fillStroke) } else { g.fillPath() }
    }
    private static func line(_ g: CGContext, _ points: [CGPoint], _ stroke: CGColor, _ width: CGFloat = 3, _ closed: Bool = false) {
        guard let first = points.first else { return }; g.beginPath(); g.move(to: first)
        for point in points.dropFirst() { g.addLine(to: point) }; if closed { g.closePath() }
        g.setStrokeColor(stroke); g.setLineWidth(width); g.strokePath()
    }
    private static func polygon(_ g: CGContext, _ points: [CGPoint], _ fill: CGColor, _ stroke: CGColor? = nil, _ width: CGFloat = 2) {
        guard let first = points.first else { return }; g.beginPath(); g.move(to: first)
        for point in points.dropFirst() { g.addLine(to: point) }; g.closePath(); g.setFillColor(fill)
        if let stroke = stroke { g.setStrokeColor(stroke); g.setLineWidth(width); g.drawPath(using: .fillStroke) } else { g.fillPath() }
    }
    private static func curve(_ g: CGContext, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint, _ stroke: CGColor, _ width: CGFloat) {
        g.beginPath(); g.move(to: a); g.addCurve(to: d, control1: b, control2: c); g.setStrokeColor(stroke); g.setLineWidth(width); g.strokePath()
    }
    private static func shadow(_ g: CGContext, _ width: CGFloat = 140, _ y: CGFloat = 80) {
        ellipse(g, CGRect(x: -width/2, y: y, width: width, height: 10), alpha(ink, 0.075))
    }
    private static func bolt(_ g: CGContext, _ x: CGFloat, _ y: CGFloat, _ scale: CGFloat, _ fill: CGColor) {
        polygon(g, [CGPoint(x:x+3*scale,y:y-15*scale),CGPoint(x:x-9*scale,y:y+3*scale),CGPoint(x:x-1*scale,y:y+3*scale),CGPoint(x:x-4*scale,y:y+15*scale),CGPoint(x:x+10*scale,y:y-5*scale),CGPoint(x:x+2*scale,y:y-5*scale)], fill)
    }

    static func kettle(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1, heat: CGFloat = 0, steam: CGFloat = 0, time: Double = 0, powerOn: Bool = true) {
        local(g, x, y, scale) {
            let h = clamp(heat), s = clamp(steam)
            shadow(g, 155, 80)
            // Handle behind the glass body, with an open center.
            rounded(g, CGRect(x: 30, y: -42, width: 50, height: 92), 22, ink)
            rounded(g, CGRect(x: 42, y: -29, width: 25, height: 62), 12, paper)
            polygon(g, [CGPoint(x:-45,y:-37),CGPoint(x:-79,y:-49),CGPoint(x:-65,y:-10),CGPoint(x:-48,y:3)], paleBlue, ink, 3)
            g.saveGState(); g.setShadow(offset: CGSize(width: 0, height: 5), blur: 10, color: alpha(ink, 0.12))
            rounded(g, CGRect(x:-54,y:-49,width:107,height:116), 24, color(0xEDF3FA), ink, 3)
            g.restoreGState()
            g.saveGState()
            g.addPath(CGPath(roundedRect: CGRect(x:-50,y:-45,width:99,height:108), cornerWidth:20, cornerHeight:20, transform:nil)); g.clip()
            let waterTop: CGFloat = -4
            g.setFillColor(CGColor(red: 0.61 + h * 0.16, green: 0.72 + h * 0.08, blue: 0.96 - h * 0.08, alpha: 0.72)); g.fill(CGRect(x:-51,y:waterTop,width:102,height:70))
            g.beginPath(); g.move(to:CGPoint(x:-51,y:waterTop))
            g.addCurve(to:CGPoint(x:51,y:waterTop), control1:CGPoint(x:-19,y:waterTop-5+CGFloat(sin(time*1.6))*2), control2:CGPoint(x:18,y:waterTop+5)); g.setStrokeColor(alpha(blue,0.6)); g.setLineWidth(2); g.strokePath()
            if h > 0.02 {
                for i in 0..<10 {
                    let phase = (time*0.55 + Double(i)*0.123).truncatingRemainder(dividingBy:1)
                    let bx = -35 + CGFloat((i*19)%70)
                    let by = 57 - CGFloat(phase)*59
                    let r: CGFloat = 1.7 + CGFloat(i%3)*0.6
                    ellipse(g,CGRect(x:bx,y:by,width:r*2,height:r*2),alpha(white,h*0.75*(1-CGFloat(phase)*0.4)))
                }
            }
            rounded(g,CGRect(x:-42,y:-35,width:9,height:81),4,alpha(white,0.68))
            g.restoreGState()
            for i in 0..<3 { line(g,[CGPoint(x:27,y:CGFloat(8+i*15)),CGPoint(x:35,y:CGFloat(8+i*15))],alpha(ink,0.28),1.5) }
            rounded(g,CGRect(x:-53,y:-56,width:106,height:16),7,ink)
            rounded(g,CGRect(x:-18,y:-65,width:36,height:12),6,steel)
            rounded(g,CGRect(x:-54,y:53,width:108,height:18),7,steel)
            line(g,[CGPoint(x:-37,y:57),CGPoint(x:35,y:57)],powerOn ? color(0xEF6948,0.9) : alpha(steel,0.35),4)
            rounded(g,CGRect(x:-62,y:72,width:124,height:11),5,ink)
            ellipse(g,CGRect(x:40,y:75,width:5,height:5),powerOn ? orange : steel)
            if s > 0.01 {
                for i in 0..<3 {
                    let phase = time*1.7 + Double(i)*1.8
                    let xx: CGFloat = -35 + CGFloat(i)*27
                    let drift = CGFloat(sin(phase))*4
                    curve(g,CGPoint(x:xx,y:-70),CGPoint(x:xx-13+drift,y:-83),CGPoint(x:xx+13+drift,y:-94),CGPoint(x:xx+drift,y:-109),alpha(steel,s*0.42),2.5)
                }
            }
        }
    }

    static func plant(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1) {
        local(g,x,y,scale) {
            shadow(g,184,80)
            // Cooling tower and turbine hall as two distinct industrial forms.
            g.beginPath(); g.move(to:CGPoint(x:-74,y:61)); g.addCurve(to:CGPoint(x:-64,y:-47),control1:CGPoint(x:-48,y:23),control2:CGPoint(x:-54,y:-16)); g.addLine(to:CGPoint(x:-27,y:-47)); g.addCurve(to:CGPoint(x:-15,y:61),control1:CGPoint(x:-40,y:-13),control2:CGPoint(x:-33,y:23)); g.closePath(); g.setFillColor(pale); g.fillPath()
            curve(g,CGPoint(x:-74,y:61),CGPoint(x:-48,y:23),CGPoint(x:-54,y:-16),CGPoint(x:-64,y:-47),steel,2)
            curve(g,CGPoint(x:-27,y:-47),CGPoint(x:-40,y:-13),CGPoint(x:-33,y:23),CGPoint(x:-15,y:61),steel,2)
            ellipse(g,CGRect(x:-64,y:-54,width:37,height:12),steel)
            ellipse(g,CGRect(x:-58,y:-51,width:25,height:6),ink)
            curve(g,CGPoint(x:-47,y:-59),CGPoint(x:-57,y:-76),CGPoint(x:-27,y:-78),CGPoint(x:-38,y:-95),alpha(steel,0.23),9)
            rounded(g,CGRect(x:54,y:-70,width:16,height:108),3,pale,steel,2)
            rounded(g,CGRect(x:54,y:-51,width:16,height:8),0,orange)
            rounded(g,CGRect(x:54,y:-29,width:16,height:8),0,orange)
            polygon(g,[CGPoint(x:-21,y:7),CGPoint(x:11,y:-11),CGPoint(x:41,y:7),CGPoint(x:72,y:-11),CGPoint(x:91,y:1),CGPoint(x:91,y:68),CGPoint(x:-21,y:68)],paleBlue,ink,2.5)
            rounded(g,CGRect(x:-9,y:27,width:86,height:26),4,white)
            for i in 0..<4 { rounded(g,CGRect(x:CGFloat(-3+i*20),y:32,width:12,height:15),2,alpha(blue,0.55)) }
            rounded(g,CGRect(x:7,y:58,width:28,height:20),2,steel)
            rounded(g,CGRect(x:-87,y:68,width:182,height:12),4,ink)
            line(g,[CGPoint(x:-81,y:64),CGPoint(x:-81,y:50),CGPoint(x:-20,y:50)],steel,3)
            bolt(g,62,62,0.55,orange)
        }
    }

    static func tower(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1) {
        local(g,x,y,scale) {
            shadow(g,134,86)
            let metal = color(0x586D7F)
            polygon(g,[CGPoint(x:-12,y:-90),CGPoint(x:12,y:-90),CGPoint(x:43,y:83),CGPoint(x:27,y:83),CGPoint(x:0,y:-68),CGPoint(x:-27,y:83),CGPoint(x:-43,y:83)],alpha(steel,0.1))
            line(g,[CGPoint(x:-42,y:82),CGPoint(x:-12,y:-90),CGPoint(x:12,y:-90),CGPoint(x:42,y:82)],metal,3.5)
            for level in 0..<4 {
                let top: CGFloat = -61+CGFloat(level)*35, bottom = top+35
                let w1: CGFloat = 17+CGFloat(level)*6, w2 = w1+6
                line(g,[CGPoint(x:-w1,y:top),CGPoint(x:w2,y:bottom),CGPoint(x:-w2,y:bottom),CGPoint(x:w1,y:top)],metal,2)
            }
            for (yy,span) in [(CGFloat(-57),CGFloat(57)),(CGFloat(-18),CGFloat(72)),(CGFloat(25),CGFloat(83))] {
                line(g,[CGPoint(x:-span,y:yy),CGPoint(x:span,y:yy)],metal,4)
                line(g,[CGPoint(x:-span,y:yy),CGPoint(x:-17,y:yy-14),CGPoint(x:17,y:yy-14),CGPoint(x:span,y:yy)],metal,2)
                for side in [-1,1] {
                    let xx=CGFloat(side)*span
                    line(g,[CGPoint(x:xx,y:yy),CGPoint(x:xx,y:yy+17)],ink,2)
                    for j in 0..<4 { ellipse(g,CGRect(x:xx-5,y:yy+3+CGFloat(j)*4,width:10,height:3),green) }
                }
            }
            rounded(g,CGRect(x:-48,y:81,width:17,height:7),2,ink)
            rounded(g,CGRect(x:31,y:81,width:17,height:7),2,ink)
        }
    }

    static func wind(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1, time: Double = 0) {
        local(g,x,y,scale) {
            shadow(g,91,86)
            polygon(g,[CGPoint(x:-4,y:-28),CGPoint(x:4,y:-28),CGPoint(x:11,y:84),CGPoint(x:-11,y:84)],white,steel,2)
            rounded(g,CGRect(x:-23,y:80,width:46,height:7),3,ink)
            rounded(g,CGRect(x:-11,y:-43,width:35,height:17),7,steel)
            g.saveGState(); g.translateBy(x:0,y:-35); g.rotate(by:CGFloat(time*0.65))
            for i in 0..<3 {
                g.saveGState(); g.rotate(by:CGFloat(i)*2*CGFloat.pi/3)
                g.beginPath(); g.move(to:CGPoint(x:0,y:0)); g.addCurve(to:CGPoint(x:4,y:-77),control1:CGPoint(x:-8,y:-27),control2:CGPoint(x:-1,y:-60)); g.addCurve(to:CGPoint(x:10,y:-23),control1:CGPoint(x:13,y:-53),control2:CGPoint(x:15,y:-33)); g.addLine(to:CGPoint(x:4,y:0)); g.closePath(); g.setFillColor(white); g.setStrokeColor(steel);g.setLineWidth(1.7);g.drawPath(using:.fillStroke)
                line(g,[CGPoint(x:4,y:-60),CGPoint(x:6,y:-71)],orange,3)
                g.restoreGState()
            }
            ellipse(g,CGRect(x:-10,y:-10,width:20,height:20),blue,white,3)
            g.restoreGState()
        }
    }

    static func solar(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1) {
        local(g,x,y,scale) {
            shadow(g,176,82)
            line(g,[CGPoint(x:-51,y:28),CGPoint(x:-61,y:80)],steel,7)
            line(g,[CGPoint(x:51,y:28),CGPoint(x:61,y:80)],steel,7)
            rounded(g,CGRect(x:-72,y:78,width:26,height:7),3,ink)
            rounded(g,CGRect(x:46,y:78,width:26,height:7),3,ink)
            let a = CGPoint(x:-67,y:-45), b = CGPoint(x:67,y:-45), c = CGPoint(x:87,y:47), d = CGPoint(x:-87,y:47)
            polygon(g,[a,b,c,d],ink,steel,4)
            for row in 0..<3 {
                let t1=CGFloat(row)/3, t2=CGFloat(row+1)/3
                let y1 = -42+t1*86, y2 = -42+t2*86
                let w1 = 66+t1*19, w2=66+t2*19
                for col in 0..<6 {
                    let u1=CGFloat(col)/6,u2=CGFloat(col+1)/6
                    polygon(g,[CGPoint(x:-w1+2*w1*u1+2,y:y1+2),CGPoint(x:-w1+2*w1*u2-2,y:y1+2),CGPoint(x:-w2+2*w2*u2-2,y:y2-2),CGPoint(x:-w2+2*w2*u1+2,y:y2-2)],(row+col)%3==0 ? color(0x4C6BE6) : blue)
                }
            }
            polygon(g,[CGPoint(x:-62,y:-41),CGPoint(x:-15,y:-41),CGPoint(x:12,y:43),CGPoint(x:-40,y:43)],alpha(white,0.12))
            ellipse(g,CGRect(x:48,y:-87,width:27,height:27),orange)
            for i in 0..<8 { let a=CGFloat(i)*CGFloat.pi/4; line(g,[CGPoint(x:61.5+cos(a)*19,y:-73.5+sin(a)*19),CGPoint(x:61.5+cos(a)*24,y:-73.5+sin(a)*24)],orange,2) }
        }
    }

    static func house(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1, lit: Bool = true) {
        local(g,x,y,scale) {
            shadow(g,172,82)
            rounded(g,CGRect(x:37,y:-80,width:18,height:43),2,steel)
            rounded(g,CGRect(x:-66,y:-20,width:132,height:101),4,white,steel,2)
            polygon(g,[CGPoint(x:-83,y:-20),CGPoint(x:0,y:-88),CGPoint(x:83,y:-20)],ink)
            polygon(g,[CGPoint(x:-65,y:-20),CGPoint(x:0,y:-73),CGPoint(x:65,y:-20)],blue)
            line(g,[CGPoint(x:-81,y:-17),CGPoint(x:0,y:-84),CGPoint(x:81,y:-17)],ink,5)
            let glass = lit ? color(0xFFE2A7) : paleBlue
            for xx: CGFloat in [-44, 23] {
                rounded(g,CGRect(x:xx,y:4,width:25,height:29),3,glass,steel,2)
                line(g,[CGPoint(x:xx+12.5,y:5),CGPoint(x:xx+12.5,y:32)],white,2)
                line(g,[CGPoint(x:xx,y:18.5),CGPoint(x:xx+25,y:18.5)],white,2)
                rounded(g,CGRect(x:xx-4,y:33,width:33,height:4),1,steel)
            }
            rounded(g,CGRect(x:-15,y:34,width:30,height:47),3,green)
            ellipse(g,CGRect(x:6,y:57,width:4,height:4),orange)
            rounded(g,CGRect(x:-24,y:78,width:48,height:6),2,ink)
            ellipse(g,CGRect(x:-61,y:52,width:27,height:24),green)
            ellipse(g,CGRect(x:-48,y:60,width:28,height:20),color(0x56B39A))
            rounded(g,CGRect(x:69,y:49,width:4,height:32),2,steel)
            ellipse(g,CGRect(x:60,y:27,width:23,height:33),green)
        }
    }

    static func transformer(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1, pulse: CGFloat = 0) {
        local(g,x,y,scale) {
            shadow(g,173,79)
            // Closed laminated iron core around both windings.
            rounded(g,CGRect(x:-71,y:-66,width:142,height:133),12,steel,ink,2)
            rounded(g,CGRect(x:-48,y:-43,width:96,height:87),5,paper)
            for i in 0..<4 { rounded(g,CGRect(x:-67+CGFloat(i)*3,y:-62+CGFloat(i)*3,width:134-CGFloat(i)*6,height:125-CGFloat(i)*6),9,alpha(white,0),alpha(ink,0.14),0.7) }
            rounded(g,CGRect(x:-48,y:-43,width:96,height:87),5,paper)
            for i in 0..<5 {
                rounded(g,CGRect(x:-84,y:-36+CGFloat(i)*15,width:51,height:10),5,orange,ink,1.3)
                line(g,[CGPoint(x:-78,y:-33+CGFloat(i)*15),CGPoint(x:-40,y:-33+CGFloat(i)*15)],alpha(white,0.4),1.6)
            }
            for i in 0..<8 {
                rounded(g,CGRect(x:33,y:-41+CGFloat(i)*10,width:51,height:7),3.5,blue,ink,1)
                line(g,[CGPoint(x:39,y:-39+CGFloat(i)*10),CGPoint(x:78,y:-39+CGFloat(i)*10)],alpha(white,0.3),1)
            }
            line(g,[CGPoint(x:-85,y:-32),CGPoint(x:-96,y:-32),CGPoint(x:-96,y:-57)],orange,3)
            line(g,[CGPoint(x:-85,y:29),CGPoint(x:-96,y:29),CGPoint(x:-96,y:55)],orange,3)
            line(g,[CGPoint(x:85,y:-38),CGPoint(x:96,y:-38),CGPoint(x:96,y:-57)],blue,3)
            line(g,[CGPoint(x:85,y:32),CGPoint(x:96,y:32),CGPoint(x:96,y:55)],blue,3)
            if pulse > 0.001 {
                let p=clamp(pulse)
                g.saveGState();g.setLineDash(phase:p*28,lengths:[9,9]);rounded(g,CGRect(x:-57,y:-53,width:114,height:107),6,alpha(white,0),alpha(green,0.7),2.5);g.restoreGState()
            }
            bolt(g,0,0,0.95,green)
        }
    }

    static func socket(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1) {
        local(g,x,y,scale) {
            shadow(g,150,79)
            g.saveGState(); g.setShadow(offset:CGSize(width:0,height:5),blur:11,color:alpha(ink,0.13))
            rounded(g,CGRect(x:-73,y:-73,width:146,height:146),18,white,alpha(steel,0.45),2)
            g.restoreGState()
            rounded(g,CGRect(x:-57,y:-57,width:114,height:114),13,paper,alpha(steel,0.2),1)
            // Chinese two-pin outlet: neutral on the left, live on the right.
            rounded(g,CGRect(x:-31,y:-23,width:10,height:38),3,ink)
            rounded(g,CGRect(x:21,y:-23,width:10,height:38),3,ink)
            rounded(g,CGRect(x:-32,y:25,width:12,height:4),2,blue)
            rounded(g,CGRect(x:20,y:25,width:12,height:4),2,orange)
            for yy: CGFloat in [-63,63] {
                ellipse(g,CGRect(x:-3,y:yy-3,width:6,height:6),pale,steel,0.8)
                line(g,[CGPoint(x:-1.5,y:yy+1.5),CGPoint(x:1.5,y:yy-1.5)],steel,0.8)
            }
        }
    }

    static func meter(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1, value: Double = 1) {
        local(g,x,y,scale) {
            shadow(g,133,82)
            g.saveGState();g.setShadow(offset:CGSize(width:0,height:4),blur:9,color:alpha(ink,0.12))
            rounded(g,CGRect(x:-62,y:-83,width:124,height:164),14,white,steel,2)
            g.restoreGState()
            rounded(g,CGRect(x:-49,y:-66,width:98,height:51),7,ink)
            rounded(g,CGRect(x:-43,y:-59,width:86,height:37),4,color(0xCFDDCB))
            let number = String(format:"%06.2f", max(0,value))
            let attributes: [NSAttributedString.Key:Any] = [.font:NSFont.monospacedDigitSystemFont(ofSize:19,weight:.medium), .foregroundColor:NSColor(cgColor:ink)!]
            let ns = number as NSString, size=ns.size(withAttributes:attributes)
            ns.draw(at:CGPoint(x:-size.width/2,y:-52),withAttributes:attributes)
            rounded(g,CGRect(x:-43,y:0,width:63,height:4),2,pale)
            rounded(g,CGRect(x:-43,y:11,width:47,height:3),1.5,pale)
            ellipse(g,CGRect(x:31,y:0,width:9,height:9),orange)
            rounded(g,CGRect(x:-49,y:32,width:98,height:36),5,pale)
            for i in 0..<4 {
                rounded(g,CGRect(x:-37+CGFloat(i)*22,y:39,width:13,height:16),3,steel)
                ellipse(g,CGRect(x:-34+CGFloat(i)*22,y:44,width:7,height:7),ink)
                line(g,[CGPoint(x:-30.5+CGFloat(i)*22,y:55),CGPoint(x:-30.5+CGFloat(i)*22,y:76)],i<2 ? orange : blue,3)
            }
            for xx: CGFloat in [-50,50] { ellipse(g,CGRect(x:xx-2.5,y:-75,width:5,height:5),pale,steel,0.8) }
        }
    }

    static func breaker(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1) {
        local(g,x,y,scale) {
            shadow(g,168,82)
            g.saveGState();g.setShadow(offset:CGSize(width:0,height:5),blur:10,color:alpha(ink,0.12))
            rounded(g,CGRect(x:-79,y:-69,width:158,height:148),10,pale,steel,2)
            g.restoreGState()
            rounded(g,CGRect(x:-68,y:-57,width:136,height:115),6,white)
            line(g,[CGPoint(x:-59,y:15),CGPoint(x:59,y:15)],steel,7)
            for i in 0..<4 {
                let xx=CGFloat(-59+i*31)
                rounded(g,CGRect(x:xx,y:-33,width:26,height:67),4,paper,steel,1.5)
                rounded(g,CGRect(x:xx+5,y:-24,width:16,height:12),2,ink)
                rounded(g,CGRect(x:xx+5,y:-23,width:16,height:6),2,i==0 ? orange : blue)
                rounded(g,CGRect(x:xx+6,y:2,width:14,height:4),1,green)
                for yy: CGFloat in [-44,42] {
                    ellipse(g,CGRect(x:xx+10,y:yy,width:6,height:6),steel)
                    line(g,[CGPoint(x:xx+13,y:yy+1),CGPoint(x:xx+13,y:yy+5)],ink,0.9)
                }
                line(g,[CGPoint(x:xx+13,y:-44),CGPoint(x:xx+13,y:-54)],orange,2.5)
                line(g,[CGPoint(x:xx+13,y:48),CGPoint(x:xx+13,y:56)],blue,2.5)
            }
            rounded(g,CGRect(x:-65,y:64,width:130,height:5),2,paper)
            ellipse(g,CGRect(x:65,y:2,width:6,height:16),steel)
        }
    }

    static func battery(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1, charge: CGFloat = 1) {
        local(g,x,y,scale) {
            shadow(g,129,84)
            rounded(g,CGRect(x:-24,y:-84,width:48,height:16),4,steel,ink,2)
            g.saveGState();g.setShadow(offset:CGSize(width:0,height:5),blur:10,color:alpha(ink,0.12))
            rounded(g,CGRect(x:-52,y:-70,width:104,height:148),12,white,ink,3)
            g.restoreGState()
            rounded(g,CGRect(x:-41,y:-58,width:82,height:124),6,pale)
            let amount=clamp(charge), height=116*amount
            if height>0 { rounded(g,CGRect(x:-37,y:62-height,width:74,height:height),4,amount<0.2 ? orange : green) }
            for yy:CGFloat in [-27,4,35] { line(g,[CGPoint(x:-37,y:yy),CGPoint(x:37,y:yy)],alpha(white,0.6),2) }
            bolt(g,0,3,1.5,white)
            line(g,[CGPoint(x:-7,y:-77),CGPoint(x:7,y:-77)],paper,2)
        }
    }

    static func generator(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1, time: Double = 0) {
        local(g,x,y,scale) {
            shadow(g,171,82)
            rounded(g,CGRect(x:-68,y:67,width:136,height:14),5,ink)
            polygon(g,[CGPoint(x:-52,y:38),CGPoint(x:-37,y:38),CGPoint(x:-33,y:69),CGPoint(x:-60,y:69)],steel)
            polygon(g,[CGPoint(x:37,y:38),CGPoint(x:52,y:38),CGPoint(x:60,y:69),CGPoint(x:33,y:69)],steel)
            ellipse(g,CGRect(x:-76,y:-76,width:152,height:142),pale,steel,3)
            ellipse(g,CGRect(x:-59,y:-59,width:118,height:108),white,ink,2)
            for i in 0..<12 {
                g.saveGState();g.translateBy(x:0,y:-5);g.rotate(by:CGFloat(i)*CGFloat.pi/6)
                rounded(g,CGRect(x:-8,y:-62,width:16,height:21),5,orange,ink,1)
                line(g,[CGPoint(x:-5,y:-57),CGPoint(x:5,y:-57)],alpha(white,0.45),1)
                line(g,[CGPoint(x:-5,y:-52),CGPoint(x:5,y:-52)],alpha(white,0.45),1)
                g.restoreGState()
            }
            g.saveGState(); g.translateBy(x:0,y:-5); g.rotate(by:CGFloat(time*1.2))
            rounded(g,CGRect(x:-39,y:-16,width:78,height:32),8,blue,ink,2)
            rounded(g,CGRect(x:-39,y:-16,width:39,height:32),7,orange)
            line(g,[CGPoint(x:0,y:-15),CGPoint(x:0,y:15)],ink,1.5)
            ellipse(g,CGRect(x:-10,y:-10,width:20,height:20),white,ink,2)
            ellipse(g,CGRect(x:-3,y:-3,width:6,height:6),ink)
            g.restoreGState()
            line(g,[CGPoint(x:68,y:16),CGPoint(x:89,y:16),CGPoint(x:89,y:45)],blue,4)
            line(g,[CGPoint(x:61,y:34),CGPoint(x:78,y:34),CGPoint(x:78,y:55)],orange,4)
        }
    }

    static func bulb(_ g: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat = 1, glow: CGFloat = 1) {
        local(g,x,y,scale) {
            let light=clamp(glow)
            shadow(g,89,84)
            if light>0 {
                ellipse(g,CGRect(x:-88,y:-101,width:176,height:176),alpha(orange,light*0.06))
                ellipse(g,CGRect(x:-73,y:-86,width:146,height:146),alpha(orange,light*0.09))
                for i in 0..<9 {
                    let a = CGFloat.pi+CGFloat(i)*CGFloat.pi/8
                    line(g,[CGPoint(x:cos(a)*72,y:-22+sin(a)*72),CGPoint(x:cos(a)*83,y:-22+sin(a)*83)],alpha(orange,light*0.75),2.5)
                }
            }
            g.beginPath();g.move(to:CGPoint(x:-21,y:47));g.addLine(to:CGPoint(x:-23,y:28));g.addCurve(to:CGPoint(x:-52,y:-20),control1:CGPoint(x:-27,y:14),control2:CGPoint(x:-52,y:4));g.addCurve(to:CGPoint(x:0,y:-72),control1:CGPoint(x:-52,y:-51),control2:CGPoint(x:-31,y:-72));g.addCurve(to:CGPoint(x:52,y:-20),control1:CGPoint(x:31,y:-72),control2:CGPoint(x:52,y:-51));g.addCurve(to:CGPoint(x:23,y:28),control1:CGPoint(x:52,y:4),control2:CGPoint(x:27,y:14));g.addLine(to:CGPoint(x:21,y:47));g.closePath();g.setFillColor(light>0 ? color(0xFFE0A3) : paleBlue);g.setStrokeColor(steel);g.setLineWidth(2.5);g.drawPath(using:.fillStroke)
            curve(g,CGPoint(x:-35,y:-29),CGPoint(x:-36,y:-45),CGPoint(x:-24,y:-57),CGPoint(x:-12,y:-59),alpha(white,0.8),5)
            line(g,[CGPoint(x:-12,y:44),CGPoint(x:-18,y:-3),CGPoint(x:-8,y:3),CGPoint(x:0,y:-4),CGPoint(x:8,y:3),CGPoint(x:18,y:-3),CGPoint(x:12,y:44)],light>0 ? orange : steel,2.5)
            rounded(g,CGRect(x:-24,y:43,width:48,height:30),5,steel,ink,2)
            for i in 0..<3 { line(g,[CGPoint(x:-20,y:49+CGFloat(i)*8),CGPoint(x:20,y:45+CGFloat(i)*8)],pale,2) }
            rounded(g,CGRect(x:-12,y:72,width:24,height:9),4,ink)
        }
    }
}
